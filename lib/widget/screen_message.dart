import 'package:flutter/material.dart';

class ScreenMessage extends StatelessWidget {
  final String message;

  ScreenMessage(this.message);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
      ),
    );
  }
}
