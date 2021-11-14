import 'package:firebase_auth/firebase_auth.dart';
import 'package:guess_me/src/services/facebook_stuff.dart';
import 'package:guess_me/src/services/firestore_stuff.dart';

import '../style.dart';

abstract class FirebaseService {
  static FirebaseAuth _auth = FirebaseAuth.instance;

  static User get currentUser => _auth.currentUser;

  static String get photoUrl =>
      _auth.currentUser.photoURL;

  static String phoneNumber; //set in loading screen or in OTPScreen
  static String name; //set in loading screen
  static int clr; //set in loading screen

  static Stream<User> get currentUserOnStream => _auth.authStateChanges();

  static void facebookLogIn(String token) async {
    FireStoreService.whenUserLoggedFacebook(FacebookService.facebookId,
            FacebookService.friendsId, FacebookService.photoURL, phoneNumber)
        .whenComplete(() async {
      await _getCredential(token);
    });

    // if (result.additionalUserInfo.isNewUser) {
    //   // User logging in for the first time
    //
    // } else {
    //   // User has already logged in before.
    //
    // }
  }

  static Future<void> signOut() async {
    await _auth.signOut(); // sign out from everything
    await FacebookService.signOutFacebook();
  }

  static Future<UserCredential> _getCredential(String token) {
    //convert to credential
    final AuthCredential _authCredential =
        FacebookAuthProvider.credential(token);
    //user credential to sign in with firebase
    return _signInWithCredential(_authCredential);
  }

  static Future<UserCredential> _signInWithCredential(
          AuthCredential credential) async =>
      await _auth.signInWithCredential(credential);

  static Future<List> signInWithOTP(String smsCode) async {
    // we split the function to 2 different part:
    // 1. submit the OTP,
    // 2. signIn/login (both done in the same way)

    // 1. submit the OTP
    AuthCredential _authCredential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: smsCode);
    // 2. SignIn/Login
    UserCredential authRes = await _signInWithCredential(_authCredential);
    return [true, null]; // logging successfully
  }

  static String verificationId;

  //https://medium.com/flutterpub/firebase-user-authentication-using-phone-verification-in-flutter-c34dc0f7a9f8
  static Future<bool> verifyMobile(String mobile,
      {Function whenCodeSent,
      Function verFailed,
      Function verAuto,
      Function whenTimeOut}) async {
    final PhoneVerificationCompleted _verified =
        (AuthCredential _authCredential) async {
      // gets called once the verification is successfully completed
      // If user don't need sms to log in (something in the google play) without the need of user input(!)
      await _signInWithCredential(_authCredential);
      verAuto();
    };

    final PhoneVerificationFailed _verificationFailed =
        (FirebaseAuthException authException) {
      //verification is failed because of wrong code or incorrect mobile number (and user of-course not log in)
      verFailed(authException);
    };
    final PhoneCodeSent _sentCode = (String verId, [int forceResend]) {
      //gets called once the code is sent to the device
      verificationId = verId;
      whenCodeSent();
    };
    final PhoneCodeAutoRetrievalTimeout _autoTimeout = (String verId) {
      //gets called when the time will be completed for the auto retrieval of code
      verificationId = verId;
      whenTimeOut();
    };

    return _auth
        .verifyPhoneNumber(
      phoneNumber: mobile,
      timeout: Duration(seconds: kSecondsUntilSMSTimeOut),
      verificationCompleted: _verified,
      verificationFailed: _verificationFailed,
      codeAutoRetrievalTimeout: _autoTimeout,
      codeSent: (String verId, [int forceResend]) {
        _sentCode(verId, forceResend);
      },
    )
        .then((void value) async {
      return true;
    });
  }
}
