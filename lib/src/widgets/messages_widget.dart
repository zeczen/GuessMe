import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:guess_me/src/services/firebase_stuff.dart';
import 'package:guess_me/src/services/firestore_chat_stuff.dart';
import 'package:guess_me/src/services/firestore_stuff.dart';

import 'message_widget.dart';

class MessagesWidget extends StatelessWidget {
  final String idUser;
  final String urlPhoto;

  const MessagesWidget({
    @required this.idUser,
    @required this.urlPhoto,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => FutureBuilder<Stream<QuerySnapshot>>(
      future:
          FirebaseStoreChat.getMessages(idUser, FirebaseService.phoneNumber),
      builder: (context, snapshotStream) {
        switch (snapshotStream.connectionState) {
          case ConnectionState.waiting:
            return Center(child: CircularProgressIndicator());
          default:
            if (snapshotStream.hasError) {
              return buildText('Something Went Wrong, Try later');
            }
        }
        return StreamBuilder<QuerySnapshot>(
          stream: snapshotStream.data,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
              default:
                if (snapshot.hasError) {
                  return buildText('Something Went Wrong, Try later');
                } else {
                  List<Message> messages = [];
                  if (snapshot.hasData)
                    for (QueryDocumentSnapshot msg in snapshot.data.docs) {
                      Map<String, dynamic> data =
                          msg.data() as Map<String, dynamic>;
                      messages.add(Message(
                        date: data[FireStoreService.TIME].toDate(),
                        sender: data[FireStoreService.SENDER],
                        username: data[FireStoreService.NAME],
                        message: data[FireStoreService.TEXT],
                      ));
                    }

                  return messages.isEmpty
                      ? buildText('Say Hi..')
                      : ListView.builder(
                          physics: BouncingScrollPhysics(),
                          reverse: true,
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];

                            return MessageWidget(
                              message: message,
                              isMe:
                                  message.sender == FirebaseService.phoneNumber,
                            );
                          },
                        );
                }
            }
          },
        );
      });

  Widget buildText(String text) => Center(
        child: Text(
          text,
          style: TextStyle(fontSize: 24),
        ),
      );
}
