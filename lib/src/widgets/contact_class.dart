import 'package:meta/meta.dart';


class ContactObj {

  final String name;
  final String phoneNumber;
  final photo;
  final int color;


  const ContactObj({
    this.phoneNumber,
    @required this.name,
    @required this.color,
    @required this.photo,
  });


}


