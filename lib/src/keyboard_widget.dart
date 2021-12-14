import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

///A combination of a (e.g., control-shift-A), a description
///of what action that keystroke should trigger (e.g., "select all text"),
///and a callback method to be invoked.
@immutable
class KeyStrokeRep {
  final SingleActivator keyActivator;
  final String description;
  final VoidCallback callback;

  ///Creates a KeystrokeRep with the given LogicalKeyboardKey [keyStroke],
  ///[description] and [callback] method. Includes optional bool values (defaulting
  ///to false) for key modifiers for meta [isMetaPressed], shift [isShiftPressed],
  ///alt [isAltPressed]
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
  final int columnCount;
  final bool showMap;

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
  ///
  const KeyboardWidget({Key? key, required this.keyMap, this.hasFocus = false,
    required this.child, this.showDismissKey=LogicalKeyboardKey.f1, this.columnCount = 1,
    this.showMap = false,
  }) :
    assert (columnCount > 0),
    super(key: key)
  ;

  @override
  _KeyboardWidgetState createState() => _KeyboardWidgetState();

}

class _KeyboardWidgetState extends State<KeyboardWidget> {
  late FocusNode _focusNode;
  late OverlayEntry _overlayEntry;
  late bool showingOverlay;

  static const TextStyle _whiteStyle = TextStyle(color: Colors.white, fontSize: 12);
  // static const TextStyle _boldStyle = TextStyle(color: Colors.white, fontWeight: FontWeight.bold);
  static const TextStyle _blackStyle = TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.normal);

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
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
  //returns a white rounded-rect surrounded with black text
  Widget _getBubble(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
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
        decoration: BoxDecoration(border: Border.all(color: Colors.red)),
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

  static const double horizontalMargin = 16.0;
  // static const double rowHeight = 40.0;

  OverlayEntry _buildOverlay() {
    // List<Widget> shortcuts = [];
    // for (KeyStrokeRep keyEvent in widget.keyMap) {
    //   String description = keyEvent.description;
    //   String modifier = _getModifiers(keyEvent);
    //   shortcuts.add(_getShortcutWidget(keyEvent.label, description, modifiers: modifier));
    // }

    MediaQueryData media = MediaQuery.of(context);
    Size size = media.size;
    int length = widget.keyMap.length;

    int rowCount = (length/widget.columnCount).ceil();
    print('${widget.keyMap.length} items in ${widget.columnCount} columnrs => ROWCOUNT: $rowCount');
    List<List<DataCell>> tableRows = [];
    for (int k = 0; k < rowCount; k++) {
      print('\t$k');
      tableRows.add(<DataCell>[]);
    }
    print('ROWLEN a:: ${tableRows.length}');
    List<DataColumn> columns = [];
    for (int k = 0; k < widget.columnCount; k++) {
      columns.add(const DataColumn(label: Text('mod')));
      columns.add(const DataColumn(label: Text('k')));
      columns.add(const DataColumn(label: Text('desc')));
    }
    int fullRows = widget.keyMap.length~/widget.columnCount;
    print('$fullRows FULL ROWS');
    for (int k = 0; k < fullRows; k+= widget.columnCount) {
      List<DataCell> dataRow = tableRows[k];
      for (int t = 0; t < widget.columnCount; t++) {
        KeyStrokeRep rep = widget.keyMap[k*widget.columnCount+t];
        String modifiers = _getModifiers(rep);
        dataRow.add(modifiers.isNotEmpty? DataCell(_getBubble(modifiers)) : DataCell.empty);
        dataRow.add(DataCell(_getBubble(rep.label)));
        dataRow.add(DataCell(Text(rep.description, overflow: TextOverflow.ellipsis, style: _whiteStyle,)));
      }
    }
    List<DataCell> dataRow = tableRows[fullRows];
    for (int k = fullRows*widget.columnCount; k < widget.keyMap.length; k++){
      KeyStrokeRep rep = widget.keyMap[k];
      String modifiers = _getModifiers(rep);
      dataRow.add(modifiers.isNotEmpty? DataCell(_getBubble(modifiers)) : DataCell.empty);
      dataRow.add(DataCell(_getBubble(rep.label)));
      dataRow.add(DataCell(Text(rep.description, overflow: TextOverflow.ellipsis, style: _whiteStyle,)));
    }
    for (int k = widget.keyMap.length; k < rowCount*widget.columnCount; k++) {
      dataRow.add(DataCell.empty);
      dataRow.add(DataCell.empty);
      dataRow.add(DataCell.empty);
    }

    print('COLS: ${columns.length}');
    print('ROWS: ${rowCount}');
    print('ROWLEN:: ${tableRows.length}');
    for (int k = 0; k < rowCount; k++) {
      print('ROW $k::${tableRows[k].length}');
    }

    // for (KeyStrokeRep keyStrokeRep in widget.keyMap) {
    //   String modifiers = _getModifiers(keyStrokeRep);
    //
    //   DataCell modifierCell = modifiers.isNotEmpty? DataCell(_getBubble(modifiers)) : DataCell.empty;
    //   DataRow row = DataRow(cells: [
    //     modifierCell,
    //     DataCell(_getBubble(keyStrokeRep.label)),
    //     DataCell(Text(keyStrokeRep.description, overflow: TextOverflow.ellipsis, style: _whiteStyle,))
    //   ]);
    //   tableRows.add(row);
    // }
    List<DataRow> rows = [];
    for (List<DataCell> cells in tableRows) {
      rows.add(DataRow(cells: cells));
    }
    print('COLUMNS:: ${columns.length}');
    for (DataRow row in rows) {
      print('\tROW: ${row.cells.length}');
    }
    Widget grid = Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.red, //const Color(0x11777777),
      ),
      child: DataTable(
        headingRowColor: MaterialStateColor.resolveWith((states) => Colors.white),
        border: TableBorder.all(color: Colors.yellow),
        decoration: BoxDecoration(color: const Color(0xFF0a0a0a),
            border: Border.all(color: const Color(0xFF0a0a0a), width: 18),
            borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(color: Color(0xDE2a2a2a), blurRadius: 50, spreadRadius: 5)
          ]
        ),
        dividerThickness: 1,
        columns: columns,
        rows: rows, dataRowHeight: 32, headingRowHeight: 32,
      )
    );

    // Widget grid2 = GridView.count(
    //   scrollDirection: Axis.vertical,
    //   crossAxisCount: widget.columnCount, children: shortcuts,
    //   childAspectRatio: (size.width - horizontalMargin*2)/widget.columnCount/rowHeight,
    //   shrinkWrap: true,);
    return OverlayEntry(
        builder: (context) {
          // EdgeInsets padding = MediaQuery.of(context).padding;
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
      // return LayoutBuilder(
      //     builder:(context, constraints) {
            FocusScope.of(context).requestFocus(_focusNode);
            return _getKeyboardListener(context);
          // }
      // );
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
            });
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


