import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guess_me/src/services/cloud_function.dart';

import '../exceptions.dart';
import 'firestore_chat_stuff.dart';

abstract class FireStoreService {
  static const CONTACTSU = 'contacts U';
  static const CONTACTSC = 'contacts C';
  static const CONTACTSI = 'contacts I';
  static const NAME = 'name';
  static const COLOR = 'color';
  static const FACEBOOKID = 'facebook id';
  static const FACEBOOKFRIENDS = 'facebook friends';
  static const FACEBOOKPHOTO = 'facebook photo';
  static const MESSAGES = 'messages';

  static const ISFACEBOOK = 'is facebook';
  static const TEXT = 'text';
  static const BLOCKED = 'blocked';
  static const APPROVED = 'approved';
  static const PARTICIPANTS = 'participants';
  static const RECEIVER = 'receiver';
  static const SENDER = 'sender';
  static const TIME = 'time';

  static const USERS = 'users';
  static const CHATS = 'chats';

  static CollectionReference users =
      FirebaseFirestore.instance.collection(USERS);
  static CollectionReference chats =
      FirebaseFirestore.instance.collection(CHATS);

  static DocumentSnapshot currentUserDoc;

  static Future<List<DocumentSnapshot>> getChatsNotApprove(String id) async {
    // for the message screen => NOT APPROVE!

    final QuerySnapshot userChats =
        await chats.where(PARTICIPANTS, arrayContains: id).get();
    return userChats.docs;
  }

  static Future onApproved(String current, String friend) async {
    await users.doc(current).update({
      APPROVED: FieldValue.arrayUnion([friend])
    });
    await users.doc(friend).update({
      APPROVED: FieldValue.arrayUnion([current])
    });
  }

  static Future<List<QueryDocumentSnapshot>> getMessagesOfChat(
      DocumentSnapshot chatDS) async {
    // Unpacked docs
    return (await chatDS.reference.collection(MESSAGES).get()).docs;
  }

  static Future blockedClear(String current) async {
    await users.doc(current).update({
      BLOCKED: [],
    });
  }

  static Future<int> blockedNum(String current) async {
    await _loadDataWithPhoneNumber(current);
    Map<String, dynamic> data = currentUserDoc.data() as Map<String, dynamic>;

    return data[BLOCKED].length;
  }

  static Future blockedAction(String current, String friend) async {
    await users.doc(current).update({
      BLOCKED: FieldValue.arrayUnion([friend]),
    });
  }

  static Future deleteMessage(String current, String id, String textMsg) async {
    // the id is can be the sender OR the receiver
    List<String> usersBoth = [current, id];
    usersBoth.sort();
    QueryDocumentSnapshot cht =
        (await chats.where(PARTICIPANTS, isEqualTo: usersBoth).get()).docs[0];

    List<QueryDocumentSnapshot> msgs = (await cht.reference
            .collection(MESSAGES)
            .where(TEXT, isEqualTo: textMsg)
            .get())
        .docs;
    for (QueryDocumentSnapshot msg in msgs) {
      await msg.reference.delete();
    }
  }

  static Future<String> sendMessage(String sndr, String rcvr, String msg,
      {bool isFacebook}) async {
    List<String> usersBoth = [sndr, rcvr];
    usersBoth.sort();
    final QuerySnapshot userChats =
        await chats.where(PARTICIPANTS, isEqualTo: usersBoth).get();
    if (userChats.docs.length == 0) {
      // if the chat is not exist than create:
      DocumentReference dr = await chats.add({
        PARTICIPANTS: usersBoth,
        ISFACEBOOK: isFacebook,
      });
      await dr.collection(MESSAGES).add({});
    }
    // now the chat exist
    DocumentSnapshot userDS = await users.doc(sndr).get();
    Map<String, dynamic> dataUser = userDS.data() as Map<String, dynamic>;
    if ((dataUser[BLOCKED] ?? []).contains(rcvr))
      return ('You cant send him a message, you block him. Remove the block first');
    DocumentSnapshot friendDS = await users.doc(rcvr).get();
    Map<String, dynamic> dataFriend = friendDS.data() as Map<String, dynamic>;
    if ((dataFriend[BLOCKED] ?? []).contains(sndr))
      return ('You cant send him a message, you blocked!');
    // else

    // now we know that the sender is not blocked
    final QuerySnapshot openChat =
        await chats.where(PARTICIPANTS, isEqualTo: usersBoth).get();
    if (!isFacebook)
      openChat.docs[0].reference.update({ISFACEBOOK: isFacebook});
    openChat.docs[0].reference.collection(MESSAGES).add({
      RECEIVER: rcvr,
      SENDER: sndr,
      TEXT: msg,
      TIME: DateTime.now(),
    });
    return 'Successfuly send!';
  }

