import 'package:flutter/material.dart';
import 'package:guess_me/src/style.dart';

import 'contact_class.dart';

class ContactCard extends StatelessWidget {
  ContactCard({this.contact, this.onPressed});

  final Function onPressed;
  final ContactObj contact;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: EdgeInsets.only(left: 20, right: 20),
      child: InkWell(
        onTap: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  contact.name,
                  style: TextStyle(fontSize: 15.5, color: kAppBarTextColor),
                ),
                Text(
                  contact.phoneNumber,
                  style: TextStyle(fontSize: 13, color: kAppBarTextColor),
                ),
              ],
            ),
            contact.photo == null
                ? circleImage(
                    contact.color,
                    contact.name)
                : CircleAvatar(
                    backgroundImage: NetworkImage(
                      contact.photo,
                    ),
                    backgroundColor: Colors.white,
                  ),
          ],
        ),
      ),
    );
  }
}
