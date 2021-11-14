import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:guess_me/src/screens/add_name_screen.dart';
import 'package:guess_me/src/services/cloud_function.dart';
import 'package:guess_me/src/services/facebook_stuff.dart';
import 'package:guess_me/src/services/firebase_stuff.dart';
import 'package:guess_me/src/services/firestore_stuff.dart';
import 'package:guess_me/src/style.dart';
import 'package:guess_me/src/widgets//sign_bottom.dart';
import 'package:guess_me/src/widgets/popup_rules.dart';
import 'package:guess_me/src/widgets/popup_user_details.dart';
import 'package:guess_me/src/widgets/screen.dart';
import 'package:guess_me/src/widgets/snackbar.dart';

import '../exceptions.dart';
import 'loading_screen.dart';

class SettingsScreen extends Screen {
  static IconData get icon => _SettingsScreenState.icon;

  static String get id => _SettingsScreenState.id;

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const String id = 'Settings';
  static const IconData icon = Icons.settings;
  final GlobalKey<ScaffoldState> globalKey = GlobalKey<ScaffoldState>();

  int blockedUsers = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: kTopAppColor,
        title: Text(
          id,
          style: TextStyle(
            color: kAppBarTextColor,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              FirebaseService.photoUrl == null
                  ? circleImage(
                      FirebaseService.clr,
                      FirebaseService.name,
                      size: 50.0)
                  : CircleAvatar(
                      backgroundImage: NetworkImage(FirebaseService.photoUrl),
                      backgroundColor: Colors.white,
                      radius: 50,
                    ),
              SizedBox(
                height: 20,
              ),
              Text(
                FirebaseService.name,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: kAppBarTextColor,
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                FirebaseService.phoneNumber,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: kAppBarTextColor.withOpacity(0.5),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ]),
          ]),
          SignBottom(
            text: FacebookService.isUser
                ? 'Sign in to ${FacebookService.name}'
                : 'Sign in with Facebook',
            icon: FontAwesomeIcons.facebookF,
            color: Color(0xFF3B5998),
            onPressed: FacebookService.isUser
                ? () {
                    Navigator.of(context).restorablePush(dialogBuilder);
                  }
                : () {
                    FacebookService.logInFacebook().onError(
                        (ErrorsExep error, StackTrace stackTrace) async {
                      showSnackBarWithText(context, text: error.cause);
                      await CloudFunction.onLogOut(context);
                    }).whenComplete(() => Navigator.of(context)
                        .pushNamedAndRemoveUntil(
                            LoadingScreen.id, (Route<dynamic> route) => false));
                  },
          ),
          Divider(
            color: kAnotherWidgetColor,
          ),
          SizedBox(height: 15),
          Container(
            height: 60,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: kBackgroundColor,
              ),
              onPressed: () async {
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(builder: (context) => SetNameScreen()),
                    )
                    .whenComplete(() => Navigator.pop(context));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        FirebaseService.name == '' ||
                                FirebaseService.name == null
                            ? 'Set Your Name'
                            : 'Enter Your Name',
                        style: TextStyle(
                          color: kAppBarTextColor,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        FirebaseService.name == '' ||
                                FirebaseService.name == null
                            ? 'Here You Can Edit Your Name'
                            : FirebaseService.name,
                        style: TextStyle(
                          color: kUnselectedColor,
                          fontSize: 13,
                        ),
                      )
                    ],
                  ),
                  Icon(
                    Icons.edit,
                    color: kAppBarTextColor,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(kAnotherWidgetColor),
            ),
            child: Text(
              'How it works?',
              style: TextStyle(
                color: kAppBarTextColor,
                fontSize: 17,
                decoration: TextDecoration.underline,
              ),
            ),
            onPressed: () =>
                Navigator.of(context).restorablePush(dialogRulesBuilder),
          ),
          SizedBox(
            height: 15,
          ),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(kAnotherWidgetColor),
            ),
            child: FutureBuilder(
              future: FireStoreService.blockedNum(FirebaseService.phoneNumber),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                TextStyle style = TextStyle(color: kAppBarTextColor);

                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Text(
                      'Release all blocked contacts',
                      style: style,
                    );
                  default:
                    if (snapshot.hasError) {
                      return Text(
                        'Release all blocked contacts',
                        style: style,
                      );
                    } else {
                      blockedUsers = snapshot.data;

                      return Text(
                        snapshot.data == 0
                            ? 'Release all blocked contacts'
                            : 'Release ${snapshot.data} blocked contact${snapshot.data > 1 ? 's' : ''}',
                        style: style,
                      );
                    }
                }
              },
            ),
            onPressed: () async {
              if (blockedUsers == 0)
                showSnackBarWithText(context, text: 'You have 0 blocked');
              else {
                await FireStoreService.blockedClear(
                    FirebaseService.phoneNumber);
                showSnackBarWithText(context,
                    text: 'Clear $blockedUsers blocked');
                Navigator.pop(context);
              }
            },
          ),
          SizedBox(height: 25),
          ElevatedButton(
              child: Text(
                'Log Out',
                style: TextStyle(color: kAnotherWidgetColor),
              ),
              onPressed: () {
                cntxt = context;
                Navigator.of(context).restorablePush(dialogLogOut);
              },
              style: ElevatedButton.styleFrom(
                primary: kWidgetColor,
              )),
          SizedBox(
            height: 5,
          ),
          ElevatedButton(
            child: Text(
              'Delete My Account',
              style: TextStyle(color: kAnotherWidgetColor),
            ),
            onPressed: () {
              cntxt = context;
              Navigator.of(context).restorablePush(dialogDelAccount);
            },
            style: ElevatedButton.styleFrom(
              primary: kWidgetColor,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Version 1.0',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: kAppBarTextColor.withOpacity(.2), fontSize: 15),
          ),
        ],
      ),
    );
  }
}
