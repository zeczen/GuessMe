import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guess_me/src/screens/chats_screen.dart';
import 'package:guess_me/src/screens/permission_screen.dart';
import 'package:guess_me/src/screens/sign_in_phone_screen.dart';

import 'src/screens/enter_code_OTP_screen.dart';
import 'src/screens/loading_screen.dart';
import 'src/screens/master_screen.dart';
import 'src/screens/settings_screen.dart';
import 'src/screens/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    // to prevent horizontal mode
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Firebase.initializeApp();
  runApp(
    //  _MaterialAppWithProviders(),
    MaterialAppWithRoutes(),
  );
}

// This Widget is the main application

class MaterialAppWithRoutes extends StatelessWidget {
  static const String _title = 'GuessMe';

  // not change it without search and find all the places

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: _title,
      initialRoute: LoadingScreen.id,
      routes: {
        LoadingScreen.id: (context) =>
            LoadingScreen(ModalRoute.of(context).settings.arguments),
        PermissionScreen.id: (context) => PermissionScreen(),
        SettingsScreen.id: (context) => SettingsScreen(),
        WelcomeScreen.id: (context) => WelcomeScreen(),
        MainScreen.id: (context) => MainScreen(),
        SignInScreen.id: (context) => SignInScreen(),
        ChatsScreen.id: (context) => ChatsScreen(),
        VerCodeScreen.id: (context) =>
            VerCodeScreen(ModalRoute.of(context).settings.arguments),
      },
    );
  }
}
