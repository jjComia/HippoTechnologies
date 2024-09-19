import 'package:shared_preferences/shared_preferences.dart';

import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _sessionIDKey = 'sessionID';

  Future<void> saveSession(String sessionID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionIDKey, sessionID);
  }

  Future<String?> getSessionID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(_sessionIDKey);
  }

  Future<void> deleteSessionID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionIDKey);
  }
}
