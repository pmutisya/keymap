import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    bindings = [
      KeyAction.fromString('I', 'Increase the counter',
        categoryHeader: 'Counter',
        () {
          setState(() {
            count++;
          }
        );
      }),
      KeyAction.fromString('5', 'Increase the counter by 5',
        isShiftPressed: true, isControlPressed: true,
        categoryHeader: 'Counter',
        () {
          setState(() {
            count+= 5;
          }
        );
      }),
      KeyAction.fromString('5', 'Decrease the counter by 5',
        isShiftPressed: true,
        categoryHeader: 'Counter',
        () {
          setState(() {
            count-=5;
          }
        );
      }),
      KeyAction.fromString('D', 'Decrease the counter',
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

      KeyAction.fromString('I', 'Increase',
        categoryHeader: 'Secondary Counter',
        () {
          setState(() {
            count++;
          }
        );
      }),
      KeyAction.fromString('5', 'Increase by 5',
        isShiftPressed: true, isControlPressed: true,
        categoryHeader: 'Secondary Counter',
        () {
          setState(() {
            count+= 5;
          }
        );
      }),
      KeyAction.fromString('5', 'Decrease by 5',
        isShiftPressed: true,
        categoryHeader: 'Secondary Counter',
        () {
          setState(() {
            count-=5;
          }
        );
      }),
      KeyAction.fromString('D', 'Decrease',
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
      showLines: true,
      groupByCategory: true,
        // columnCount: 2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text('The count is $count'),
        ],
      ));
  }
}
