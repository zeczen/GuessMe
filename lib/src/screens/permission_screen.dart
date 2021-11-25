import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:guess_me/src/exceptions.dart';
import 'package:guess_me/src/services/cloud_function.dart';
import 'package:guess_me/src/services/facebook_stuff.dart';
import 'package:guess_me/src/services/firestore_stuff.dart';
import 'package:guess_me/src/services/permission_stuff.dart';
import 'package:guess_me/src/services/shared_pref.dart';
import 'package:guess_me/src/style.dart';
import 'package:guess_me/src/widgets/snackbar.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/firebase_stuff.dart';
import '../widgets/sign_bottom.dart';
import 'loading_screen.dart';

class PermissionScreen extends StatefulWidget {
  static String get id => '/premisionsscreen';

  @override
  _PermissionScreenState createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  SharedPrefService secondStage = SharedPrefService("secondStage");
  SharedPrefService namePref = SharedPrefService("name");
  final globalKey = GlobalKey<ScaffoldState>();

  Future<bool> oldUser;
  bool granted = false;
  bool processing = false;
  bool pressedSkip = false;
  double theRalPart = 0; // how much processing passed
  DateTime startProcess;


  Future<void> getContacts() async {
    final PermissionStatus permissionS =
        await PermissionService.getPermission();
    if (permissionS == PermissionStatus.granted) {
      setState(() {
        granted = true;
        processing = true;
        // the soon we granted we start processing
      });
    }
    if (permissionS == PermissionStatus.denied) {
      throw AccessExep('DeniedError');
    }
    if (permissionS == PermissionStatus.permanentlyDenied) {
      throw AccessExep('PermanentlyDeniedError');
    }
    //we get here just when there is no exepsions
    return;
  }

  void nextScreen(BuildContext context) async {
    FirebaseService.phoneNumber = await SharedPrefService('phoneNumber').value;

    await secondStage.setValue(true);
    FirebaseService.name = await FireStoreService.getProp(
        FirebaseService.phoneNumber, FireStoreService.NAME);
    if (FirebaseService.name != null)
      await namePref.setValue(FirebaseService.name);
    Navigator.of(context).pushNamedAndRemoveUntil(
        LoadingScreen.id, (Route<dynamic> route) => false);
  }

  Future<void> tryGoNextPage(context) async {
    //this function check if we done with the screen and we can go to the next one (loading => mainScreen)
    setState(() {
      pressedSkip = true;
    });

    if (!granted) {
      start();
      return;
    } else if (!processing) {
      // call to the navigator
      nextScreen(context);
    }
  }

  void start() async {
    try {
      await getContacts();
      //now we continue without Errors

      int howManyPass = 0;
      setState(() => processing = true);
      int len = (await PermissionService.getContacts()).length;
      oldUser =
          FireStoreService.isPhoneUserAlreadyExist(FirebaseService.phoneNumber);
      FireStoreService.whenUserLogInPhoneNumber(FirebaseService
          .phoneNumber); // create the user documents if its not exist yet
      CloudFunction.whenUserLog().listen((int pass) {
        //pass is how many contacts pass => pass/len is the absolute fraction
        if (!pressedSkip)
          howManyPass++; // while is not load the howmanypast equal to pass
        else {
          startProcess = startProcess ?? DateTime.now();
          // startProcess is the time when the loading begin
          setState(() {
            theRalPart = (pass - howManyPass) / (len - howManyPass);
          });
        }
      }).onDone(() {
        setState(() {
          processing = false;
        });
        if (pressedSkip) tryGoNextPage(context);
      });

    } on AccessExep catch (e) {
      setState(() {
        granted = false;
      });
      if (e.cause == "DeniedError")
        showSnackBarWithText(context,
            text: 'You need to allow access to contacts to continue');
      else if (e.cause == "PermanentlyDeniedError")
        showSnackBarWithText(context,
            text: 'You need to allow access to contacts in your settings');
    } on ConnectionExep catch (e) {
      if (e.cause == "ConnectionError")
        showSnackBarWithText(context,
            text:
                'You may have some connection errors, try to connect to wifi network and try again');
    } catch (e) {
      showSnackBarWithText(context,
          text: 'there are some problems, try to close the app and try again');
    }
  }

  String timeLeft() {
    // some math
    int microSec = ((DateTime.now()).difference(startProcess)).inMilliseconds;
    int timeSum = (microSec / theRalPart).round();
    return ((timeSum - microSec).round() / 1000).toString();
  }

  @override
  void initState() {
    super.initState();
    start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      backgroundColor: kBackgroundColor,
      body: pressedSkip && processing && granted
          ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Loading',
                    style: TextStyle(fontSize: 35, color: kAppBarTextColor),
                  ),
                  SizedBox(height: 50),
                  LinearProgressIndicator(
                    minHeight: 12,
                    value: theRalPart,
                  ),
                  SizedBox(height: 20),
                  Text(
                    theRalPart == 0 ? '' : 'estimated time: ${timeLeft()} sec',
                    style: TextStyle(
                      color: kAppBarTextColor,
                      fontSize: 15.5,
                    ),
                  )
                ],
              ),
            )
          : Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    'Sign in With Your Facebook Account is Helping To You find Your Friends',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: kSelectedColor,
                      fontSize: 17.0,
                    ),
                  ),
                  SignBottom(
                    text: FacebookService.isUser
                        ? 'You connect to ${FacebookService.name}'
                        : 'Sign in with Facebook',
                    icon: FontAwesomeIcons.facebookF,
                    color: Color(0xFF3B5998),
                    onPressed: FacebookService.isUser
                        ? () {}
                        : () {
                            FacebookService.logInFacebook()
                                .onError((error, StackTrace stackTrace) =>
                                    showSnackBarWithText(context,
                                        text: error.cause))
                                .whenComplete(() => tryGoNextPage(context));
                          },
                  ),
                  TextButton(
                    onPressed: () async {
                      tryGoNextPage(context);
                    },
                    child: Text(
                      'Skip',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: kSelectedColor,
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
