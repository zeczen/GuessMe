import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guess_me/src/services/permission_stuff.dart';
import 'package:guess_me/src/services/shared_pref.dart';
import 'package:guess_me/src/widgets/snackbar.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../services/country_stuff.dart';
import '../services/firebase_stuff.dart';
import '../style.dart';
import 'enter_code_OTP_screen.dart';
import 'loading_screen.dart';

class SignInScreen extends StatefulWidget {

  static String get id => '/signInScreen';

  @override
  _SignInPhoneScreenState createState() => _SignInPhoneScreenState();
}

class _SignInPhoneScreenState extends State<SignInScreen> {
  static const String id = 'Sign In With Your Phone Number';
  static const IconData icon = Icons.phone;

  @override
  void initState() {
    super.initState();
    initPlatformState().then((value) => initialProp());
  }

  initialProp() {
    setState(() {
      _controllerForPlugin.clear();
      initialPhoneNumber = PhoneNumber(isoCode: currentCode, phoneNumber: '');
      inputPhoneNumber = PhoneNumber(
          isoCode: currentCode, phoneNumber: _controllerForPlugin.value.text);
      isVer = false;
      isLoad = false;
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    currentCode = await LocationService.getCountryCode();
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    setState(() {
      initialPhoneNumber = PhoneNumber(isoCode: currentCode, phoneNumber: '');
      inputPhoneNumber = PhoneNumber(isoCode: currentCode, phoneNumber: '');
    });
  }

  @override
  void dispose() {
    _controllerForPlugin.dispose();

    super.dispose();
  }

  void _setStateIfMounted(Function f) {
    if (mounted) setState(f);
  }

  Future<bool> _verifyPhoneNumber({String formatPN}) async {
    formatPN = formatPN ??
        await PermissionService.formatPhoneNumber(
            '${initialPhoneNumber.dialCode} ${_controllerForPlugin.text}');
    await // this is probably the MOST IMPORTANT 'await
        SharedPrefService('phoneNumber').setValue(formatPN);
    FirebaseService.phoneNumber = formatPN;
    return FirebaseService.verifyMobile(
      formatPN,
      verAuto: () async {
        if (!mounted) return;
        await SharedPrefService('firstStage').setValue(true);
        // if we pass the auth automatically we go to loading and change the first stage

        Navigator.of(context).pushNamedAndRemoveUntil(
            LoadingScreen.id, (Route<dynamic> route) => false,
            arguments: false);
      },
      verFailed: (FirebaseAuthException failedCode) {
        if (!mounted) return;
        setState(() {
          isLoad = false;
        }); // for the animation
        String text;
        if (failedCode.code == 'network-request-failed') {
          text = 'You Need To Check Your Connection Status';
        } else if (failedCode.code == 'invalid-phone-number') {
          text = 'You Need To Enter a Valid Phone Number In E.164 Format';
        } else if (failedCode.code == 'too-many-requests') {
          text = failedCode.message;
        } else {
        }
        showSnackBarWithText(context,
            text: text ?? failedCode.message ?? "try again");
      },
      whenCodeSent: () {
        if (!mounted) return;
        Navigator.pushNamed(context, VerCodeScreen.id, arguments: formatPN)
            .then((value) => initialProp());
      },
      whenTimeOut: () {},
    );
  }

  final TextEditingController _controllerForPlugin = TextEditingController();
  final globalKey = GlobalKey<ScaffoldState>();

  PhoneNumber initialPhoneNumber = PhoneNumber(isoCode: 'US');
  PhoneNumber inputPhoneNumber = PhoneNumber(isoCode: 'US');
  String currentCode = 'US';
  bool isVer = false;
  bool isLoad = false;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: isVer ? kSelectedColor : kUnselectedColor,
        child: isLoad
            ? CircularProgressIndicator(
                color: Colors.white,
              )
            : Icon(
                Icons.send,
                color: kAppBarTextColor,
              ),
        onPressed: () {
          if (_formKey.currentState.validate()) {
            initialPhoneNumber =
                inputPhoneNumber; //In order to format the textFormField
            setState(() {
              isLoad = true;
            });
            _verifyPhoneNumber();
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      body: Padding(
        padding: EdgeInsets.only(
          top: 15,
          bottom: 36,
          left: 23,
          right: 23,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Sign In With Phone Number Is Necessary',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: kAppBarTextColor,
                    fontSize: 16.5,
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 20),
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: InternationalPhoneNumberInput(
                      validator: (String value) {
                        if (value.isEmpty) {
                          return 'Enter your phone number';
                        }
                        if (!isVer) {
                          return 'Phone number must be valid';
                        }
                        return null;
                      },
                      formatInput: true,
                      //
                      searchBoxDecoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            //borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(color: kSelectedColor)),
                        focusedBorder: OutlineInputBorder(
                            //borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(color: Colors.black)),
                        filled: true,
                        hintText: "Whats Your Country?",
                        hintStyle: TextStyle(
                          fontSize: 15.5,
                          color: Colors.black,
                        ),
                        fillColor: kAnotherWidgetColor,
                        border: OutlineInputBorder(),
                      ),
                      textStyle: TextStyle(color: kAppBarTextColor),
                      onInputChanged: (PhoneNumber newNumber) {
                        if (inputPhoneNumber.phoneNumber !=
                            newNumber
                                .phoneNumber) // if there is acctualy a change
                          setState(() {
                            isLoad = false;
                          });

                        inputPhoneNumber = newNumber;
                        currentCode = newNumber.isoCode;
                        //_formKey.currentState.validate();
                      },
                      onInputValidated: (bool value) {
                        setState(() {
                          isVer = value;
                        });
                      },
                      selectorConfig: SelectorConfig(
                        selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                      ),
                      ignoreBlank: false,
                      autoValidateMode: AutovalidateMode.disabled,
                      selectorTextStyle: TextStyle(color: kAppBarTextColor),
                      initialValue: initialPhoneNumber,
                      textFieldController: _controllerForPlugin,
                      inputBorder: UnderlineInputBorder(),
                      keyboardAction: TextInputAction.send,
                      inputDecoration: InputDecoration(
                          suffixIcon: IconButton(
                            splashRadius: 12,
                            tooltip: "clear",
                            padding: EdgeInsets.zero,
                            autofocus: true,
                            iconSize: 17,
                            splashColor: Colors.white70,
                            color: kAppBarTextColor,
                            highlightColor: Colors.transparent,
                            onPressed: () {
                              if (_controllerForPlugin.value.text == '') return;
                              setState(() {
                                _controllerForPlugin.clear();
                              });
                            },
                            icon: Icon(
                              Icons.clear,
                            ),
                          ),
                          enabledBorder: UnderlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                              borderSide: BorderSide(color: kUnselectedColor)),
                          focusedBorder: UnderlineInputBorder(
                              //borderRadius: BorderRadius.all(Radius.circular(8)),
                              borderSide: BorderSide(color: kAppBarTextColor)),
                          filled: true,
                          hintText: "Your Phone Number?",
                          hintStyle: TextStyle(
                            fontSize: 15,
                            color: kAppBarTextColor,
                          ),
                          border: UnderlineInputBorder(),
                          fillColor: Colors.transparent),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              width: 110,
              child: Text(
                'If you wish to continue perhaps text message (SMS) will sent to you for authontication. You may get fee ',
                style: TextStyle(color: kAppBarTextColor),
                textAlign: TextAlign.start,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
