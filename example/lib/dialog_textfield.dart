import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keymap/keymap.dart';

///An example showing the keymap working with a dialog
///containing text fields.
void main() => runApp(
  const MaterialApp(title: 'Dialog Example',
    home: Material(child: DialogExample())));


class DialogExample extends StatefulWidget {
  const DialogExample({Key? key}) : super(key: key);

  @override
  State<DialogExample> createState() => _DialogExampleState();
}

class _DialogExampleState extends State<DialogExample> {
  late List<KeyAction> bindings;
  int count = 0;

  @override
  void initState() {
    super.initState();
    bindings = [
      KeyAction(LogicalKeyboardKey.keyD, 'open dialog', () {
        _setEmailAndPassword();
      }),
      KeyAction(LogicalKeyboardKey.keyA, 'Add 1', () {
        setState(() {
          count++;
        });
      },),
    ];
  }

  Future<void> _setEmailAndPassword() async{
    showDialog(context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Enter email and password'),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  TextField(decoration: InputDecoration(hintText: 'Email'),),
                  TextField(decoration: InputDecoration(
                      hintText: 'Password'), obscureText: true,
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text('Log in'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardWidget(bindings: bindings,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('The count is $count'),
          Center(
            child: ElevatedButton(
              onPressed: () { _setEmailAndPassword();},
              child: const Text('show'),
            ),
          )
        ],
      ));
  }
}
