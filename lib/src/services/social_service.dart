import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';
import 'package:flutter_sms/flutter_sms.dart';

abstract class WhatsappService {
  static void send(String phoneNumber) async {
    await FlutterOpenWhatsapp.sendSingleMessage(phoneNumber, "Hi");
  }
}

abstract class SMSService {
  static void send(String phoneNumber) async {
    String _result = await sendSMS(message: 'Hi', recipients: [phoneNumber]);
  }
}
