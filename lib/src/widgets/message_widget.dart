import 'package:flutter/material.dart';
import 'package:guess_me/src/style.dart';

class MessageWidget extends StatelessWidget {
  final Message message;
  final bool isMe;

  const MessageWidget({
    @required this.message,
    @required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final radius = Radius.circular(12);
    final borderRadius = BorderRadius.all(radius);
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(16),
          margin: EdgeInsets.all(16),
          constraints: BoxConstraints(maxWidth: 300),
          decoration: BoxDecoration(
            color: isMe ? Colors.black26 : Colors.blueGrey,
            borderRadius: isMe
                ? borderRadius.subtract(BorderRadius.only(bottomRight: radius))
                : borderRadius.subtract(BorderRadius.only(bottomLeft: radius)),
          ),
          child: buildMessage(),
        ),
      ],
    );
  }

  Widget buildMessage() => Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            message.message,
            style: TextStyle(color: kAppBarTextColor),
            textAlign: isMe ? TextAlign.end : TextAlign.start,
          ),
          Text(
            '${message.date.year}-${message.date.month}-${message.date.day}'
            ' ${message.date.hour}:${message.date.minute}:${message.date.second}',
            style: TextStyle(color: kAppBarTextColor.withOpacity(.5)),
          )
        ],
      );
}

class Message {
  final String sender;
  final String username;
  final String message;
  final DateTime date;

  const Message({
    @required this.sender,
    @required this.date,
    @required this.username,
    @required this.message,
  });
}
