import 'package:flutter/material.dart';

extension ContextUtils on BuildContext {
  double get height => MediaQuery.of(this).size.height;

  double get width => MediaQuery.of(this).size.width;

  void showToast(String text, {bool negative = true}) {
    final snackBar = SnackBar(
      content: Text(text),
      backgroundColor: negative ? Colors.red : Colors.green,
    );
    ScaffoldMessenger.of(this).showSnackBar(snackBar);
  }
}
