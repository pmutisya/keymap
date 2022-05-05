import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keymap/keymap.dart';

///An example showing the keymap working with a dialog
///containing text fields.
void main() => runApp(
    const MaterialApp(title: 'Dialog Example',
        home: Material(child: TextFieldExample())));


class TextFieldExample extends StatefulWidget {
  const TextFieldExample({Key? key}) : super(key: key);

  @override
  State<TextFieldExample> createState() => _TextFieldExampleState();
}

class _TextFieldExampleState extends State<TextFieldExample> {
  late List<KeyAction> bindings;
  int count = 0;

  @override
  void initState() {
    super.initState();
    bindings = [
      KeyAction(LogicalKeyboardKey.keyD, 'open dialog', () {
        showDialog(context: context, builder: (context) {
          return const AlertDialog(content: Text('Hello, world'),);
        });
      }),
      KeyAction(LogicalKeyboardKey.keyA, 'Add 1', () {
        setState(() {
          count++;
        });
      },),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardWidget(bindings: bindings,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('The count is $count'),
            const TextField(decoration: InputDecoration(hintText: 'First Field'),),
            const TextField(decoration: InputDecoration(hintText: 'Second Field'),),
          ],
        ));
  }
}
