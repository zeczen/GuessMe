import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:guess_me/src/provider_data/contact_provider.dart';
import 'package:guess_me/src/provider_data/facebook_provider.dart';
import 'package:guess_me/src/provider_data/messages_provider.dart';
import 'package:guess_me/src/screens/loading_screen.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:guess_me/src/services/facebook_stuff.dart';
import 'package:guess_me/src/services/firebase_stuff.dart';
import 'package:guess_me/src/services/firestore_stuff.dart';
import 'package:guess_me/src/services/permission_stuff.dart';
import 'package:guess_me/src/services/shared_pref.dart';
import '../services/firebase_stuff.dart';
import 'package:guess_me/src/exceptions.dart';

// this class call only when stage1 and stage 2! after checking for permission for contacts
abstract class CloudFunction {
  static Future<bool> isOpenAlreadyToday() async {
    final String today = DateTime.now().toString().split(' ')[0]; //2021-04-01
    String lastDayRun = await SharedPrefService('date').value ?? "0000-00-00";
    return today == lastDayRun;
  }

  static Future<void> onceADay() async {
    // update fireStore properties
  }

  static Stream<int> whenUserLog() async* {
    final bool isDone =
        await SharedPrefService('initial process done').value ?? false;
    if (!isDone) {
      // call only when we passed the 2 stages
      Iterable<Contact> contacts = (await PermissionService.getContacts());

      yield* _checkWithDataBase(contacts); // RUN!

      SharedPrefService('initial process done').setValue(true);
      // initial the user document in database
    }
  }

  static Future<void> onceAppOpen() async {
    final String phoneNumber = FirebaseService.phoneNumber;
    await facebookPropUpdate(phoneNumber);

    whenUserLog(); // run just once
    await updateContacts(
        phoneNumber); //search for new and deleted contacts and update the FireStore
    handleContactsC(phoneNumber);
    if (!await isOpenAlreadyToday()) onceADay();
  }

  static Future<void> facebookPropUpdate(String currentPN) async {
    await FacebookService.initFacebookUserProp();
    // its here with await because the UI depend on it

    //now we compare the updated prop with the facebook prop in the firestore database:
    List friends = await FireStoreService.getProp(
        currentPN, FireStoreService.FACEBOOKFRIENDS);
    String photo = await FireStoreService.getProp(
        currentPN, FireStoreService.FACEBOOKPHOTO);

    if (photo != FacebookService.photoURL)
      FireStoreService.updateFacebookPhoto(currentPN, FacebookService.photoURL);
    if (friends != FacebookService.friendsId)
      FireStoreService.updateFacebookFriends(
          currentPN, FacebookService.friendsId ?? []);
  }

  static Future<void> updateContacts(String currentPN) async {
    //this function search for a new and deleted contacts and update the database accordingly

    Iterable<Contact> contactsFromPhoneBook;

    Set contactsListFromSharedPref =
        (await SharedPrefService('contacts').value).toSet();
    contactsListFromSharedPref.remove(currentPN); // if user change account
    contactsFromPhoneBook = await PermissionService.getContacts();
    Set phoneBookContactsFormatted = Set();

    for (Contact con in contactsFromPhoneBook)
      for (Item phone in con.phones)
        phoneBookContactsFormatted
            .add(await PermissionService.formatPhoneNumber(phone.value));

    phoneBookContactsFormatted.remove(currentPN);
    //now phoneBookContactsFormat full with different formatted numbers (and without the current)

    final bool isEqual =
        setEquals(contactsListFromSharedPref, phoneBookContactsFormatted);
    if (isEqual) {
      return;
      //if the sets equal we know that the contacts not change (add or delete)
      //in such case there is no need to change the SharedPref('contacts') or the FireStore so just we exit
    }
    List newContacts;
    List delContacts;

    //its like the filter func: newContacts = filter(phoneBookContactsFormatted, lambda x: x not in contactsListFromSharedPref
    newContacts = phoneBookContactsFormatted
        .where((element) => !contactsListFromSharedPref.contains(element))
        .toList();
    delContacts = contactsListFromSharedPref
        .where((element) => !phoneBookContactsFormatted.contains(element))
        .toList();

    Set<String> newContactsInApp = new Set();
    Set<String> delContactsInApp = new Set();

    for (String phoneNumberContact in newContacts) {
      final bool isPhoneNumberInApp =
          await FireStoreService.isPhoneUserAlreadyExist(phoneNumberContact);
      if (isPhoneNumberInApp) newContactsInApp.add(phoneNumberContact);
    }

    for (String phoneNumberContact in delContacts) {
      final bool isPhoneNumberInApp =
          await FireStoreService.isPhoneUserAlreadyExist(phoneNumberContact);
      if (isPhoneNumberInApp) delContactsInApp.add(phoneNumberContact);
    }


    if (newContactsInApp != null && newContactsInApp.length != 0)
      FireStoreService.addToFriendContact(currentPN, newContactsInApp);
    if (delContactsInApp != null && delContactsInApp.length != 0)
      FireStoreService.delFriendContact(currentPN, delContactsInApp);

    //update the contacts in the shared prefences:
    SharedPrefService('contacts')
        .setValue(phoneBookContactsFormatted.toList().cast<String>());
  }