  static Future<void> whenUserLogInPhoneNumber(String phoneNumber) async {
    if (!await isPhoneUserAlreadyExist(phoneNumber)) {
      await users.doc(phoneNumber).set({
        CONTACTSC: [],
        CONTACTSI: [],
        CONTACTSU: [],
        BLOCKED: [],
        APPROVED: [],
        FACEBOOKID: "",
        FACEBOOKFRIENDS: [],
        COLOR: CloudFunction.generateColor(),
      });
    }
    // if the document does not yet exist, it will be created.
  }

  static Future<void> deleteUser(String id) async {
    List contactsCList = await getProp(id, CONTACTSC);
    List contactsIList = await getProp(id, CONTACTSI);
    List contactsUList = await getProp(id, CONTACTSU);
    List blocked = await getProp(id, BLOCKED);
    List approved = await getProp(id, APPROVED);

    for (var c in contactsCList)
      users.doc(c).update({
        CONTACTSI: FieldValue.arrayRemove([id]),
      });
    for (var u in contactsUList)
      users.doc(u).update({
        CONTACTSU: FieldValue.arrayRemove([id]),
      });
    for (var i in contactsIList)
      users.doc(i).update({
        CONTACTSC: FieldValue.arrayRemove([id]),
      });
    for (var i in blocked)
      users.doc(i).update({
        BLOCKED: FieldValue.arrayRemove([id]),
      });
    for (var i in approved)
      users.doc(i).update({
        APPROVED: FieldValue.arrayRemove([id]),
      });

    await facebookLoggedOut(id);

    // delete not approve chats:
    QuerySnapshot chatsToDel =
        await chats.where(PARTICIPANTS, arrayContains: id).get();
    for (QueryDocumentSnapshot cht in chatsToDel.docs) cht.reference.delete();

    await FirebaseStoreChat.deleteUserChats(id); // delete approved

    await users.doc(id).delete(); // !!!
  }

  static Future<void> facebookLoggedOut(String phoneNumber) async {
    // disconnect from facebook account
    await _loadDataWithPhoneNumber(phoneNumber);
    Map<String, dynamic> data = currentUserDoc.data() as Map<String, dynamic>;

    List friends = data[FACEBOOKFRIENDS] ?? [];

    for (var id in friends) {
      await users.doc(id).update({
        FACEBOOKFRIENDS: FieldValue.arrayRemove([phoneNumber]),
      });
    }
    await users.doc(phoneNumber).update({
      FACEBOOKID: null,
      FACEBOOKFRIENDS: [],
      FACEBOOKPHOTO: FieldValue.delete(),
    });
    currentUserDoc = null;

    // delete not approve chats:
    QuerySnapshot chatsToDel = await chats
        .where(PARTICIPANTS, arrayContains: phoneNumber)
        .where(ISFACEBOOK, isEqualTo: true)
        .get();
    for (QueryDocumentSnapshot cht in chatsToDel.docs) cht.reference.delete();

    await FirebaseStoreChat.deleteFacebookChats(phoneNumber); // delete approved
  }

  static Future<List<String>> facebookIdsToPhoneNumbers(
      List<String> fbIds) async {
    List<String> friends = [];
    for (String id in fbIds) {
      final QuerySnapshot result =
          await users.where(FACEBOOKID, isEqualTo: id).get();
      final List<DocumentSnapshot> documents = result.docs;
      friends.add(documents[0].id);
    }
    return friends;
  }

  static Future<void> whenUserLoggedFacebook(String fbId,
      List<String> friendsFacebookIds, String photo, String phoneNumber) async {
    final int isHeInFbUsers = await _isFbUserAlreadyExist(fbId, phoneNumber);
    List<String> friends = await facebookIdsToPhoneNumbers(friendsFacebookIds);
    users.doc(phoneNumber).update(
        {FACEBOOKID: fbId, FACEBOOKFRIENDS: friends, FACEBOOKPHOTO: photo});
    if (isHeInFbUsers >= 1) {
      // we have the facebook already in the data base,
      throw (WorningExep(
          "This Facebook account already bean used. First, log out of your second account"));
    }
  }

