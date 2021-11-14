import 'package:flutter/material.dart';
import 'package:guess_me/src/style.dart';

Route<Object> dialogRulesBuilder(BuildContext context, Object arguments) {
  return DialogRoute<void>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
        backgroundColor: kWidgetColor,
        title: Text(
          'How it works?',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: kAppBarTextColor,
          ),
        ),
        content: Text(
          'In contacts screen you tap one of your contact and you send them a message, '
          'the contact see the message in Messages screen and he have up to 3 guesses to guess who'
          'send them the message, if he guess you right you can talk,'
          ' if he guess wrong - the message delete',
          textAlign: TextAlign.center,
          style: TextStyle(color: kAppBarTextColor),
        )),
  );
}
