import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserState extends ChangeNotifier {
  bool _isLoggedIn = false;
  int? _userId;
  String? _username;
  String? _token;

  bool get isLoggedIn => _isLoggedIn;
  int? get userId => _userId;
  String? get username => _username;
  String? get token => _token;

  Future<void> initializeState() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _userId = prefs.getInt('userId');
    _username = prefs.getString('username');
    _token = prefs.getString('token');
    notifyListeners();
  }

  Future<void> login(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setInt('userId', userData['user_id']);
    await prefs.setString('username', userData['username']);
    await prefs.setString('token', userData['token']);

    _isLoggedIn = true;
    _userId = userData['user_id'];
    _username = userData['username'];
    _token = userData['token'];
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _isLoggedIn = false;
    _userId = null;
    _username = null;
    _token = null;
    notifyListeners();
  }
}