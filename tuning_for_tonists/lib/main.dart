import 'package:flutter/material.dart';
import 'package:tuning_for_tonists/screens/info_screen.dart';
import 'package:tuning_for_tonists/screens/main_screen.dart';
import 'package:tuning_for_tonists/screens/settings_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        'Home': (context) => const MainScreen(),
        // When navigating to the "/second" route, build the SecondScreen widget.
        'Settings': (context) => const SettingsScreen(),
        'Info': (context) => const InfoScreen(),
      },
      home: const MainScreen(),
    );
  }
}
