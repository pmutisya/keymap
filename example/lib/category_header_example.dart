import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keymap/keymap.dart';

void main() => runApp(
  const MaterialApp(title: 'Categories Example',
    home: Material(child: CategoryHeaderExample(),),
  )
);


class CategoryHeaderExample extends StatefulWidget {
  const CategoryHeaderExample({super.key});

  @override
  State<CategoryHeaderExample> createState() => _CategoryHeaderExampleState();
}

class _CategoryHeaderExampleState extends State<CategoryHeaderExample> {
  int count = 0;
  late List<KeyAction> bindings;
  bool showCategories = true;
  bool showLines = false;

  @override
  void initState() {
    super.initState();
    bindings = [
      KeyAction.fromString('I', 'Increase',
        categoryHeader: 'Counter',
        () {
          setState(() {
            count++;
          }
        );
      }),
      KeyAction.fromString('5', 'Increase by 5',
        isShiftPressed: true, isControlPressed: true,
        categoryHeader: 'Counter',
        () {
          setState(() {
            count+= 5;
          }
        );
      }),
      KeyAction.fromString('5', 'Decrease by 5',
        isShiftPressed: true,
        categoryHeader: 'Counter',
        () {
          setState(() {
            count-=5;
          }
        );
      }),
      KeyAction.fromString('D', 'Decrease',
        categoryHeader: 'Counter',
        () { setState(() {
          count--;
        });
      }),

      KeyAction.fromString('A', 'About dialog',
          isShiftPressed: true,
          categoryHeader: 'Information',
              () {
            showAboutDialog(context: context);
          }
      ),
      KeyAction.fromString('R', 'Random dialog',
          categoryHeader: 'Information',
              () {
            showAboutDialog(context: context);
          }
      ),

      KeyAction(LogicalKeyboardKey.arrowUp, 'Increase',
        categoryHeader: 'Secondary Counter',
        () {
          setState(() {
            count++;
          }
        );
      }),
      KeyAction(LogicalKeyboardKey.arrowUp, 'Increase by 5',
        isShiftPressed: true, isControlPressed: true,
        categoryHeader: 'Secondary Counter',
        () {
          setState(() {
            count+= 5;
          }
        );
      }),
      KeyAction(LogicalKeyboardKey.arrowDown, 'Decrease by 5',
        isShiftPressed: true,
        categoryHeader: 'Secondary Counter',
        () {
          setState(() {
            count-=5;
          }
        );
      }),
      KeyAction(LogicalKeyboardKey.arrowDown, 'Decrease',
        categoryHeader: 'Secondary Counter',
        () { setState(() {
          count--;
        });
      }),
    ];
  }
  @override
  Widget build(BuildContext context) {
    return KeyboardWidget(bindings: bindings,
      showLines: showLines,
      groupByCategory: showCategories,
        // columnCount: 2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text('The count is $count'),
          SwitchListTile(
            controlAffinity: ListTileControlAffinity.leading,
            value: showCategories,
            visualDensity: VisualDensity.compact,
            title: const Text('Show categories'),
            onChanged: (selected){
              setState(() {
                showCategories = selected;
              });
          }),
          SwitchListTile(
            controlAffinity: ListTileControlAffinity.leading,
            value: showLines,
            visualDensity: VisualDensity.compact,
            title: const Text('Show lines'),
            onChanged: (selected){
              setState(() {
                showLines = selected;
              });
          }),
        ],
      ));
  }
}
