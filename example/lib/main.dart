import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keymap/keymap.dart';

///This example shows how to use the keymap by
///inserting a KeyMap and related functions to the standard
///Flutter counter app. It adds a global key to let the user
///call up the help screen with a button in the app bar.
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
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.purple,
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
  //used by the help icon button in the AppBar
  late GlobalKey<KeyboardWidgetState> _key;
  int _counter = 0;
  //The shortcuts used by the KeyMap
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
      _counter += amount;
    });
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
    });
  }

  //each shortcut is defined by the key pressed, the method called and a
  //human-readable description. You can optionally add modifiers like control,
  //alt, etc.
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
      KeyAction(LogicalKeyboardKey.delete,'round down (by 10s)',
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
          }, isShiftPressed: true
      ),
      KeyAction(LogicalKeyboardKey.keyD, 'Divide by 10',
          () {
            setState(() {
              _counter = _counter~/10;
            });
          },
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    //the KeyBoardWidget is at the root of the app so that
    //all key-presses are registered
    return KeyboardWidget(
      key: _key,
      showDismissKey: LogicalKeyboardKey.f2,
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

}
