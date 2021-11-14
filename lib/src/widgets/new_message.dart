import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guess_me/src/services/firebase_stuff.dart';
import 'package:guess_me/src/services/firestore_chat_stuff.dart';
import 'package:guess_me/src/style.dart';

class NewMessageWidget extends StatefulWidget {
  final String idUser;

  const NewMessageWidget({
    @required this.idUser,
    Key key,
  }) : super(key: key);

  @override
  _NewMessageWidgetState createState() => _NewMessageWidgetState();
}

class _NewMessageWidgetState extends State<NewMessageWidget> {
  final _controller = TextEditingController();
  String message = '';
  bool loading = false;

  void sendMessage() async {
    if (loading) return;

    loading = true;
    FocusScope.of(context).unfocus();

    await FirebaseStoreChat.uploadMessage(
        FirebaseService.phoneNumber, widget.idUser, message);

    _controller.clear();
    setState(() => message = '');
    loading = false;
  }

  @override
  Widget build(BuildContext context) => Container(
        color: kWidgetColor,
        padding: EdgeInsets.all(8),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _controller,
                textCapitalization: TextCapitalization.sentences,
                autocorrect: true,
                enableSuggestions: true,
                style: TextStyle(color: kAppBarTextColor),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: kBackgroundColor,
                  labelText: 'Type your message',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(width: 0),
                    gapPadding: 10,
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onChanged: (value) => setState(() {
                  message = value;
                }),
              ),
            ),
            SizedBox(width: 20),
            GestureDetector(
              onTap: message.trim().isEmpty ? null : sendMessage,
              child: Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: loading || message.trim().isEmpty
                      ? kBackgroundColor
                      : kSelectedColor,
                ),
                child: Icon(
                  Icons.send,
                  color: loading || message.trim().isEmpty
                      ? kSelectedColor
                      : kBackgroundColor,
                ),
              ),
            ),
          ],
        ),
      );
}
