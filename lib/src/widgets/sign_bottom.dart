import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_builder.dart';

class SignBottom extends StatelessWidget {
  SignBottom({this.text, this.icon, this.onPressed, this.color, this.width});

  final String text;
  final IconData icon;
  final Function onPressed;
  final Color color;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: width,
      margin: EdgeInsets.symmetric(vertical: 15),
      child: SignInButtonBuilder(
        innerPadding: EdgeInsets.fromLTRB(12, 0, 11, 0),
        elevation: 2.0,
        mini: false,
        text: text,
        backgroundColor: color,
        icon: icon,
        onPressed: onPressed,
      ),
    );
  }
}
