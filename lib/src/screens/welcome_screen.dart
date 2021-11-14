import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:guess_me/src/style.dart';

import '../style.dart';
import 'sign_in_phone_screen.dart';

class WelcomeScreen extends StatefulWidget {
  static String get id => '/welcomeScreen';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Padding(
        padding: EdgeInsets.only(
          top: 74,
          bottom: 36,
          left: 23,
          right: 23,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'GuessMe',
              style: TextStyle(
                color: kAppBarTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 27,
              ),
            ),
            Image.asset(
              "images/logo.png",
              fit: BoxFit.fitWidth,
              width: 220.0,
              alignment: Alignment.bottomCenter,
            ),
            Text(
              'Click To Sign In',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: kAppBarTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 27,
              ),
            ),
            Container(
              height: 47,
              child: ElevatedButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Get Started',
                      style: TextStyle(fontSize: 17),
                    ),
                    Icon(
                      Icons.arrow_forward,
                      size: 25,
                    ),
                  ],
                ),
                onPressed: () async {
                  Navigator.pushNamed(context, SignInScreen.id)
                      .then((value) {});
                },
                style: ElevatedButton.styleFrom(
                  primary: kAnotherWidgetColor, // background
                  onPrimary: Colors.black, // foreground
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
