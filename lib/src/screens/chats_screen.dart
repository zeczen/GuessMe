import 'package:flutter/material.dart';
import 'package:guess_me/src/screens/single_chat_screen.dart';
import 'package:guess_me/src/services/firebase_stuff.dart';
import 'package:guess_me/src/services/firestore_chat_stuff.dart';
import 'package:guess_me/src/widgets/contact_class.dart';
import 'package:guess_me/src/widgets/snackbar.dart';

import '../style.dart';

class ChatsScreen extends StatelessWidget {
  static String get id => 'chat screen';

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: kTopAppColor,
        body: SafeArea(
          child: StreamBuilder<List<ContactObj>>(
            stream: FirebaseStoreChat.getUsers(FirebaseService.phoneNumber),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return Center(child: CircularProgressIndicator());
                default:
                  if (snapshot.hasError) {
                    return buildText('Something Went Wrong Try later');
                  } else {
                    List<ContactObj> contacts = snapshot.data ?? [];
                    if (contacts.length == 0) {
                      return buildText('No Users Found');
                    } else
                      return Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 24),
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.75,
                                  child: Text(
                                    'Chats',
                                    style: TextStyle(
                                      color: kAppBarTextColor,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 12),
                                Container(
                                  height: 65,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: contacts.length + 1,
                                    itemBuilder: (context, index) {
                                      ContactObj user;
                                      if (index != contacts.length)
                                        user = contacts[index];
                                      if (index == contacts.length) {
                                        return Container(
                                          margin: EdgeInsets.only(right: 12),
                                          child: CircleAvatar(
                                            radius: 24,
                                            child: InkWell(
                                                onTap: () => showSnackBarWithText(
                                                    context,
                                                    text: 'Not Functional Yet'),
                                                child: Icon(Icons.search)),
                                          ),
                                        );
                                      } else {
                                        return Container(
                                          margin:
                                              const EdgeInsets.only(right: 12),
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ChatScreen(
                                                    user: user,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: user.photo == null
                                                ? circleImage(
                                                    user.color, user.name, size: 24)
                                                : CircleAvatar(
                                                    backgroundImage:
                                                        NetworkImage(
                                                      user.photo,
                                                    ),
                                                    backgroundColor:
                                                        Colors.white,
                                                  ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: kWidgetColor,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(25),
                                  topRight: Radius.circular(25),
                                ),
                              ),
                              child: ListView.builder(
                                physics: BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final user = contacts[index];

                                  return Container(
                                    height: 75,
                                    child: ListTile(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => ChatScreen(
                                              user: user,
                                            ),
                                          ),
                                        );
                                      },
                                      leading: user.photo == null
                                          ? circleImage(user.color, user.name)
                                          : CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                user.photo,
                                              ),
                                              backgroundColor: Colors.white,
                                            ),
                                      title: Text(
                                        user.name,
                                        style:
                                            TextStyle(color: kAppBarTextColor),
                                      ),
                                    ),
                                  );
                                },
                                itemCount: contacts.length,
                              ),
                            ),
                          ),
                        ],
                      );
                  }
              }
            },
          ),
        ),
      );

  Widget buildText(String text) => Center(
        child: Text(
          text,
          style: TextStyle(fontSize: 24, color: kAppBarTextColor),
        ),
      );
}
