import 'dart:io';
import 'dart:math' show sqrt;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

@immutable
class KeyStrokeRep {
  final SingleActivator keyActivator;
  final String description;
  final VoidCallback callback;
  KeyStrokeRep(LogicalKeyboardKey keyStroke, this.description, this.callback,
      {bool isControlPressed = false, bool isMetaPressed = false, bool isShiftPressed = false, bool isAltPressed = false}):
      keyActivator = SingleActivator(keyStroke, control: isControlPressed, shift: isShiftPressed, alt: isAltPressed, meta: isMetaPressed);

  bool get isControlPressed => keyActivator.control;
  bool get isMetaPressed => keyActivator.meta;
  bool get isShiftPressed => keyActivator.shift;
  bool get isAltPressed => keyActivator.alt;
  String get label => keyActivator.trigger.keyLabel;
}

class KeyboardWidget extends StatefulWidget {
  final bool hasFocus;
  final Widget child;
  final List<KeyStrokeRep> keyMap;

  const KeyboardWidget({Key? key, required this.keyMap, this.hasFocus = false,
    required this.child,}) : super(key: key);

  @override
  _KeyboardWidgetState createState() => _KeyboardWidgetState();

}

class _KeyboardWidgetState extends State<KeyboardWidget> {
  late FocusNode _focusNode;
  late OverlayEntry _overlayEntry;
  bool showingOverlay = false;

  static const TextStyle _whiteStyle = TextStyle(color: Color(0xAAFFFFFF));
  // static const TextStyle _boldStyle = TextStyle(color: Colors.white, fontWeight: FontWeight.bold);
  static const TextStyle _blackStyle =TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold);

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(KeyboardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hasFocus) {
      _focusNode.requestFocus();
    }
  }
  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
  //returns a white rounded-rect surrounded with black text
  Widget _getBubble(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: _blackStyle,),
    );
  }

  Widget _getShortcutWidget(String text, String description, {String? modifiers}) {
    List<Widget> widgets = [_getBubble(text), const SizedBox(width: 4),
      Text(description, style: _whiteStyle,)];
    if (modifiers != null) {
      widgets.insert(0, _getBubble(modifiers));
      widgets.insert(1, const SizedBox(width: 4,));
    }
    return Container(
        height: 20,
        padding: const EdgeInsets.all(4),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min, children: widgets,
        )
    );
  }

  //returns the modifier key as text or a symbol (where possible)
  String _getModifiers(KeyStrokeRep rep) {
    StringBuffer buffer = StringBuffer();
    if(rep.isMetaPressed) {
      if (Platform.isMacOS) {
        buffer.write('⌘');
      }
      else {
        buffer.write('meta');
      }
    }
    if (rep.isShiftPressed) {
      buffer.write('⇧');
    }
    if (rep.isControlPressed) {
      if (Platform.isMacOS) {
        buffer.write('⌃');
      }
      else {
        buffer.write('ctrl');
      }
    }
    if (rep.isAltPressed) {
      if (Platform.isMacOS) {
        buffer.write('⌥');
      }
      else {
        buffer.write('alt');
      }
    }
    return buffer.toString();
  }

  OverlayEntry _buildOverlay() {
    List<Widget> shortcuts = [];
    for (KeyStrokeRep keyEvent in widget.keyMap) {
      String description = keyEvent.description;
      String modifier = _getModifiers(keyEvent);
      shortcuts.add(_getShortcutWidget(keyEvent.label, description, modifiers: modifier));
    }

    Size size = MediaQuery.of(context).size;
    int cols = sqrt(shortcuts.length).toInt();
    int rows = shortcuts.length~/cols;
    // print('COLS: $cols ROWS: $rows  TOTAL: ${shortcuts.length}');
    Widget grid = GridView.count(
      crossAxisCount: cols, children: shortcuts,
      childAspectRatio: 700/cols/40,
      shrinkWrap: true,);
    return OverlayEntry(
        builder: (context) {
          EdgeInsets padding = MediaQuery.of(context).padding;
          return Positioned(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _overlayEntry.remove();
                  });
                },
                child: Container(
                  alignment: Alignment.center,
                  height: size.width - padding.left - padding.right - 40,
                  width: size.height - padding.top - padding.bottom - 40,
                  decoration: const BoxDecoration(
                    color: Colors.black12,
                  ),
                  child: Material(
                      color: Colors.transparent,
                      child: Container(
                        alignment: Alignment.center,
                        width: 750, height: 30.0*rows+40,
                        decoration: BoxDecoration(color: Colors.black54,
                          borderRadius: BorderRadius.circular(18),
                          // border: Border.all(color: Colors.red),
                        ),
                        child: grid,
                        // child:const Text('OVERLAY', style: TextStyle(color: Colors.white),)
                      )
                  ),
                ),
              )
          );
        }
    );
  }
  @override
  Widget build(BuildContext context) {
    if (kIsWeb || Platform.isFuchsia || Platform.isLinux || Platform.isMacOS ||
        Platform.isWindows) {
      return LayoutBuilder(
          builder:(context, constraints) {
            FocusScope.of(context).requestFocus(_focusNode);
            return _getKeyboardListener(context);
          }
      );
    }
    else {
      return widget.child;
    }

  }
  Widget _getKeyboardListener(BuildContext context) {
    return RawKeyboardListener(
      child: widget.child,
      focusNode: _focusNode,
      autofocus: widget.hasFocus,
      onKey: (RawKeyEvent event) {
        if (event.runtimeType == RawKeyUpEvent) {
          LogicalKeyboardKey key = event.logicalKey;

          // if (key == LogicalKeyboardKey.arrowLeft) {
          //   double v = widget.controller.value;
          //   widget.controller.value = max(0, v - .1);
          // }
          // else if (key == LogicalKeyboardKey.arrowRight) {
          //   double v = widget.controller.value;
          //   widget.controller.value = min(1.0, v + .1);
          // }
          // else if (key == LogicalKeyboardKey.enter) {
          //   if (widget.controller.isAnimating) {
          //     widget.controller.stop();
          //   }
          //   else {
          //     widget.controller.forward();
          //   }
          // }
          // else if (key.keyLabel == 'B' && event.isControlPressed) {
          //   widget.controller.reverse();
          // }
          if (key == LogicalKeyboardKey.f1) {
            print('PRESSED F1');
            setState(() {
              if (!showingOverlay) {
                showingOverlay = true;
                _overlayEntry = _buildOverlay();
                Overlay.of(context)!.insert(_overlayEntry);
              }
              else {
                _hideOverlay();
              }
            }
            );}
          else if (key == LogicalKeyboardKey.escape) {
            _hideOverlay();
          }
        }
      },);
  }
  void _hideOverlay() {
    setState(() {
      showingOverlay = false;
      _overlayEntry.remove();
    });
  }
}


