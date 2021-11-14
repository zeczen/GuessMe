import 'dart:async';

import 'package:flutter/material.dart';
import 'package:guess_me/src/services/firebase_stuff.dart';
import 'package:guess_me/src/services/firestore_stuff.dart';
import 'package:guess_me/src/services/permission_stuff.dart';
import 'package:guess_me/src/widgets/contact_class.dart';

class FacebookProvider with ChangeNotifier {
  FacebookProvider() {
    // all the constructors of type Provider.ChangeNotifier call just once
    // (in the first call to them in the screens)
    loadData();
  }

  static void clean() {
    friendsStatic = [];
  }

  Future<void> load;
  bool loading = false;

  static List<ContactObj> friendsStatic = [];

  List<ContactObj> get friends => friendsStatic;

  void loadData({bool force = false}) {
    if (!force) if (friendsStatic != []) return;
    if (loading) return;
    // else
    loading = true;
    load = _loadData();

    notifyListeners();
  }

  Future<void> _loadData() async {
    // reset
    friendsStatic = [];
    String phoneNumber = FirebaseService.phoneNumber;
    // get data from database
    List friendsPhoneNumbers = await FireStoreService.getProp(
            phoneNumber, FireStoreService.FACEBOOKFRIENDS) ??
        [];
    if (friendsPhoneNumbers.length != 0)
      for (String pn in friendsPhoneNumbers) {
        friendsStatic.add(ContactObj(
          name: await PermissionService.isContactExist(pn)
              ? (await PermissionService.getContact(pn)).first.displayName
              : (await FireStoreService.getNamesContacts([pn]))[0],
          phoneNumber: pn,
          photo: (await FireStoreService.getProp(
              pn, FireStoreService.FACEBOOKPHOTO)),
          color: await FireStoreService.getProp(pn, FireStoreService.COLOR),
        ));
      }

    loading = false;
    notifyListeners();
    // important!
  }
}
