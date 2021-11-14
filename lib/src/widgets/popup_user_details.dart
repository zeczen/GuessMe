import 'package:flutter/material.dart';
import 'package:guess_me/src/services/cloud_function.dart';
import 'package:guess_me/src/services/facebook_stuff.dart';
import 'package:guess_me/src/services/firebase_stuff.dart';
import 'package:guess_me/src/services/firestore_stuff.dart';
import 'package:guess_me/src/style.dart';

bool pressed = false;

Route<Object> dialogBuilder(BuildContext context, Object arguments) {
  return DialogRoute<void>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      backgroundColor: kWidgetColor,
      title: Text(
        'Sign in to Facebook',
        style: TextStyle(
          color: kAppBarTextColor,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Name: ${FacebookService.name}',
            style: tStyle,
          ),
          Text(
            'Facebook ID: ${FacebookService.facebookId}',
            style: tStyle,
          ),
          Text(
            'Creation Time: \n${FirebaseService.currentUser.metadata.creationTime.toString().substring(0, FirebaseService.currentUser.metadata.creationTime.toString().lastIndexOf('.'))}',
            style: tStyle,
          ),
          Text(
            'last SignIn Time: \n${FirebaseService.currentUser.metadata.lastSignInTime.toString().substring(0, FirebaseService.currentUser.metadata.lastSignInTime.toString().lastIndexOf('.'))}',
            style: tStyle,
          ),
        ],
      ),
    ),
  );
}

Route<Object> dialogLogOut(BuildContext context, Object arguments) {
  return DialogRoute<void>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      backgroundColor: kWidgetColor,
      title: Text(
        'Log Out',
        style: TextStyle(
          color: kAppBarTextColor,
        ),
      ),
      content: Text(
        'By pressing Log Out all the information of your account will be deleted from the device, '
        'you can login again using the phone number: ${FirebaseService.phoneNumber}',
        style: tStyle,
      ),
      actions: [
        ElevatedButton(
          child: Text(
            'Log Out',
            style: TextStyle(color: kAnotherWidgetColor),
          ),
          onPressed: () async {
            if (pressed) return;
            pressed = true;
            await CloudFunction.onLogOut(cntxt);
            pressed = false;
          },
          style: ElevatedButton.styleFrom(
            primary: kWidgetColor,
          ),
        ),
      ],
    ),
  );
}

Route<Object> dialogDelAccount(BuildContext context, Object arguments) {
  return DialogRoute<void>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      backgroundColor: kWidgetColor,
      title: Text(
        'Delete My Account',
        style: TextStyle(
          color: kAppBarTextColor,
        ),
      ),
      content: Text(
        'Clicking Delete My Account will delete your account, it can not be canceled',
        style: tStyle,
      ),
      actions: [
        ElevatedButton(
          child: Text(
            'Delete My Account',
            style: TextStyle(color: kAnotherWidgetColor),
          ),
          onPressed: delAcc,
          style: ElevatedButton.styleFrom(
            primary: kWidgetColor,
          ),
        ),
      ],
    ),
  );
}

final TextStyle tStyle = TextStyle(color: kAppBarTextColor);
BuildContext cntxt;

void delAcc() async {
  if (pressed) return;
  pressed = true;
  await FireStoreService.deleteUser(FirebaseService.phoneNumber);
  await CloudFunction.onLogOut(cntxt);
  pressed = false;
}
