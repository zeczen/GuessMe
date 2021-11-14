import 'dart:async';

import 'package:flutter/material.dart';
import 'package:guess_me/src/services/cloud_function.dart';
import 'package:guess_me/src/services/firebase_stuff.dart';
import 'package:guess_me/src/services/firestore_stuff.dart';
import 'package:guess_me/src/services/permission_stuff.dart';
import 'package:guess_me/src/widgets/contact_class.dart';

class ContactProvider with ChangeNotifier {
  ContactProvider() {
    // all the constructors of type Provider.ChangeNotifier call just once
    // (in the first call to them in the screens)
    loadData();
  }

  static void clean() {
    contactsUStatic = [];
    contactsCStatic = [];
    contactsIStatic = [];
  }

  Future<void> load;
  bool loading = false;

  static List<ContactObj> contactsUStatic = [];
  static List<ContactObj> contactsCStatic = [];
  static List<ContactObj> contactsIStatic = [];

  List<ContactObj> get contactsU => contactsUStatic;

  List<ContactObj> get contactsC => contactsCStatic;

  List<ContactObj> get contactsI => contactsIStatic;

  void loadData({bool force = false}) {
    if (!force) if (contactsIStatic.length +
            contactsCStatic.length +
            contactsUStatic.length !=
        0) // we have them
      return;
    if (loading) return;
    loading = true;
    load = _loadData();

    notifyListeners();
  }

  Future<void> _loadData() async {
    await CloudFunction.handleContactsC(FirebaseService.phoneNumber);
    // await CloudFunction.updateContacts(FirebaseService.phoneNumber);
    // is less likely that user delete or create contact while the app is running

    // reset
    contactsUStatic = [];
    contactsCStatic = [];
    contactsIStatic = [];
    String phoneNumber = FirebaseService.phoneNumber;
    // get data from database
    List phoneNumbersContactsU =
        await FireStoreService.getProp(phoneNumber, FireStoreService.CONTACTSU);
    List phoneNumbersContactsI =
        await FireStoreService.getProp(phoneNumber, FireStoreService.CONTACTSI);
    List phoneNumbersContactsC =
        await FireStoreService.getProp(phoneNumber, FireStoreService.CONTACTSC);
    List namesContactsC =
        await FireStoreService.getNamesContacts(phoneNumbersContactsC);
    if (phoneNumbersContactsU != null)
      for (String pn in phoneNumbersContactsU) {
        contactsUStatic.add(ContactObj(
            name: (await PermissionService.isContactExist(
                    pn)) // it should always be True
                ? (await PermissionService.getContact(pn)).first.displayName
                : (await FireStoreService.getNamesContacts([pn]))[0],
            phoneNumber: pn,
            photo: (await FireStoreService.getProp(
                pn, FireStoreService.FACEBOOKPHOTO)),
            color: await FireStoreService.getProp(pn, FireStoreService.COLOR)));
      }
    if (phoneNumbersContactsC != null)
      for (int i = 0; i < phoneNumbersContactsC.length; i++)
        contactsCStatic.add(ContactObj(
          name: namesContactsC[i],
          phoneNumber: phoneNumbersContactsC[i],
          photo: (await FireStoreService.getProp(
              phoneNumbersContactsC[i], FireStoreService.FACEBOOKPHOTO)),
          color: await FireStoreService.getProp(
              phoneNumbersContactsC[i], FireStoreService.COLOR),
        ));
    if (phoneNumbersContactsI != null)
      for (String pn in phoneNumbersContactsI)
        contactsIStatic.add(ContactObj(
            name: (await PermissionService.isContactExist(
                    pn)) // it should always be True
                ? (await PermissionService.getContact(pn)).first.displayName
                : (await FireStoreService.getNamesContacts([pn]))[0],
            phoneNumber: pn,
            photo: (await FireStoreService.getProp(
                pn, FireStoreService.FACEBOOKPHOTO)),
            color: await FireStoreService.getProp(pn, FireStoreService.COLOR)));

    loading = false;
    notifyListeners();
    // important!
  }
}
