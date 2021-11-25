import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guess_me/src/services/permission_stuff.dart';
import 'package:guess_me/src/widgets/contact_class.dart';

import 'firestore_stuff.dart';

abstract class FirebaseStoreChat {
  static const CHATSA = 'chatsA';

  static Future<void> deleteFacebookChats(String current) async {
    QuerySnapshot chatsToDel = await FirebaseFirestore.instance
        .collection(CHATSA)
        .where(FireStoreService.PARTICIPANTS, arrayContains: current)
        .where(FireStoreService.ISFACEBOOK, isEqualTo: true)
        .get();
    for (QueryDocumentSnapshot cht in chatsToDel.docs) cht.reference.delete();
  }

  static Future<void> deleteUserChats(String current) async {
    QuerySnapshot chatsToDel = await FirebaseFirestore.instance
        .collection(CHATSA)
        .where(FireStoreService.PARTICIPANTS, arrayContains: current)
        .get();
    for (QueryDocumentSnapshot cht in chatsToDel.docs) cht.reference.delete();
  }

  static Stream<List<ContactObj>> getUsers(String current) async* {
    await for (QuerySnapshot users in _getUsers(current)) {
      List<ContactObj> contacts = [];
      for (QueryDocumentSnapshot user in users.docs) {
        Map<String, dynamic> data = user.data() as Map<String, dynamic>;
        contacts.add(ContactObj(
            color:
                await FireStoreService.getProp(user.id, FireStoreService.COLOR),
            name: await PermissionService.isContactExist(user.id)
                ? (await PermissionService.getContact(user.id))
                    .first
                    .displayName
                : data[FireStoreService.NAME],
            photo: data[FireStoreService.FACEBOOKPHOTO],
            phoneNumber: user.id));
      }
      yield contacts;
    }
  }

  static Stream<QuerySnapshot<Object>> _getUsers(String current) {
    // this function return user object of all the approved
    return FirebaseFirestore.instance
        .collection(FireStoreService.USERS)
        .where(FireStoreService.APPROVED, arrayContains: current)
        .snapshots();
  }

  static Future uploadMessage(String current, String idContact, String message,
      {bool isFacebook, DateTime time}) async {
    List<String> usersBoth = [idContact, current];
    usersBoth.sort();

    QuerySnapshot cht = await FirebaseFirestore.instance
        .collection(CHATSA)
        .where(FireStoreService.PARTICIPANTS, isEqualTo: usersBoth)
        .get();
    if (cht.docs.length == 0) {
      // if the chat is not exist than create:
      DocumentReference dr =
          await FirebaseFirestore.instance.collection(CHATSA).add({
        FireStoreService.PARTICIPANTS: usersBoth,
        FireStoreService.ISFACEBOOK: isFacebook,
      });
      await dr.collection(FireStoreService.MESSAGES).add({});

      cht = await FirebaseFirestore.instance
          .collection(CHATSA)
          .where(FireStoreService.PARTICIPANTS, isEqualTo: usersBoth)
          .get();
    }
    await cht.docs[0].reference.collection(FireStoreService.MESSAGES).add({
      FireStoreService.RECEIVER: idContact,
      FireStoreService.SENDER: current,
      FireStoreService.TEXT: message,
      FireStoreService.TIME: time ?? DateTime.now(),
    });
  }

  static Future<Stream<QuerySnapshot<Object>>> getMessages(
      String idContact, String current) async {
    // return all the messages with the approve contact: 'idContact'
    List<String> usersBoth = [idContact, current];
    usersBoth.sort();

    return (await FirebaseFirestore.instance
            .collection(CHATSA)
            .where(FireStoreService.PARTICIPANTS, isEqualTo: usersBoth)
            .get())
        .docs[0]
        .reference
        .collection(FireStoreService.MESSAGES)
        .orderBy(FireStoreService.TIME, descending: true)
        .snapshots();
  }
}
