import 'package:flutter/material.dart';
import 'package:guess_me/src/provider_data/facebook_provider.dart';
import 'package:guess_me/src/screens/settings_screen.dart';
import 'package:guess_me/src/services/facebook_stuff.dart';
import 'package:guess_me/src/widgets/contact_card.dart';
import 'package:guess_me/src/widgets/screen.dart';
import 'package:provider/provider.dart';

import '../style.dart';

class FacebookScreen extends Screen {
  @override
  _FacebookScreenState createState() => _FacebookScreenState();
}

class _FacebookScreenState extends State<FacebookScreen> {
  static String get id => 'Facebook';

  void loadData(FacebookProvider bloc) async {
    bloc.loadData(force: true);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FacebookProvider>(
      create: (BuildContext context) => FacebookProvider(),
      child: Consumer<FacebookProvider>(
        builder: (BuildContext context, FacebookProvider bloc, Widget child) =>
            Scaffold(
          backgroundColor: kWidgetColor,
          endDrawer: Drawer(
            child: SettingsScreen(),
          ),
          appBar: AppBar(
            title: Center(
              child: Text(
                id,
                style: TextStyle(color: kAppBarTextColor),
              ),
            ),
            leading: IconButton(
              onPressed: () => loadData(bloc),
              icon: Icon(Icons.refresh_sharp),
            ),
            backgroundColor: kTopAppColor,
          ),
          body: FacebookService.isUser
              ? bloc.loading
                  ? CircularProgressIndicator()
                  : bloc.friends.length != 0
                      ? ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: bloc.friends.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ContactCard(
                              contact: bloc.friends[index],
                            );
                          },
                        )
                      : Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Center(
                            child: Text(
                              'You not have facebook friends that use this app',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                color: kAppBarTextColor,
                              ),
                            ),
                          ),
                        )
              : Padding(
            padding: EdgeInsets.all(20.0),
            child: Center(
              child: Text(
                'First Sign in to Your Facebook Account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: kAppBarTextColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
