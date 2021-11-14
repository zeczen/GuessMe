 import 'package:flutter/material.dart';
import 'package:guess_me/src/services/cloud_function.dart';

Color kBackgroundColor = Color(0xFF282B54);
Color kBackgroundColorShade = Colors.black;

Color kTopAppColor = Color(0xFF2E3562);
Color kAppBarTextColor = Colors.white;

Color kWidgetColor = Color(0xFF3C4379);
Color kAnotherWidgetColor = Color(0xFFFD8F68);

Color kSelectedColor = Color(0xFF039ED6);
Color kUnselectedColor = Color(0xFF4B5382);

FontWeight kSelectedBottomNavigatorWeight = FontWeight.w900;

const int kSecondsUntilSMSTimeOut = 15;
Duration kAnimationTime = Duration(seconds: 1);

Widget circleImage(int clr, String name, {double size = 20}) {
  String acronymsName = CloudFunction.formatName(name);
  return CircleAvatar(
    backgroundColor: Color(clr),
    foregroundColor: Color(clr),
    child: Text(
      acronymsName,
      style: TextStyle(fontSize: size * 0.8, color: kAppBarTextColor),
    ),
    radius: size,
  );
}
