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
  late GlobalKey<KeyboardWidgetState> _key;
  int _counter = 0;
  late List<KeyAction> shortcuts;

  @override
  void initState() {
    super.initState();
    _key = GlobalKey();
    shortcuts = _getShortcuts();
  }
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
    return KeyboardWidget(
      key: _key,
      keyMap: shortcuts, columnCount: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            Tooltip(message: 'Show keyboard shortcuts',
             child: IconButton(icon: const Icon(Icons.help_outline), onPressed: () {
              _key.currentState?.toggleOverlay();
            },)),
          ],
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

  List<KeyAction> _getShortcuts() {
    return [
      KeyAction(LogicalKeyboardKey.keyI,'increment the counter', _incrementCounter,),
      KeyAction(LogicalKeyboardKey.keyD, 'decrement the counter', _decrementCounter,
          isAltPressed: true, isControlPressed: true),
      KeyAction(LogicalKeyboardKey.enter,'increase by 10',
              (){ increaseBy(10); },
          isControlPressed: true
      ),
      KeyAction(LogicalKeyboardKey.arrowUp,'increase by 5',
              (){ increaseBy(5); },
          isAltPressed: true
      ),
      KeyAction(LogicalKeyboardKey.arrowDown,'decrease by 5',
              (){ increaseBy(-5); },
          isAltPressed: true
      ),
      KeyAction(LogicalKeyboardKey.keyR,'reset the counter ',
              (){ _resetCounter();},
          isMetaPressed: true
      ),
      KeyAction(LogicalKeyboardKey.enter,'reset the counter ',
              (){ _resetCounter();},
          isShiftPressed: true
      ),
      KeyAction(LogicalKeyboardKey.delete,'round down ',
              (){
            setState(() {
              _counter = _counter~/10;
            });
          },
          isShiftPressed: true
      ),
      KeyAction(LogicalKeyboardKey.keyM, 'multiply by 10',
              () {
            setState(() {
              _counter = _counter*10;
            });
          }
      )
    ];
  }
}
