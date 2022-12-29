import 'package:flutter/material.dart';
import 'package:tuning_for_tonists/widgets/bottom_nav_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const Icon(Icons.key)),
      body: Center(
        child: Column(
          children: [Text('SETTINGS')],
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}