  static Future<void> handleContactsC(String currentPN) async {
    Set<String> toMoveToContactsU = {};
    List contactsC =
        await FireStoreService.getProp(currentPN, FireStoreService.CONTACTSC);
    if (contactsC == null) return;
    for (String contactPN in contactsC) {
      final bool existInPhoneBook =
          await PermissionService.isContactExist(contactPN);
      if (existInPhoneBook) toMoveToContactsU.add(contactPN);
      // we move to the next user in contacts C
      // remember: there all a formatted contacts because them from the data base
    }
    // when we finish
    // move the phone numbers from 'contacts C' to 'Contacts U'

    if (toMoveToContactsU != null && toMoveToContactsU.length != 0)
      FireStoreService.addToFriendContact(currentPN, toMoveToContactsU);
  }

  static Future<void> onLogOut(BuildContext context) async {
    ContactProvider.clean();
    MessagesProvider.clean();
    FacebookProvider.clean();
    await SharedPrefService.clean();
    await FirebaseService.signOut();
    await SharedPrefService('firstStage').setValue(false);
    await SharedPrefService('secondStage').setValue(false);
    Navigator.of(context).pushNamedAndRemoveUntil(
        LoadingScreen.id, (Route<dynamic> route) => false);
  }

  static bool setEquals<T>(Set<T> a, Set<T> b) {
    // setEquals({1, 2, 3}, {3, 2, 1}) => true
    // the order is not matter
    if (a == null) return b == null;
    // we know that a and b are not null
    if (b == null || (a.length != b.length)) return false;

    if (identical(a, b)) return true;

    for (final T value in a) {
      if (!b.contains(value)) return false;
    }

    return true;
  }

  static int generateColor() {
    FirebaseService.clr =
        Colors.primaries[Random().nextInt(Colors.primaries.length)].value;
    return FirebaseService.clr;
  }

  static String formatName(String name) {
    return name.length >= 1
        ? name.contains(' ') &&
                !name.endsWith(' ') &&
                !name.startsWith(' ') &&
                !name.contains('  ')
            ? '${name.split(' ')[0].substring(0, 1)}'
                ' ${name.split(' ')[1].substring(0, 1)}'
            : '${name.substring(0, 1)}'
        : name;
  }

  static Stream<int> _checkWithDataBase(Iterable<Contact> contacts) async* {
    //static Future<void> _checkWithDataBase(Iterable<Contact> contacts) async {
    String userPNFormat = FirebaseService.phoneNumber;

    Set<String> contactsPhoneNumberThatInApp = new Set();
    Set<String> checksContactsPhoneNumber = new Set();
    //in order to not check twice

    int howManyPass = 0;

    for (Contact contact in contacts) {
      howManyPass++;
      yield howManyPass;
      //we get the value and know how much processing/time left
      for (Item phoneNumber in contact.phones) {
        //for every phone number
        final String formatPhoneNumberContact =
            await PermissionService.formatPhoneNumber(phoneNumber.value);
        if (checksContactsPhoneNumber.contains(
                formatPhoneNumberContact) || //case that user already was check
            formatPhoneNumberContact ==
                userPNFormat) // case that the user is himself
          continue;

        checksContactsPhoneNumber.add(formatPhoneNumberContact);
        try {
          FireStoreService.isPhoneUserAlreadyExist(formatPhoneNumberContact)
              .then((bool value) {
            if (value)
              contactsPhoneNumberThatInApp.add(formatPhoneNumberContact);
          });
        } catch (e) {
          throw ConnectionExep('NoInternet');
        }
      }
    }
    SharedPrefService('contacts').setValue(checksContactsPhoneNumber.toList());
    FireStoreService.addToFriendContact(
        userPNFormat, contactsPhoneNumberThatInApp);
  }
}
