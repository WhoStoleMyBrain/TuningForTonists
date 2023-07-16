import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  final _bottomNavigationBarItems = {
    'Home':
        const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    'chat':
        const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'chat'),
    'Settings': const BottomNavigationBarItem(
        icon: Icon(Icons.settings), label: 'Settings'),
    'Info':
        const BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Info'),
  };

  var _index = 0;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: _bottomNavigationBarItems.values.toList(),
      onTap: (value) {
        print(value);
        print(_bottomNavigationBarItems.keys.toList()[value]);

        setState(() {
          _index = value;
          Navigator.of(context).pushReplacementNamed(
              _bottomNavigationBarItems.keys.toList()[value]);
        });
      },
    );
  }
}
