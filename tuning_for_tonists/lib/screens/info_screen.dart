import 'package:flutter/material.dart';
import 'package:tuning_for_tonists/widgets/bottom_nav_bar.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const Icon(Icons.key)),
      body: Center(
        child: Column(
          children: [Text.rich(TextSpan(text: 'Info Screen'))],
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}
