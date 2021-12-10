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

  bool matchesEvent(RawKeyEvent event) {
    return event.logicalKey == keyActivator.trigger && isControlPressed == event.isControlPressed &&
    isMetaPressed == event.isMetaPressed && isShiftPressed == event.isShiftPressed &&
    isAltPressed == event.isAltPressed;
  }
}

/// A keymap widget
///
class KeyboardWidget extends StatefulWidget {
  final bool hasFocus;
  final Widget child;
  final List<KeyStrokeRep> keyMap;
  final LogicalKeyboardKey showDismissKey;

  /// Creates a new KeyboardWidget with a list of Keystrokes and associated
  /// functions [keyMap], a required [child] widget and an optional
  /// keystroke to show and dismiss the displayed map, [showDismissKey].
  ///
  /// By default the F1 keyboard key is used to show and dismiss the keymap
  /// display.
  ///
  const KeyboardWidget({Key? key, required this.keyMap, this.hasFocus = false,
    required this.child, this.showDismissKey=LogicalKeyboardKey.f1}) : super(key: key);

  @override
  _KeyboardWidgetState createState() => _KeyboardWidgetState();

}

class _KeyboardWidgetState extends State<KeyboardWidget> {
  late FocusNode _focusNode;
  late OverlayEntry _overlayEntry;
  bool showingOverlay = false;

  static const TextStyle _whiteStyle = TextStyle(color: Colors.white, fontSize: 12);
  // static const TextStyle _boldStyle = TextStyle(color: Colors.white, fontWeight: FontWeight.bold);
  static const TextStyle _blackStyle = TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.normal);

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
      Flexible(child: Text(description, style: _whiteStyle, overflow: TextOverflow.ellipsis,))];
    if (modifiers != null && modifiers.isNotEmpty) {
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

  KeyStrokeRep? _findMatch(RawKeyEvent event) {
    for (KeyStrokeRep rep in widget.keyMap) {
      if (rep.matchesEvent(event)) {
        return rep;
      }
    }
    return null;
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
                  _hideOverlay();
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
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        alignment: Alignment.center,
                        width: 750, height: 36.0*rows+40,
                        decoration: BoxDecoration(color: const Color(0xDD2a2a2a),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: const [
                            BoxShadow(color: Color(0xDD2a2a2a), blurRadius: 50, spreadRadius: 5)
                          ]
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

          if (key == widget.showDismissKey) {
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
            );
          }
          else if (key == LogicalKeyboardKey.escape) {
            _hideOverlay();
          }
          else {
            KeyStrokeRep? rep = _findMatch(event);
            if (rep != null) {
              rep.callback();
            }
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


