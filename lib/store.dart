import 'package:shared_preferences/shared_preferences.dart';

class Store {
  static SharedPreferences? _p;

  static Future<SharedPreferences> _prefs() async {
    _p ??= await SharedPreferences.getInstance();
    return _p!;
  }

  static Future<String?> read(String key) async =>
      (await _prefs()).getString(key);

  static Future<void> write(String key, String value) async {
    await (await _prefs()).setString(key, value);
  }
}