  static Future<void> addToFriendContact(
      String uId, Set<String> friends) async {
    await _loadDataWithPhoneNumber(uId);
    // [friends] could have contacts in contactsI or contactsU
    // there is 2 scenarios:
    // 1: the contacts is in C (current) and I (contacts) => move to contactsU (both)
    // 2: the contact is new => add to I (current) and C (contacts)

    Map<String, dynamic> data = currentUserDoc.data() as Map<String, dynamic>;
    if (data == null) return;
    List exContactsC = data[CONTACTSC];
    List exContactsU = data[CONTACTSU];
    List exContactsI = data[CONTACTSI];
    List inContactsC = [];
    List newContacts = [];

    friends.forEach((str) {
      if (exContactsC.contains(str))
        inContactsC.add(str);
      else if (!exContactsU.contains(str) && !exContactsI.contains(str))
        // if the contact is total new, not in C, U or I
        newContacts.add(str);
    });
    // now [inContactsC] contains all the element that both in [exContactsC] and [friends]
    // and [newContacts] contains all the element that in [friends] but not in [exContactsC]

    // _____for scenario 1:_____
    // remove contacts from the contactsC of current:
    // add contacts to the contactsU of current:
    users.doc(uId).update({
      CONTACTSC: FieldValue.arrayRemove(inContactsC.toList()),
      CONTACTSU: FieldValue.arrayUnion(inContactsC.toList()),
    });

    // remove contacts from the contactsI of each contacts:
    // add contacts to the contactsU of each contacts:
    for (var friend in inContactsC)
      users.doc(friend).update({
        CONTACTSI: FieldValue.arrayRemove([uId]),
        CONTACTSU: FieldValue.arrayUnion([uId]),
      });
    // _____for scenario 2:_____
    users
        .doc(uId)
        .update({CONTACTSI: FieldValue.arrayUnion(newContacts.toList())});
    for (var friend in newContacts)
      //add the current user to each friend
      users.doc(friend).update({
        CONTACTSC: FieldValue.arrayUnion([uId])
      });
  }

  static void delFriendContact(String uId, Set<String> usersToDel) async {
    await _loadDataWithPhoneNumber(uId);
    // there is 2 scenarios:
    // 1: the contacts is in U
    // 2: the contact is in I (current) and C (contacts)

    Map<String, dynamic> data = currentUserDoc.data() as Map<String, dynamic>;
    if (data == null) return;

    List exContactsU = data[CONTACTSU];
    List exContactsI = data[CONTACTSI];
    List filtered = [];

    // _____for scenario 1:_____
    filtered = [];
    exContactsU.forEach((var str) {
      if (usersToDel.contains(str)) filtered.add(str);
    }); // now [filtered] contains all the element that both in [exContactsU] and [usersToDel]

    // remove contacts from the contactsU of current:
    // add contacts to the contactsC of current:
    users.doc(uId).update({
      CONTACTSU: FieldValue.arrayRemove(filtered.toList()),
      CONTACTSC: FieldValue.arrayUnion(filtered.toList()),
    });

    // remove contacts from the contactsU of each contacts:
    // add contacts to the contactsI of each contacts:
    for (var friend in filtered)
      users.doc(friend).update({
        CONTACTSU: FieldValue.arrayRemove([uId]),
        CONTACTSI: FieldValue.arrayUnion([uId]),
      });

    // _____for scenario 2:_____
    // 2: the contact is in I (current) and C (contacts)
    filtered = [];
    exContactsI.forEach((var str) {
      if (usersToDel.contains(str)) filtered.add(str);
    }); // now [filtered] contains all the element that both in [exContactsI] and [usersToDel]

    // remove contacts from the contactsI of current:
    users.doc(uId).update({
      CONTACTSI: FieldValue.arrayRemove(filtered.toList()),
    });

    // remove current from the contactsI of each contacts:
    for (var friend in filtered)
      users.doc(friend).update({
        CONTACTSC: FieldValue.arrayRemove([uId]),
      });
  }

  static Future<void> updateFacebookPhoto(
      String id, String facebookPhotoURL) async {
    await users.doc(id).update({
      FACEBOOKPHOTO: facebookPhotoURL,
    });
  }

  static Future<void> updateFacebookFriends(
      String id, List<String> facebookFriendsList) async {
    List<String> friends = await facebookIdsToPhoneNumbers(facebookFriendsList);
    await users.doc(id).update({
      FACEBOOKFRIENDS: friends,
    });
  }

  static Future<int> _isFbUserAlreadyExist(String facebookId, String pn) async {
    // return how many account using this facebook id
    final QuerySnapshot result =
        await users.where(FACEBOOKID, isEqualTo: facebookId).get();
    final List<DocumentSnapshot> documents = result.docs;
    return documents.length;
  }

  static Future<bool> isPhoneUserAlreadyExist(String id) async {
    bool exist = false;
    try {
      await users.doc(id).get().then((doc) {
        exist = doc.exists;
      });
      return exist;
    } catch (e) {
      // If any error
      return false;
    }
  }

  static Future<void> _loadDataWithPhoneNumber(String phoneNumber) async {
    currentUserDoc = await users.doc(phoneNumber).get();
  }

  static Future<void> setName(String uId, String newName) async {
    await users.doc(uId).update({NAME: newName});
  }

  static Future<List> getNamesContacts(List phoneNumbers) async {
    List namesContactsC = [];
    for (var friend in phoneNumbers) {
      Map<String, dynamic> data =
          (await users.doc(friend).get()).data() as Map<String, dynamic>;
      if (data != null) namesContactsC.add(data[NAME]);
    }
    return namesContactsC;
  }

  static Future getProp(String phoneNumber, String prop) async {
    DocumentSnapshot doc = await users.doc(phoneNumber).get();
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return data[prop];
  }
}
