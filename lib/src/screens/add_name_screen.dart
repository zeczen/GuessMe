
import 'package:flutter/material.dart';
import 'package:guess_me/src/services/firebase_stuff.dart';
import 'package:guess_me/src/services/firestore_stuff.dart';
import 'package:guess_me/src/services/shared_pref.dart';
import 'package:guess_me/src/widgets/snackbar.dart';

import '../style.dart';
import '../widgets/screen.dart';

class SetNameScreen extends Screen {
  SetNameScreen();

  static IconData get icon => _SetNameScreenState.icon;

  static String get id => _SetNameScreenState.id;

  @override
  _SetNameScreenState createState() => _SetNameScreenState();
}

class _SetNameScreenState extends State<SetNameScreen> {
  static const String id = 'Set Your Name';
  static const IconData icon = Icons.edit;
  SharedPrefService sharedInstance = SharedPrefService('name');

  void _whenUserSend(String value, BuildContext context) async {
    await sharedInstance.setValue(value);
    FirebaseService.name = value;
    FireStoreService.setName(FirebaseService.phoneNumber, value);
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    newName = FirebaseService.name ?? 'A Z';
  }

  String newName = '';
  bool valid = false;
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Padding(
        padding: EdgeInsets.only(left: 50, right: 50, top: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            (FirebaseService.photoUrl == null)
                ? circleImage(FirebaseService.clr, valid ? newName : '',
                    size: 50.0)
                : CircleAvatar(
                    backgroundImage: NetworkImage(FirebaseService.photoUrl),
                    backgroundColor: Colors.white,
                    radius: 50,
                  ),
            SizedBox(
              height: 20,
            ),
            Container(
              child: TextFormField(
                textCapitalization: TextCapitalization.words,
                style: TextStyle(
                  color: Colors.white,
                ),
                autocorrect: false,
                maxLines: 1,
                autofocus: true,
                textAlign: TextAlign.left,
                cursorColor: kAppBarTextColor,
                controller: _controller,
                onChanged: (String value) {
                  setState(() {
                    valid = validName(value);
                  });
                  if (value == ' ‎') {
                    setState(() {
                      _controller.clear();
                      newName = '';
                    });
                  } else {
                    setState(() {
                      newName = value;
                    });
                  }
                },
                textInputAction: TextInputAction.go,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      //borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(color: kAnotherWidgetColor)),
                  focusedBorder: OutlineInputBorder(
                      //borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(color: kSelectedColor)),
                  filled: true,
                  hintText: "Whats Your Name?",
                  hintStyle: TextStyle(fontSize: 15, color: kUnselectedColor),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'Enter Your Name Is Helping To Your Friends Find You',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: kUnselectedColor,
                fontSize: 12,
//fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(
              height: 50,
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                    !valid ? kUnselectedColor : kSelectedColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    'Save',
                    style: TextStyle(
                      color: kAppBarTextColor,
                    ),
                  ),
                  Icon(
                    Icons.check,
                    color: kAppBarTextColor,
                  ),
                ],
              ),
              onPressed: () {
                if (!valid) {
                  showSnackBarWithText(context, text: 'Enter a valid name');
                } else
                  _whenUserSend(newName, context);
              },
            ),
          ],
        ),
      ),
    );
  }

  bool validName(String name) {
    return ((name.length >= 1) &&
        (name.length <= 50) &&
        (!name.contains("  ")) &&
        (!name.endsWith(' ')) &&
        (!name.startsWith(' ')));
  }
}
