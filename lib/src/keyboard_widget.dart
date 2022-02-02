import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

///A combination of a [LogicalKeyboardKey] (e.g., control-shift-A), a description
///of what action that keystroke should trigger (e.g., "select all text"),
///and a callback method to be invoked when that keystroke is pressed.
@immutable
class KeyAction {
  final SingleActivator keyActivator;
  final String description;
  final VoidCallback callback;

  ///Creates a KeystrokeRep with the given LogicalKeyboardKey [keyStroke],
  ///[description] and [callback] method. Includes optional bool values (defaulting
  ///to false) for key modifiers for meta [isMetaPressed], shift [isShiftPressed],
  ///alt [isAltPressed]
  KeyAction(LogicalKeyboardKey keyStroke, this.description, this.callback,
      {bool isControlPressed = false, bool isMetaPressed = false, bool isShiftPressed = false, bool isAltPressed = false}):
      keyActivator = SingleActivator(keyStroke, control: isControlPressed, shift: isShiftPressed, alt: isAltPressed, meta: isMetaPressed);

  bool get isControlPressed => keyActivator.control;
  bool get isMetaPressed => keyActivator.meta;
  bool get isShiftPressed => keyActivator.shift;
  bool get isAltPressed => keyActivator.alt;

  String get label {
    LogicalKeyboardKey key = keyActivator.trigger;
    String label = keyActivator.trigger.keyLabel;
    if (key == LogicalKeyboardKey.arrowRight) {
      if (kIsWeb) {
        label = 'arrow right';
      }
      else {
        label = '\u2192';
      }
    }
    else if (key == LogicalKeyboardKey.arrowLeft) {
      if (kIsWeb) {
        label = 'arrow left';
      }
      else {
        label = '\u2190';
      }
    }
    else if (key == LogicalKeyboardKey.arrowUp) {
      if (kIsWeb) {
        label = 'arrow up';
      }
      else {
        label = '\u2191';
      }
    }
    else if (key == LogicalKeyboardKey.arrowDown) {
      if (kIsWeb) {
        label = 'arrow down';
      }
      else {
        label = '\u2193';
      }
    }
    else if (key == LogicalKeyboardKey.delete) {
      if (kIsWeb) {
        label = 'delete';
      }
      else {
        label = '\u232B';
      }
    }
    else if (key == LogicalKeyboardKey.enter) {
      if (kIsWeb) {
        label = 'enter';
      }
      else {
        label = '\u2B90';
      }
    }
    return label;
  }

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
  final List<KeyAction> keyMap;
  final LogicalKeyboardKey showDismissKey;
  final int columnCount;
  final bool showMap;
  final VoidCallback? callbackOnHide;

  /// Creates a new KeyboardWidget with a list of Keystrokes and associated
  /// functions [keyMap], a required [child] widget and an optional
  /// keystroke to show and dismiss the displayed map, [showDismissKey].
  ///
  /// The number of columns used to display the options can be optionally
  /// chosen. It defaults to one column.
  ///
  /// By default the F1 keyboard key is used to show and dismiss the keymap
  /// display. If another key is preferred, set the [showDismissKey] to another
  /// [LogicalKeyboardKey].
  ///
  /// If the help map should be displayed, set the parameter [showMap] to true.
  /// This lets the implementer programmatically show the map.
  /// You would usually pair this with a function [callbackOnHide] so that the caller
  /// to show the help screen can be notified when it is hidden
  ///
  const KeyboardWidget({Key? key, required this.keyMap, this.hasFocus = false,
    required this.child, this.showDismissKey=LogicalKeyboardKey.f1, this.columnCount = 1,
    this.showMap = false, this.callbackOnHide,
  }) :
    assert (columnCount > 0),
    super(key: key)
  ;

  @override
  KeyboardWidgetState createState() => KeyboardWidgetState();

}

