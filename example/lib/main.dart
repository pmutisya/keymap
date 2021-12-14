import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keymap/keymap.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _decrementCounter() {
    setState(() {
      _counter--;
    });
  }

  void increaseBy(int amount) {
    setState(() {
      _counter += 10;
    });
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<KeyStrokeRep> shortcuts = [
      KeyStrokeRep(LogicalKeyboardKey.keyI,'increment the counter', () => _incrementCounter(),),
      KeyStrokeRep(LogicalKeyboardKey.keyD, 'decrement the counter', () => _decrementCounter(),
        isShiftPressed: true, isAltPressed: true),
      KeyStrokeRep(LogicalKeyboardKey.enter,'increase by 10',
        (){ increaseBy(10); },
        isControlPressed: true),
      KeyStrokeRep(LogicalKeyboardKey.keyR,'reset the counter ',
        (){ _resetCounter();},
        isMetaPressed: true),
      KeyStrokeRep(LogicalKeyboardKey.keyM, 'multiply by 10',
          () {
            setState(() {
              _counter = _counter*10;
            });
          }
      )
    ];

    return KeyboardWidget(
      keyMap: shortcuts, columnCount: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'You have pushed the button this many times:',
              ),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.headline4,
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _incrementCounter,
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      )
    );
  }
}
