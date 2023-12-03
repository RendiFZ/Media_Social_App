import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  static Future<void> logIn() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', true);
  }

  static Future<void> logOut() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', false);
  }
}
