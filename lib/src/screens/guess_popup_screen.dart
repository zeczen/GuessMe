import 'package:flutter/material.dart';
import 'package:guess_me/src/provider_data/contact_provider.dart';
import 'package:guess_me/src/provider_data/messages_provider.dart';
import 'package:guess_me/src/services/firebase_stuff.dart';
import 'package:guess_me/src/services/firestore_chat_stuff.dart';
import 'package:guess_me/src/services/firestore_stuff.dart';
import 'package:guess_me/src/style.dart';
import 'package:guess_me/src/widgets/contact_card.dart';
import 'package:guess_me/src/widgets/contact_class.dart';
import 'package:guess_me/src/widgets/message_card.dart';
import 'package:guess_me/src/widgets/snackbar.dart';
import 'package:provider/provider.dart';

class GuessScreen extends StatefulWidget {
  GuessScreen(this.msg);

  final MessageObj msg;

  static String get id => '/guessScreen';

  @override
  _GuessScreenState createState() => _GuessScreenState();
}

class _GuessScreenState extends State<GuessScreen> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();

  List<ContactObj> displayContacts = [];
  List<ContactObj> selectedCF = [];

  bool run = false;
  bool load = false;
  int allow = 1;

  @override
  void initState() {
    super.initState();
  }

  Widget showCards(dynamic bloc) {
    List<ContactObj> lst = displayContacts;
    List<ContactObj> lstAll = bloc.contactsU;

    if (bloc.loading)
      return Center(
        child: CircularProgressIndicator(),
      );
    if (lstAll.length == 0 || lst.length == 0)
      return Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: Text(
            (lst.length == 0 && lstAll.length != 0)
                ? 'No Result'
                : 'You have no contacts',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              color: kAppBarTextColor,
            ),
          ),
        ),
      );
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: lst.length,
      itemBuilder: (BuildContext context, int index) {
        ContactObj card = lst[index];
        return ContactCard(
          onPressed: () {
            if (selectedCF.length == allow) {
              showSnackBarWithText(context,
                  text: allow == 1
                      ? 'You can chooce 3 contacts when you will have 5 or more contacts in app'
                      : 'You can only chooce 3 contacts');
              return;
            }
            setState(() {
              selectedCF.add(card);
              lst.remove(card);
            });
          },
          contact: card,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ContactProvider>(
          create: (context) => ContactProvider(),
        ),
      ],
      child: Consumer<ContactProvider>(
        builder: (context, contactBloc, _) {
          if (!run) {
            displayContacts = contactBloc.contactsU.toList();
            run = true;
          }
          return Scaffold(
            backgroundColor: kWidgetColor,
            key: _globalKey,
            appBar: AppBar(
              backgroundColor: kTopAppColor,
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.clear,
                  ),
                  color: kAppBarTextColor,
                  onPressed: () {
                    _controller.clear();
                    setState(() {
                      displayContacts = [];
                      contactBloc.contactsU.forEach((element) {
                        if (!selectedCF.contains(element))
                          displayContacts.add(element);
                      });
                    });
                  },
                )
              ],
              title: Center(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    onChanged: (String val) {
                      setState(() {
                        displayContacts = contactBloc.contactsU
                            .where((dynamic element) =>
                                (!selectedCF.contains(element)) &&
                                (element.name
                                        .toLowerCase()
                                        .contains(val.toLowerCase()) ||
                                    element.phoneNumber.contains(val)))
                            .toList();
                      });
                    },
                    controller: _controller,
                    style: TextStyle(
                      color: kAppBarTextColor,
                      fontSize: 17,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      hintText: 'Search...',
                      hintStyle: TextStyle(
                        color: kAppBarTextColor,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: InkWell(
              onTap: () async {
                if (load) {
                  showSnackBarWithText(context, text: 'Loading...');
                  return;
                }
                setState(() {
                  load = true;
                });
                if (selectedCF.length == 0) {
                  showSnackBarWithText(context,
                      text: 'First choose at least 1 contact');
                  return;
                }
                // else
                if (selectedCF.any((ContactObj element) =>
                    element.phoneNumber == widget.msg.id)) {
                  // correct guess
                  // create chatA and move the message to the chat
                  await FirebaseStoreChat.uploadMessage(
                      FirebaseService.phoneNumber,
                      widget.msg.id,
                      widget.msg.text,
                      isFacebook: widget.msg.isFacebook,
                      time: widget.msg.date);
                  await FireStoreService.onApproved(
                      FirebaseService.phoneNumber, widget.msg.id);
                  await FireStoreService.deleteMessage(
                      FirebaseService.phoneNumber,
                      widget.msg.id,
                      widget.msg.text);
                  MessagesProvider.clean();
                  Navigator.pop(context);
                  showSnackBarWithText(context,
                      text: 'Correct guess! Now you can talk');
                } else {
                  // uncorrect guess
                  // delete message

                  FireStoreService.deleteMessage(FirebaseService.phoneNumber,
                      widget.msg.id, widget.msg.text);
                  showSnackBarWithText(context,
                      text: 'Wrong guess! Message deleted');
                  MessagesProvider.clean();
                  Navigator.pop(context);
                }
                setState(() {
                  load = false;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: selectedCF.length != 0
                      ? kAnotherWidgetColor
                      : kUnselectedColor,
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                ),
                height: 47,
                width: 150,
                child: Center(
                  child: load
                      ? CircularProgressIndicator()
                      : Text(
                          'GuessMe',
                          style:
                              TextStyle(color: kAppBarTextColor, fontSize: 21),
                        ),
                ),
              ),
            ),
            body: Column(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 200),
                  child: Container(
                    margin: EdgeInsets.only(top: 20, bottom: 5),
                    decoration: BoxDecoration(
                      color: kTopAppColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: selectedCF.length,
                        itemBuilder: (BuildContext context, int index) {
                          ContactObj con = selectedCF[index];
                          return ContactCard(
                            onPressed: () {
                              setState(() {
                                selectedCF.remove(con);
                                displayContacts.add(con);
                              });
                            },
                            contact: con,
                          );
                        }),
                  ),
                ),
                Expanded(
                  child: showCards(
                    contactBloc,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 1,
                    ),
                    Container(
                      width: 70,
                      child: Text(
                        'You can guess up to '
                        '$allow contact${allow != 1 ? 's' : ''}!',
                        style: TextStyle(
                          color: kAppBarTextColor,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
