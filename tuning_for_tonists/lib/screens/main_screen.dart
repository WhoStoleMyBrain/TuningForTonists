import 'package:flutter/material.dart';
import 'package:tuning_for_tonists/widgets/bottom_nav_bar.dart';
import 'package:tuning_for_tonists/widgets/frequency_display.dart';
import 'package:tuning_for_tonists/widgets/strings_display.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const Icon(Icons.key)),
      bottomNavigationBar: BottomNavBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: const [
          FrequencyDisplay(),
          StringsDisplay(),
        ],
      ),
    );
  }
}
