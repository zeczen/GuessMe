import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefService {
  SharedPrefService(String key) {
    _key = key;
    _initPrefs();
  }

  String _key;

  Future value;

  Future<void> _initPrefs() async {
    value = _getValue();
  }

  static Future<void> clean() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
  }

  Future<void> setValue(newValue) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (_key == 'initial process done') {
      value = prefs.setBool(_key, newValue).then((bool isDone) {
        if (isDone) {
        }
        return newValue;
      });
    }
    if (_key == 'firstStage') {
      value = prefs.setBool(_key, newValue).then((bool isDone) {
        if (isDone) {
        }
        return newValue;
      });
    }
    if (_key == 'secondStage') {
      value = prefs.setBool(_key, newValue).then((bool isDone) {
        if (isDone) {
        }
        return newValue;
      });
    }
    if (_key == 'phoneNumber') {
      value = prefs.setString(_key, newValue).then((bool isDone) {
        if (isDone) {
        }
        return newValue;
      });
    }
    if (_key == 'contacts') {
      //the contacts are all formatted and saved as Set (every contacts exist once), the currentPN not there
      value = prefs.setStringList(_key, newValue).then((bool isDone) {
        if (isDone) {
        }
        return newValue;
      });
    }

    if (_key == 'name') {
      value = prefs.setString(_key, newValue).then((bool isDone) {
        if (isDone) {
        }
        return newValue;
      });
    }
    if (_key == 'date') {
      value = prefs.setString(_key, newValue).then((bool isDone) {
        if (isDone) {
        }
        return newValue;
      });
    }
  }

  Future _getValue() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var value;
    if (_key == 'date')
      value = prefs.getString(_key);
    else if (_key == 'name')
      value = prefs.getString(_key);
    else if (_key == 'phoneNumber')
      value = prefs.getString(_key);
    else if (_key == 'firstStage')
      value = prefs.getBool(_key);
    else if (_key == 'secondStage')
      value = prefs.getBool(_key);
    else if (_key == 'contacts')
      value = prefs.getStringList(_key);
    else if (_key == 'initial process done')
      value = prefs.getBool(_key);
    else
      throw ("Erorr1234321"); // invalid name
    return value;
  }
}
