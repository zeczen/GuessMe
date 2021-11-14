
import 'package:flutter/material.dart';
import 'package:guess_me/src/services/firebase_stuff.dart';
import 'package:guess_me/src/services/firestore_stuff.dart';
import 'package:guess_me/src/style.dart';
import 'package:guess_me/src/widgets/snackbar.dart';

class MessageCard extends StatelessWidget {
  MessageCard({
    @required this.message,
    @required this.updateBloc,
    @required this.pushGuessScreen,
  });

  final Function updateBloc;
  final Function pushGuessScreen;
  final MessageObj message;

  final GlobalKey _globalKey = new GlobalKey();

  String timeText() {
    return '${message.date.year}-${message.date.month}-${message.date.day}'
        ' ${message.date.hour}:${message.date.minute}:${message.date.second}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            margin: EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: kAnotherWidgetColor.withOpacity(.7),
              borderRadius: BorderRadius.only(
                topLeft: message.sent ? Radius.zero : Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
                topRight: message.sent ? Radius.circular(20) : Radius.zero,
              ),
            ),
            child: InkWell(
              onTap: () {
                dynamic state = _globalKey.currentState;
                state.showButtonMenu();
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        message.sent
                            ? '${message.name} ${message.id}'
                            : 'Press to guess who send you that',
                        style: TextStyle(
                          color: kAppBarTextColor.withOpacity(.6),
                        ),
                      ),
                      SizedBox(
                        height: 19,
                        child: PopupMenuButton(
                          onSelected: (val) async {
                            if (val == 0) {
                              await FireStoreService.deleteMessage(
                                  FirebaseService.phoneNumber,
                                  message.id,
                                  message.text);
                              updateBloc();
                              showSnackBarWithText(context, text: 'Deleted!');
                            }
                            if (val == 1) {
                              await FireStoreService.blockedAction(
                                  FirebaseService.phoneNumber, message.id);
                              await FireStoreService.deleteMessage(
                                  FirebaseService.phoneNumber,
                                  message.id,
                                  message.text);
                              updateBloc();
                              showSnackBarWithText(context, text: 'Blocked!');
                            }
                            if (val == 2) {
                              await FireStoreService.deleteMessage(
                                  FirebaseService.phoneNumber,
                                  message.id,
                                  message.text);
                              updateBloc();
                              showSnackBarWithText(context, text: 'Deleted!');
                            }
                            if (val == 3) {
                              pushGuessScreen();
                            }
                          },
                          key: _globalKey,
                          color: kWidgetColor,
                          enabled: true,
                          itemBuilder: (context) {
                            if (message.sent) {
                              return [
                                PopupMenuItem(
                                  value: 0,
                                  child: Text(
                                    'Delete message',
                                    style: TextStyle(color: kAppBarTextColor),
                                  ),
                                ),
                              ];
                            }
                            return [
                              PopupMenuItem(
                                value: 1,
                                child: Text(
                                  'Block',
                                  style: TextStyle(color: kAppBarTextColor),
                                ),
                                // Block the sender
                              ),
                              PopupMenuItem(
                                child: Text(
                                  'Delete message',
                                  style: TextStyle(color: kAppBarTextColor),
                                ),
                                // Delete the Message
                                value: 2,
                              ),
                              PopupMenuItem(
                                child: Text(
                                  'Guess',
                                  style: TextStyle(color: kAppBarTextColor),
                                ),
                                value: 3,
                              ),
                            ];
                          },
                          child: Icon(
                            Icons.more_horiz,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                    child: Text(
                      message.text,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Text(
                    timeText(),
                    style: TextStyle(
                      color: kAppBarTextColor.withOpacity(.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(
            color: kAppBarTextColor,
          ),
        ],
      ),
    );
  }
}

class MessageObj {
  MessageObj({
    @required this.text,
    this.id, // not current
    this.date,
    this.sent,
    this.name = '',
    this.isFacebook,
  });

  final String text;
  final DateTime date;
  final String id;
  final String name;
  final bool isFacebook;
  final bool sent;
}
