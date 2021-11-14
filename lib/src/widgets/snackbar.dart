import 'package:flutter/material.dart';

void showSnackBarWithText(BuildContext context, {String text}) {
  if (context == null) return;
  ScaffoldMessenger.of(context).hideCurrentSnackBar();

  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(
      text,
      textAlign: TextAlign.center,
    ),
    backgroundColor: Colors.black,
    behavior: SnackBarBehavior.floating,
    duration: Duration(milliseconds: 4000),
  ));
}
