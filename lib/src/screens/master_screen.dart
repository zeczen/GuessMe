import 'package:flutter/material.dart';

import '../style.dart';
import 'chats_screen.dart';
import 'contacts_screen.dart';
import 'messages_screen.dart';

class MainScreen extends StatefulWidget {
  static String get id => _MainScreenState.id;

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static const String id = 'main screen';
  final GlobalKey<ScaffoldState> globalKey = GlobalKey<ScaffoldState>();

  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    ContactsScreen(),
    // FacebookScreen(),
    MessagesScreen(),
    ChatsScreen(),
  ];

  @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      backgroundColor: kTopAppColor,
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: kTopAppColor,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            backgroundColor: kTopAppColor,
            icon: Icon(Icons.contacts),
            label: 'Contacts',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(FontAwesomeIcons.facebookF),
          //   backgroundColor: kTopAppColor,
          //   label: 'Facebook',
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            backgroundColor: kTopAppColor,
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble),
            backgroundColor: kTopAppColor,
            label: 'Chats',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: kSelectedColor,
        onTap: (int index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
