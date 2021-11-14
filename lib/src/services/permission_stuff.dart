
import 'package:contacts_service/contacts_service.dart';
import 'package:libphonenumber/libphonenumber.dart';
import 'package:permission_handler/permission_handler.dart';

import 'country_stuff.dart';

abstract class PermissionService {
  static Future<Iterable<Contact>> getContact(String phoneNumber,
      {bool thumbnails = false}) async {
    Iterable<Contact> contacts = await ContactsService.getContactsForPhone(
          phoneNumber,
          withThumbnails: thumbnails,
          photoHighResolution:
              false,
      // Android only: Get thumbnail for an avatar afterwards (only necessary if `withThumbnails: false` is used)
        ) ??
        null;

    return contacts;
  }

  static Future<bool> isContactExist(String phoneNumber) async {
    Iterable<Contact> contacts = await getContact(phoneNumber);
    return contacts.isNotEmpty;
  }

  static Future<Iterable<Contact>> getContacts() {
    // We can now access our contacts here
    // Make sure we already have permissions for contacts when we get
    // here, so we can just retrieve it
    //Iterable<Contact> contacts = await ContactsService.getContactsForPhone("YourPhoneNumber");
    return ContactsService.getContacts(
        photoHighResolution: false, withThumbnails: false);
  }

  static Future<PermissionStatus> getPermission() async {
    // PermissionStatus.denied:
    // what we need to do is just to ask again
    // PermissionStatus.restricted:
    // only IOS
    // PermissionStatus.permanentlyDenied:
    // user selected never again.
    // This permission status can still be changed but through the devices settings page
    final PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted) {
      final Map<Permission, PermissionStatus> permissionStatus =
          await [Permission.contacts].request();
      return permissionStatus[Permission.contacts] ?? PermissionStatus.denied;
    } else {
      return permission; //= granted
    }
  }

  static Future<String> formatPhoneNumber(String phoneNumber) async {
    // this function format the phone numbers that in the fireStore =>
    // all the numbers that get will read and write formatted here:
    String isoCode = await LocationService.getCountryCode();
    return await PhoneNumberUtil.normalizePhoneNumber(
        phoneNumber: phoneNumber, isoCode: isoCode);
  }
}
