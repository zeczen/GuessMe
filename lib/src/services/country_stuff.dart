import 'dart:async';

import 'package:devicelocale/devicelocale.dart';
import 'package:flutter/services.dart';

//example to how to get the country in the front end:
//await LocationService.getCountryCode();

class LocationService {


  static Future<String> _countryCode;
  static bool _isCountryAlreadyChange = false;
  static Future<String> getCountryCode() async {
    if (!_isCountryAlreadyChange) await _getCountryCode();
    return _countryCode;
  }
  static Future<void> _getCountryCode() async {
    _countryCode = _initPlatformState(true);
    _isCountryAlreadyChange = true;
  }


  static Future<String> _languageCode;
  static bool _isLanguageAlreadyChange = false;

  static Future<String> getLanguageCode() async {
    if (!_isLanguageAlreadyChange) await _getLanguageCode();
    return _languageCode;
  }
  static Future<void> _getLanguageCode() async {
    _languageCode = _initPlatformState(true);
    _isLanguageAlreadyChange = true;
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  static Future<String> _initPlatformState(bool isForCountry) async {
    String newCode;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      if(isForCountry)
        newCode = (await Devicelocale.currentAsLocale).countryCode;
      else if(!isForCountry)
        newCode = (await Devicelocale.currentAsLocale).languageCode;
    } on PlatformException {
    }
    return newCode;
  }
}
