import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:guess_me/src/services/firebase_stuff.dart';
import 'package:guess_me/src/services/firestore_stuff.dart';
import 'package:guess_me/src/services/permission_stuff.dart';
import 'package:guess_me/src/widgets/message_card.dart';

class MessagesProvider with ChangeNotifier {
  MessagesProvider() {
    // all the constructors of type Provider.ChangeNotifier call just once
    // (in the first call to them in the screens)
    loadData();
  }

  static void clean() {
    messagesSentStatic = [];
    messagesReceiveStatic = [];
    _process = false;
  }

  Future<void> load;
  bool loading = false;

  static List<MessageObj> messagesSentStatic;
  static List<MessageObj> messagesReceiveStatic;
  static bool _process = false;

  List<MessageObj> get messagesSent => messagesSentStatic;

  List<MessageObj> get messagesReceive => messagesReceiveStatic;

  void loadData({bool force = false}) {
    if (!force && _process) return;
    if (loading) return;
    loading = true;
    load = _loadData();

    notifyListeners();
  }

  Future<void> _loadData() async {
    // reset

    messagesSentStatic = [];
    messagesReceiveStatic = [];

    // final List<DocumentSnapshot> docsSent = [];
    // final List<DocumentSnapshot> docsReceive = [];

    List<DocumentSnapshot> chatsSnapshot =
        await FireStoreService.getChatsNotApprove(FirebaseService.phoneNumber);

    for (DocumentSnapshot ds in chatsSnapshot) {
      Map<String, dynamic> chatData = ds.data() as Map<String, dynamic>;

      String id = chatData[FireStoreService.PARTICIPANTS][1 -
          chatData[FireStoreService.PARTICIPANTS]
              .indexOf(FirebaseService.phoneNumber)];
      bool isFacebook = chatData[FireStoreService.ISFACEBOOK];
      // return the other participant (not the current)
      for (DocumentSnapshot msg
          in await FireStoreService.getMessagesOfChat(ds)) {
        // for every message
        Map<String, dynamic> msgData = msg.data() as Map<String, dynamic>;

        if (msgData[FireStoreService.SENDER] == FirebaseService.phoneNumber)
          // add to sent list
          messagesSentStatic.add(MessageObj(
            sent: true,
            name: (await PermissionService.getContact(id)).first.givenName,
            id: id,
            isFacebook: isFacebook,
            date: msgData[FireStoreService.TIME].toDate(),
            text: msgData[FireStoreService.TEXT],
          ));
        else if (msgData[FireStoreService.RECEIVER] ==
            FirebaseService.phoneNumber)
          // add to receive list
          messagesReceiveStatic.add(MessageObj(
            sent: false,
            isFacebook: isFacebook,
            id: chatData[FireStoreService.PARTICIPANTS][1 -
                chatData[FireStoreService.PARTICIPANTS]
                    .indexOf(FirebaseService.phoneNumber)]
            // return the other participant (not the current)
            ,
            date: msgData[FireStoreService.TIME].toDate(),
            text: msgData[FireStoreService.TEXT],
          ));
      }
    }

    messagesReceiveStatic
        .sort((MessageObj m1, MessageObj m2) => m1.date.compareTo(m2.date));
    messagesSentStatic
        .sort((MessageObj m1, MessageObj m2) => m1.date.compareTo(m2.date));

    loading = false;
    _process = true;
    notifyListeners();
    // important!
  }
}
