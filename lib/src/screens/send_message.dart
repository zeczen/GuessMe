import 'package:flutter/material.dart';
import 'package:guess_me/src/provider_data/messages_provider.dart';
import 'package:guess_me/src/services/firebase_stuff.dart';
import 'package:guess_me/src/services/firestore_stuff.dart';
import 'package:guess_me/src/style.dart';
import 'package:guess_me/src/widgets/contact_class.dart';
import 'package:guess_me/src/widgets/snackbar.dart';

class PopSendScreen extends StatefulWidget {
  PopSendScreen(this.contact);

  final ContactObj contact;

  @override
  _PopSendScreenState createState() => _PopSendScreenState();
}

class _PopSendScreenState extends State<PopSendScreen> {
  bool loading = false;
  String text = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kWidgetColor,
      padding: EdgeInsets.only(left: 50, right: 50),
      child: loading
          ? Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 25,
                ),
                Text(
                  'Send Message to ${widget.contact.name}:',
                  style: TextStyle(
                    color: kAppBarTextColor,
                    fontSize: 30,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 30,
                ),
                TextField(
                  maxLines: 3,
                  style: TextStyle(color: kAppBarTextColor),
                  autofocus: true,
                  textAlign: TextAlign.start,
                  cursorColor: kAppBarTextColor,
                  onChanged: (value) {
                    setState(() {
                      text = value;
                    });
                  },
                ),
                SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(kAnotherWidgetColor),
                  ),
                  child: Text(
                    'Send!',
                    style: TextStyle(
                      color: kAppBarTextColor,
                    ),
                  ),
                  onPressed: () async {
                    if (text != '') {
                      setState(() {
                        loading = true;
                      });
                      String msg = await FireStoreService.sendMessage(
                          FirebaseService.phoneNumber,
                          widget.contact.phoneNumber,
                          text,
                          isFacebook: false);

                      showSnackBarWithText(context, text: msg);
                      MessagesProvider.messagesSentStatic = [];
                      MessagesProvider.messagesReceiveStatic = [];
                      setState(() {
                        loading = false;
                      });
                      MessagesProvider.clean();
                      Navigator.pop(context);
                    }
                  },
                ),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
    );
  }
}
