import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Spotted extends StatefulWidget {
  const Spotted({super.key});

  @override
  State<Spotted> createState() => _SpottedState();
}

class _SpottedState extends State<Spotted> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SPOTTED"),
      ),
    );
  }
}
