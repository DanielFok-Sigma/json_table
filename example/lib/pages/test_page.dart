import 'package:flutter/material.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
        Container(
          height: 100,
          color: Colors.red,
        ),
        Expanded(
          child: Container(
            color: Colors.blue,
          ),
        ),
        Container(
          height: 100,
          color: Colors.green,
        ),
      ],
    );
  }
}
