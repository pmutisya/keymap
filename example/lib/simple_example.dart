import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:keymap/keymap.dart';

void main() => runApp(const MyApp());

///An example of using the Keymap widget to implement keyboard
///shortcuts
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String _title = 'keymap shortcut example';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Scaffold(
        appBar: AppBar(title: const Text(_title),),
        body: const Center(
          child: MyStatefulWidget(),
        ),
      ),
    );
  }
}

class IncrementIntent extends Intent {
  const IncrementIntent();
}

class DecrementIntent extends Intent {
  const DecrementIntent();
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {

  int count = 0;

  @override
  Widget build(BuildContext context) {
    return KeyboardWidget(
      bindings: [
        KeyAction(LogicalKeyboardKey.keyA,'increment the counter', () {
            setState(() {
              count++;
          });}, isControlPressed: true),
        KeyAction(LogicalKeyboardKey.keyD, 'decrement the counter', () {
          setState(() {
            count--;
          });
        }, isAltPressed: true, isControlPressed: true),
      ],
      child: Column(
        children: [
          const Text('Up arrow for adding, down arrow to subtract'),
          Text('count: $count'),
        ],
      ),
    );
  }
}