class KeyboardWidgetState extends State<KeyboardWidget> {
  late FocusNode _focusNode;
  late OverlayEntry _overlayEntry;
  late bool showingOverlay;


  static const Color background = Color(0xFF0a0a0a);
  static const Color shadow = Color(0xaa000000);
  static const Color text = Colors.white;

  static const TextStyle _textStyle = TextStyle(color: text, fontSize: 12);

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.requestFocus();
    showingOverlay = widget.showMap;
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
  //returns text surrounded with a rounded-rect
  Widget _getBubble(String text, Color color, Color color2, {bool invert = false}) {
    // bool isDark = background.computeLuminance() < .5;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(
        color: invert? color : color2,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color)
      ),
      child: Text(text, style: _textStyle.copyWith(color: invert? color2 : color)), //isDark? _whiteStyle :_blackStyle,),
    );
  }

  //returns the modifier key as text or a symbol (where possible)
  String _getModifiers(KeyAction rep) {
    StringBuffer buffer = StringBuffer();
    if(rep.isMetaPressed) {
      //Platform operating system is not available in the web platform
      if (!kIsWeb && Platform.isMacOS) {
        buffer.write('⌘');
      }
      else {
        buffer.write('meta ');
      }
    }
    if (rep.isShiftPressed) {
      if (kIsWeb) {
        buffer.write('shift ');
      }
      else {
        buffer.write('⇧');
      }
    }
    if (rep.isControlPressed) {
      if (!kIsWeb && Platform.isMacOS) {
        buffer.write('⌃');
      }
      else {
        buffer.write('ctrl ');
      }
    }
    if (rep.isAltPressed) {
      if (!kIsWeb && Platform.isMacOS) {
        buffer.write('⌥');
      }
      else {
        buffer.write('alt ');
      }
    }
    if (kIsWeb || !Platform.isMacOS) {
      return buffer.toString().trimRight();
    }
    else {
      return buffer.toString();
    }
  }

  KeyAction? _findMatch(RawKeyEvent event) {
    for (KeyAction rep in widget.keyMap) {
      if (rep.matchesEvent(event)) {
        return rep;
      }
    }
    return null;
  }

  static const double horizontalMargin = 16.0;

  OverlayEntry _buildOverlay() {

    MediaQueryData media = MediaQuery.of(context);
    Size size = media.size;
    int length = widget.keyMap.length;

    int rowCount = (length/widget.columnCount).ceil();
    List<List<DataCell>> tableRows = [];
    for (int k = 0; k < rowCount; k++) {
      tableRows.add(<DataCell>[]);
    }
    List<DataColumn> columns = [];
    for (int k = 0; k < widget.columnCount; k++) {
      columns.add(const DataColumn(label: Text('m'), numeric: true));
      columns.add(const DataColumn(label: Text('k')));
      columns.add(const DataColumn(label: Text('d')));
    }
    int fullRows = widget.keyMap.length~/widget.columnCount;
    for (int k = 0; k < fullRows; k++) {
      List<DataCell> dataRow = tableRows[k];
      for (int t = 0; t < widget.columnCount; t++) {
        KeyAction rep = widget.keyMap[k*widget.columnCount+t];
        String modifiers = _getModifiers(rep);
        dataRow.add(modifiers.isNotEmpty? DataCell(_getBubble(modifiers, text,
          background, invert: true)) : DataCell.empty);
        dataRow.add(DataCell(_getBubble(rep.label, text, background)));
        dataRow.add(DataCell(Container(
          margin: const EdgeInsets.only(right: 32),
          child: Text(rep.description, overflow: TextOverflow.ellipsis, style: _textStyle,))));
      }
    }
    if (widget.keyMap.length%widget.columnCount != 0) {
      List<DataCell> dataRow = tableRows[fullRows];
      for (int k = fullRows * widget.columnCount; k <
          widget.keyMap.length; k++) {
        KeyAction rep = widget.keyMap[k];
        String modifiers = _getModifiers(rep);
        dataRow.add(
            modifiers.isNotEmpty ? DataCell(_getBubble(modifiers, text, background)) : DataCell
                .empty);
        dataRow.add(DataCell(_getBubble(rep.label, text, background)));
        dataRow.add(DataCell(Text(
          rep.description, overflow: TextOverflow.ellipsis,
          style: _textStyle,)));
      }
      for (int k = widget.keyMap.length; k <
          rowCount * widget.columnCount; k++) {
        dataRow.add(DataCell.empty);
        dataRow.add(DataCell.empty);
        dataRow.add(DataCell.empty);
      }
    }
    List<DataRow> rows = [];
    for (List<DataCell> cells in tableRows) {
      rows.add(DataRow(cells: cells));
    }

    Widget grid = Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent, //const Color(0x11777777),
      ),
      child: DataTable(
        columnSpacing: 6,
        decoration: BoxDecoration(color: background,
            border: Border.all(color: background, width: 18),
            borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(color: shadow, blurRadius: 50, spreadRadius: 5)
          ]
        ),
        dividerThickness: 1,
        columns: columns,
        rows: rows, dataRowHeight: 44, headingRowHeight: 0,
      )
    );

    return OverlayEntry(
        builder: (context) {
          return Positioned(
              child: GestureDetector(
                onTap: () {
                  _hideOverlay();
                },
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(horizontalMargin),
                  width: size.width, // - padding.left - padding.right - 40,
                  height: size.height, // - padding.top - padding.bottom - 40,
                  decoration: const BoxDecoration(
                    color: Colors.black26,
                  ),
                  child: Material(
                      color: Colors.transparent,
                      child: Center(child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                        alignment: Alignment.center,
                        // width: boxWidth,
                        // height: rowHeight*rows+horizontalMargin*2,
                        // decoration: BoxDecoration(color: const Color(0xDD2a2a2a),
                        //   borderRadius: BorderRadius.circular(18),
                        //   boxShadow: const [
                        //     BoxShadow(color: Color(0xDD2a2a2a), blurRadius: 50, spreadRadius: 5)
                        //   ]
                        // ),
                        child: grid,
                        // child:const Text('OVERLAY', style: TextStyle(color: Colors.white),)
                      )
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
          FocusScope.of(context).requestFocus(_focusNode);
          return _getKeyboardListener(context);
    }
    else {
      return widget.child;
    }

  }
  Widget _getKeyboardListener(BuildContext context) {
    return Focus(
      child: widget.child,
      focusNode: _focusNode,
      autofocus: widget.hasFocus,
      onKey: (FocusNode node, RawKeyEvent event) {
        if (event.runtimeType == RawKeyUpEvent) {
          LogicalKeyboardKey key = event.logicalKey;

          if (key == widget.showDismissKey) {
            toggleOverlay();
            return KeyEventResult.handled;
          }
          else if (key == LogicalKeyboardKey.escape) {
            if (showingOverlay) {
              _hideOverlay();
            }
            return KeyEventResult.handled;
          }
          else {
            KeyAction? rep = _findMatch(event);
            if (rep != null) {
              rep.callback();
              return KeyEventResult.handled;
            }
            else {
              return KeyEventResult.ignored;
            }
          }
        }
        return KeyEventResult.ignored;
      },);
  }
  void toggleOverlay() {
    setState(() {
      if (!showingOverlay) {
        showingOverlay = true;
        _overlayEntry = _buildOverlay();
        Overlay.of(context)!.insert(_overlayEntry);
      }
      else {
        if (showingOverlay) {
          _hideOverlay();
        }
      }
    });
  }
  void _hideOverlay() {
    setState(() {
      showingOverlay = false;
      _overlayEntry.remove();
      // if (widget.callbackOnHide != null) {
      //   widget.callbackOnHide!();
      // }
    });
  }
}


