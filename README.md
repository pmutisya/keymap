# Keymap

A keymap widget letting a developer easily allow end users to use keyboard shortcuts
and an associated help screen overlay to any app.

This is pre-alpha and the API will probably change in the future.

## Getting started

[![pub package](https://img.shields.io/pub/v/keymap.svg)](https://pub.dev/packages/keymap)

```
dependencies:
  keymap: <latest-version>
```

## Features

- Easily add keyboard shortcuts to any widget tree
- Clear, readable help screen
- Allows rich text introductions with images using the Markdown format
- Handles focus, passing up unhandled key events
- Respects application theme colors and fonts

## Usage

Add a KeyMap widget to your tree in the build method
```dart
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
```

You can optionally set the number of columns for the text shown in the help screen

```dart
  @override
  Widget build(BuildContext context) {
    return KeyboardWidget(
      columnCount: 2,
      child: Scaffold(

```
This creates keyboard shortcuts that call the referenced methods and a help screen
that can be called up by pressing F1 (or any key you choose):

<p>
    <img src="https://raw.githubusercontent.com/pmutisya/keymap/main/doc/light_mode.png"/>
</p>

It will shift colors to match your app's theme (here in dark mode)

<p>
    <img src="https://raw.githubusercontent.com/pmutisya/keymap/main/doc/dark_mode.png"/>
</p>

You can add rich text (using Markdown format) above the keyboard map. A code sample
showing how to do this can be found in the examples directory

<p>
    <img src="https://raw.githubusercontent.com/pmutisya/keymap/main/doc/markdown.png"/>
</p>
