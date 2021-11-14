import 'dart:async';

import 'package:flutter/material.dart';
import 'package:guess_me/src/services/cloud_function.dart';
import 'package:guess_me/src/services/firebase_stuff.dart';
import 'package:guess_me/src/services/firestore_stuff.dart';
import 'package:guess_me/src/services/permission_stuff.dart';
import 'package:guess_me/src/services/shared_pref.dart';
import 'package:permission_handler/permission_handler.dart';

import '../style.dart';
import 'add_name_screen.dart';
import 'master_screen.dart';
import 'permission_screen.dart';
import 'welcome_screen.dart';

class LoadingScreen extends StatefulWidget {
  LoadingScreen(this.appOpen);

  final bool appOpen;

  static String get id => '/loadingScreen';

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final Widget loading = Scaffold(
    backgroundColor: kBackgroundColor,
    body: Center(
      child: Text(
        'GuessMe',
        style: TextStyle(color: kAppBarTextColor, fontSize: 27),
      ),
    ),
  );
  final SharedPrefService firstStage = SharedPrefService('firstStage');
  final SharedPrefService secondStage = SharedPrefService('secondStage');

  @override
  void initState() {
    super.initState();
    getRoute();
  }

  Future<void> callCloudFunction() async {
    // this function called after we check if there is a permission and both stages

    FirebaseService.phoneNumber = await SharedPrefService('phoneNumber').value;
    FirebaseService.name = await SharedPrefService('name').value;
    FirebaseService.clr = await FireStoreService.getProp(
        FirebaseService.phoneNumber, FireStoreService.COLOR);
    // update here in the start and everyone that need the phone number take without 'await'

    await CloudFunction.onceAppOpen();
    // its take a while, in the background!
  }

  void getRoute() async {
    final bool firStage = await firstStage.value ?? false;
    bool secStage = await secondStage.value ?? false;

    if (firStage && secStage) {
      final PermissionStatus ps = await PermissionService.getPermission();
      if (!ps.isGranted) {
        //if there is no permission and we already a user so do not go to the home page
        await secondStage.setValue(false);
        secStage = false;
      }
    }

    //navigate(false, false);
    navigate(firStage, secStage);
  }

  Future<void> navigate(bool firstStage, bool secondStage) async {
    String nextPage;
    if (firstStage && secondStage) {
      nextPage = MainScreen.id;
      // if (widget.appOpen == null)
      // if the screen if up on lunch
      await callCloudFunction();
      if (FirebaseService.name == null) {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => SetNameScreen()),
        ); // when the screen is popped we back here
      }
      // if we finish the process(finish the stages and there a permission)
      // so we can call to the function
    } else if (!firstStage)
      nextPage = WelcomeScreen.id;
    else if (firstStage && !secondStage) nextPage = PermissionScreen.id;
    if (mounted) Navigator.of(context).pushReplacementNamed(nextPage);
  }

  @override
  Widget build(BuildContext context) {
    return loading;
  }
}
