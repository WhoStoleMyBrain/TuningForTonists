import 'package:flutter/material.dart';

class FrequencyDisplay extends StatefulWidget {
  const FrequencyDisplay({super.key});

  @override
  State<FrequencyDisplay> createState() => _FrequencyDisplayState();
}

class _FrequencyDisplayState extends State<FrequencyDisplay> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [Text('frequency:')],
        ),
        CircularProgressIndicator(),
      ],
    );
  }
}
