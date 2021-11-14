import 'package:flutter/material.dart';
import 'package:guess_me/src/provider_data/messages_provider.dart';
import 'package:guess_me/src/screens/guess_popup_screen.dart';
import 'package:guess_me/src/screens/settings_screen.dart';
import 'package:guess_me/src/widgets/message_card.dart';
import 'package:provider/provider.dart';

import '../style.dart';

class MessagesScreen extends StatelessWidget {
  static String get id => 'Messages';

  void loadData(MessagesProvider bloc) async {
    bloc.loadData(force: true);
  }

  Widget displayMessages(
      BuildContext mainContext, Type status, MessagesProvider bloc,
      {loading = false}) {
    if (loading)
      return Center(
        child: CircularProgressIndicator(),
      );

    // else

    List<MessageObj> msgs =
        status == Type.R ? bloc.messagesReceive : bloc.messagesSent;
    if (msgs.length == 0)
      return Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: Text(
            status == Type.R
                ? 'You not have any receive messages'
                : 'You not have any sent messages',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              color: kAppBarTextColor,
            ),
          ),
        ),
      );
    return ListView.builder(
        itemCount: msgs.length,
        itemBuilder: (BuildContext context, int index) {
          return MessageCard(
              message: msgs[index],
              updateBloc: () => loadData(bloc),
              pushGuessScreen: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (cntxt) => GuessScreen(msgs[index])),
                );
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MessagesProvider>(
      create: (BuildContext context) => MessagesProvider(),
      child: DefaultTabController(
        initialIndex: 0,
        length: 2,
        child: Consumer<MessagesProvider>(
          builder:
              (BuildContext context, MessagesProvider bloc, Widget child) =>
                  Scaffold(
            backgroundColor: kWidgetColor,
            endDrawer: Drawer(
              child: SettingsScreen(),
            ),
            appBar: AppBar(
              leading: IconButton(
                  onPressed: () => loadData(bloc),
                  icon: Icon(Icons.refresh_sharp)),
              title: Center(
                child: Text(
                  id,
                  style: TextStyle(color: kAppBarTextColor),
                ),
              ),
              backgroundColor: kTopAppColor,
              bottom: TabBar(
                tabs: [
                  Tab(
                    text: 'Sent',
                    icon: Icon(Icons.call_made),
                  ),
                  Tab(
                    text: 'Receive',
                    icon: Icon(Icons.call_received),
                  ),
                ],
              ),
            ),
            body: Builder(builder: (contextB) {
              return TabBarView(children: [
                bloc.loading
                    ? displayMessages(contextB, Type.S, bloc, loading: true)
                    : displayMessages(contextB, Type.S, bloc),
                bloc.loading
                    ? displayMessages(contextB, Type.R, bloc, loading: true)
                    : displayMessages(contextB, Type.R, bloc),
              ]);
            }),
          ),
        ),
      ),
    );
  }
}

enum Type { R, S }
