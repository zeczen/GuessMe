import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:guess_me/src/provider_data/contact_provider.dart';
import 'package:guess_me/src/screens/send_message.dart';
import 'package:guess_me/src/screens/settings_screen.dart';
import 'package:guess_me/src/style.dart';
import 'package:guess_me/src/widgets/contact_card.dart';
import 'package:guess_me/src/widgets/snackbar.dart';
import 'package:provider/provider.dart';

class ContactsScreen extends StatelessWidget {
  static String get id => 'Contacts';

  void loadData(ContactProvider bloc) async {
    bloc.loadData(force: true);
  }

  Widget displayContacts(BuildContext context, Status c, ContactProvider bloc,
      {bool loading = false}) {
    List contacts;
    switch (c) {
      case Status.C:
        contacts = bloc.contactsC;
        break;
      case Status.U:
        contacts = bloc.contactsU;
        break;
      case Status.I:
        contacts = bloc.contactsI;
        break;
    }
    if (loading) {
      return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            imageButton(context, c),
            SizedBox(
              height: 40,
            ),
            Text(
              'Loading...',
              textAlign: TextAlign.center,
              style: TextStyle(color: kAppBarTextColor, fontSize: 20),
            ),
            SizedBox(
              height: 30,
            ),
            Center(child: CircularProgressIndicator()),
          ]);
    }

    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: contacts.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (contacts.length == 0)
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              imageButton(context, c),
              SizedBox(height: 80),
              Text(
                'You not have that kind of contacts yet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: kAppBarTextColor,
                ),
              ),
            ],
          );
        if (index == 0) return imageButton(context, c);
        return Column(
          children: [
            Divider(
              color: kAppBarTextColor,
            ),
            ContactCard(
              onPressed: () {
                if (c == Status.U) {
                  showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (context) => SingleChildScrollView(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child:
                          PopSendScreen(contacts[index - 1]),
                    ),
                  );
                } else
                  showSnackBarWithText(context,
                      text:
                          'You cant send a message to this kind of contacts!');
              },
              contact: contacts[index - 1],
            ),
          ],
        );
      },
    );
  }

  Widget imageButton(BuildContext context, Status c) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
      decoration: BoxDecoration(
        color: kAnotherWidgetColor,
        borderRadius: const BorderRadius.all(Radius.circular(15)),
      ),
      child: InkWell(
        onTap: () {
          showContactsDialog(context, c);
        },
        child: Image(
          image: AssetImage('images/contacts${c.toString().split('.')[1]}.png'),
          height: 75,
          color: Colors.black,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ContactProvider>(
      create: (BuildContext context) => ContactProvider(),
      child: Consumer<ContactProvider>(
        builder: (BuildContext context, ContactProvider bloc, Widget child) =>
            DefaultTabController(
          initialIndex: 2,
          length: 3,
          child: Scaffold(
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
                tabs: [Tab(text: '<->'), Tab(text: '->'), Tab(text: '<-')],
              ),
            ),
            body: TabBarView(children: [
              bloc.loading
                  ? displayContacts(context, Status.U, bloc, loading: true)
                  : displayContacts(context, Status.U, bloc),
              bloc.loading
                  ? displayContacts(context, Status.C, bloc, loading: true)
                  : displayContacts(context, Status.C, bloc),
              bloc.loading
                  ? displayContacts(context, Status.I, bloc, loading: true)
                  : displayContacts(context, Status.I, bloc),
            ]),
          ),
        ),
      ),
    );
  }

  static showContactsDialog(BuildContext context, Status arguments) {
    return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: kWidgetColor,
        title: Center(
          child: Text(
            arguments == Status.C
                ? '->'
                : arguments == Status.I
                    ? '<-'
                    : '<->',
            style: TextStyle(
              color: kAppBarTextColor,
            ),
          ),
        ),
        content: Text(
          arguments == Status.C
              ? 'This page shows you all the contacts that use the app and they save you but you does not save them, '
                  'so if you save them you - can send them a message!'
              : arguments == Status.I
                  ? 'This page shows you all the contacts that use the app and you save them but they does not save you, '
                      'so if they will save you - you can send them a message!'
                  : 'This page shows you all the contacts that use the app and you save them and they save you, '
                      'so if you want to send them a message just choose one!',
          style: TextStyle(color: kAppBarTextColor),
        ),
      ),
    );
  }
}

enum Status { U, I, C }
