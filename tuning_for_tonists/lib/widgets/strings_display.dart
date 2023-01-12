import 'package:flutter/material.dart';

class StringsDisplay extends StatefulWidget {
  const StringsDisplay({super.key});

  @override
  State<StringsDisplay> createState() => _StringsDisplayState();
}

class _StringsDisplayState extends State<StringsDisplay> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.1,
      child: Text('Strings Display'),
    );
  }
}
