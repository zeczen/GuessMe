import 'dart:async';

import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:guess_me/src/services/firebase_stuff.dart';

import '../exceptions.dart';

class FacebookService {
  static bool _isUser = false;
  static String facebookId;
  static String photoURL;
  static String name;
  static List<String> friendsId;

  static bool get isUser {
    return _isUser;
  }

  static Future<void> initFacebookUserProp() async {
    final AccessToken accessToken = await FacebookAuth.instance.accessToken;
    _isUser = accessToken != null;
    if (_isUser) {
      await getData();
    }
  }

  static Future<void> getData() async {
    Map<String, dynamic> userData = await FacebookAuth.instance.getUserData(
      fields: "name, picture.width(200), friends, id",
    );
    if (userData == null) {
      throw ConnectionExep('NoInternet');
    } else {
      _getFriendsList(userData["friends"]);
      _getProp(userData);
    }
  }

  static void _getProp(Map<String, dynamic> data) {
    facebookId = data['id'];
    name = data['name'];
    photoURL = data['picture']['data']['url'];
  }

  static void _getFriendsList(Map<String, dynamic> data) {
    int i = 0;

    while (true) {
      try {
        friendsId.add(data[i++]);
        continue;
      } catch (e) {
        break;
      }
    }
  }

  static Future<void> signOutFacebook() async {
    friendsId = null;
    _isUser = false;
    photoURL = null;
    facebookId = null;
    FacebookAuth.instance.logOut();
  }

  static Future<void> logInFacebook() async {
    final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['user_friends', 'public_profile'],
        loginBehavior: LoginBehavior.webOnly);
// loginBehavior is only supported for Android devices, for ios it will be ignored

    if (result.status == LoginStatus.success) {
      final AccessToken accessToken = await FacebookAuth.instance.accessToken;
      await getData();
      // we need an await because the function change the friendsId
      // which use in  FirebaseService.facebookLogIn
      FirebaseService.facebookLogIn(accessToken
          .token); // the function may throw an error, validate that there is no more important things after that
      // you are logged
    } else {
      //throw error maybe
    }
  }
}
