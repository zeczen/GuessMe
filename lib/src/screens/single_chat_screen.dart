
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:guess_me/src/services/social_service.dart';
import 'package:guess_me/src/style.dart';
import 'package:guess_me/src/widgets/contact_class.dart';
import 'package:guess_me/src/widgets/messages_widget.dart';
import 'package:guess_me/src/widgets/new_message.dart';

// class ChatScreen extends StatefulBuilder {
//   static String get id => _ChatScreenState.id;
//
//   final ContactObj user;
//
//   const ChatScreen({
//     @required this.user,
//   });
//
//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }

class ChatScreen extends StatelessWidget {
  final ContactObj user;

  ChatScreen({
    @required this.user,
  });

  static const String id = 'Chat';

  final radius = Radius.circular(12);
  final borderRadius = BorderRadius.all(Radius.circular(12));

  Widget buildIcon(IconData icon, Function onTap) => Container(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white10,
    ),
    child: IconButton(
      onPressed: onTap,
      iconSize: 30,
      splashRadius: 30,
      icon: Icon(icon, size: 25, color: Colors.white),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    extendBodyBehindAppBar: true,
    backgroundColor: kTopAppColor,
    body: SafeArea(
      child: Column(
        children: [
          Container(
            height: 80,
            padding: EdgeInsets.all(16).copyWith(left: 0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BackButton(
                      color: kAppBarTextColor,
                    ),
                    Expanded(
                      child: Text(
                        user.name,
                        style: TextStyle(
                          fontSize: 24,
                          color: kAppBarTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        buildIcon(FontAwesomeIcons.whatsapp, () {
                          WhatsappService.send(user.phoneNumber);
                        }),
                        SizedBox(width: 12),
                        buildIcon(FontAwesomeIcons.sms,
                                () => SMSService.send(user.phoneNumber)),
                      ],
                    ),
                    SizedBox(width: 4),
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: kWidgetColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: MessagesWidget(
                  urlPhoto: user.photo, idUser: user.phoneNumber),
            ),
          ),
          NewMessageWidget(idUser: user.phoneNumber)
        ],
      ),
    ),
  );
}