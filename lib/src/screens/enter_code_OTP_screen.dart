import 'dart:io';

import 'package:guess_me/src/widgets/snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:guess_me/src/services/firebase_stuff.dart';
import 'package:guess_me/src/services/shared_pref.dart';
import 'loading_screen.dart';
import '../widgets/screen.dart';
import 'package:quiver/async.dart';
import 'dart:async';
import '../style.dart';
import 'package:provider/provider.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class VerCodeScreen extends StatefulWidget {
  VerCodeScreen(this.mobile);

  final String mobile;

  static String get id => '/verCodeScreen';

  @override
  _VerCodeScreenState createState() => _VerCodeScreenState();
}

class _VerCodeScreenState extends State<VerCodeScreen> {
  static const String id = 'Enter Code';
  static const IconData icon = Icons.send;

  bool load = false; // for the _sendAgain()
  String codeFromSMS = '';

  TextEditingController _controllerForCodeSms = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  StreamController<ErrorAnimationType> _errorController;
  bool hasError = false;
  final SharedPrefService firstStage = SharedPrefService('firstStage');
  final GlobalKey<ScaffoldState> globalKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    startTimer();
    _sendAgain();
    setVaribles();
    _errorController = StreamController<ErrorAnimationType>();
    super.initState();
  }

  void setVaribles() {
    setState(() {
      load = false;
    });
  }

  void _setStateIfMounted(Function f) {
    if (mounted) setState(f);
  }

  @override
  void dispose() {
    //_controllerForCodeSms.dispose();
    _errorController.close();
    _timer.cancel();
    super.dispose();
  }

  Future<void> _verifyCode(String codeFromSMS, BuildContext context) async {
    List ret;
    try {
      ret = await FirebaseService.signInWithOTP(codeFromSMS);
    } catch (e) {
      return;

    }
    if (ret[0]) {
      // if we logging in successfully
      if (!mounted) return;
      await firstStage.setValue(true);
      Navigator.of(context).pushNamedAndRemoveUntil(
          LoadingScreen.id, (Route<dynamic> route) => false,
          arguments: false);
    } else if (!ret[0]) {
      // if error
      String message;
      String code = ret[1].code;
      if (code == "session-expired") {
        message = 'The Code That Sent To You Was Expired';
      } else if (code == "invalid-verification-code") {
        message = 'You Enter uncorrect Code, Try Again';
      } else if (code == "invalid-verification-id") {
        message = 'You Enter Invalid Code, Try Again';
      } else {
        message = 'You Enter uncorrect Code, Try Again';
      }
      _controllerForCodeSms.clear();

      showSnackBarWithText(context, text: message);
    }
  }

  Future<bool> _sendAgain() async {
    setState(() {
      load = true;
    });
    return FirebaseService.verifyMobile(
      widget.mobile,
      verAuto: () async {
        if (!mounted) return;

        await firstStage.setValue(true);
        Navigator.of(context).pushNamedAndRemoveUntil(
            LoadingScreen.id, (Route<dynamic> route) => false,
            arguments: false);
      },
      verFailed: (FirebaseAuthException failedCode) {
        setState(() {
          load = false;
        });
        if (!mounted) return;
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
        _setStateIfMounted(() {
          load = false;
        });
        startTimer();
      },
      whenTimeOut: () {},
    );
  }

  int _counter;
  Timer _timer;

  void startTimer() {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.

    _setStateIfMounted(() {
      _counter = kSecondsUntilSMSTimeOut;
      _timer = null;
    });
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
    } else {
      _timer = new Timer.periodic(
        const Duration(seconds: 1),
        (Timer timer) => _setStateIfMounted(
          () {
            if (_counter < 1) {
              timer.cancel();
            } else {
              _counter = _counter - 1;
            }
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        tooltip: load ? 'Just a second' : 'Verify',
        child: load
            ? CircularProgressIndicator(
                color: Colors.white,
              )
            : Icon(Icons.arrow_forward),
        backgroundColor:
            codeFromSMS.length == 6 ? kSelectedColor : kUnselectedColor,
        onPressed: () {
          if (codeFromSMS.length != 6) {
            _errorController.add(
                ErrorAnimationType.shake); // Triggering error shake animation
            _setStateIfMounted(() {
              hasError = true;
            });
          } else {
            _setStateIfMounted(() {
              hasError = false;
            });
          }
        },
      ),
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
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                RichText(
                  textAlign: TextAlign.start,
                  text: TextSpan(
                      text: "Enter the code that sent to\n",
                      style: TextStyle(color: kAppBarTextColor, fontSize: 19),
                      children: [
                        TextSpan(
                            text: '${widget.mobile}. ',
                            style: TextStyle(
                                color: kAppBarTextColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 21)),
                        _counter == 0
                            ? TextSpan(
                                text: 'Are You Enter Your Phone Correct?',
                                style: TextStyle(
                                    color: kAnotherWidgetColor, fontSize: 19))
                            : TextSpan(),
                      ]),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: 30,
                  ),
                  child: PinCodeTextField(
                    autoFocus: true,
                    key: _formKey,
                    appContext: context,
                    pastedTextStyle: TextStyle(color: kAppBarTextColor),
                    length: 6,
                    animationType: AnimationType.slide,
                    pinTheme: PinTheme(
                        selectedColor: kAppBarTextColor,
                        selectedFillColor: Colors.transparent,
                        shape: PinCodeFieldShape.underline,
                        activeColor: kAppBarTextColor.withAlpha(0x50),
                        inactiveColor: kAppBarTextColor.withAlpha(0x50),
                        fieldHeight: 60,
                        fieldWidth: 50,
                        activeFillColor: Colors.transparent,
                        inactiveFillColor: Colors.transparent),
                    showCursor: false,
                    animationDuration: Duration(milliseconds: 300),
                    textStyle: TextStyle(
                        fontSize: 20, height: 1.6, color: kAppBarTextColor),
                    backgroundColor: Colors.transparent,
                    enableActiveFill: true,
                    errorAnimationController: _errorController,
                    controller: _controllerForCodeSms,
                    keyboardType: TextInputType.number,
                    boxShadows: [
                      BoxShadow(
                        offset: Offset(0, 1),
                        color: kBackgroundColor,
                        blurRadius: 10,
                      )
                    ],
                    onCompleted: (v) {
                      _verifyCode(codeFromSMS, context);
                    },
                    onChanged: (String text) {
                      if (text == '') {
                        _setStateIfMounted(() {
                          codeFromSMS = '';
                        });
                        return;
                      }
                      _setStateIfMounted(() {
                        hasError = false;
                        codeFromSMS = text;
                      });
                      try {
                        int.parse(text);
                      } catch (e) {
                        Future.delayed(Duration.zero).then((value) {
                          if (!mounted) return;
                          _controllerForCodeSms.clear();
                        });

                        _errorController.add(ErrorAnimationType.shake);
                        _setStateIfMounted(() {
                          hasError = true;
                          codeFromSMS = '';
                        });
                        return;
                      }
                    },
                    beforeTextPaste: (String text) {
                      String message = 'Succsesfully paste $text';
                      try {
                        if (text.length > 6) throw ("LEN-ERROR");

                        if (0 > int.parse(text)) throw ("NEG-ERROR");
                        _setStateIfMounted(() {
                          hasError = false;
                          _controllerForCodeSms.text = text;
                          codeFromSMS = text;
                        });
                      } catch (e) {
                        if (e == "NEG-ERROR")
                          message = 'You Can Only Paste Positive Numbers';
                        if (e == "LEN-ERROR")
                          message = 'You Can Only Paste 6 Numbers';
                        else
                          message = 'You Can Only Paste Numbers';

                        _errorController.add(ErrorAnimationType.shake);
                        _setStateIfMounted(() {
                          _controllerForCodeSms.clear();
                          codeFromSMS = '';
                        });
                      } finally {
                        showSnackBarWithText(context, text: message);
                      }
//                  message = 'You cant paste';
//                  final snackBar = SnackBar(
//                    content: Text(
//                      message,
//                      textAlign: TextAlign.center,
//                    ),
//                    backgroundColor: Colors.black,
//                    behavior: SnackBarBehavior.floating,
//                    duration: Duration(milliseconds: 1200),
//                  );
//                  globalKey.currentState.removeCurrentSnackBar();
//                  globalKey.currentState.showSnackBar(snackBar);
                      // if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                      // but you can show anything you want here, like your pop up saying wrong paste format or etc
                      return false;
                    },
                  ),
                ),
                Text(
                  hasError
                      ? "Please fill up all the cells properly with only numbers"
                      : "",
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w400),
                ),
                SizedBox(
                  height: 30,
                ),
                _counter == 0
                    ? TextButton(
                        onPressed: () => _sendAgain(),
                        child: Text(
                          'send code again',
                          style: TextStyle(
                            fontSize: 15,
                            color: kSelectedColor,
                          ),
                        ))
                    : Text(
                        'Resend Code in $_counter Seconds',
                        style: TextStyle(
                          fontSize: 15,
                          color: kAppBarTextColor,
                        ),
                      ),
              ],
            ),
            Container(
              width: 110,
              child: Text(
                'Tip: long press on the pin code field to paste!',
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
