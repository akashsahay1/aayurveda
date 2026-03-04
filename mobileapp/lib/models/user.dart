import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserState extends ChangeNotifier {
  static const _secureStorage = FlutterSecureStorage();

  bool _isLoggedIn = false;
  int? _userId;
  String? _username;
  String? _firstName;
  String? _lastName;
  String? _token;
  String? _profileImageUrl;

  bool get isLoggedIn => _isLoggedIn;
  int? get userId => _userId;
  String? get username => _username;
  String? get firstName => _firstName;
  String? get lastName => _lastName;
  String? get token => _token;
  String? get profileImageUrl => _profileImageUrl;

  Future<void> initializeState() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _userId = prefs.getInt('userId');
    _username = prefs.getString('username');
    _firstName = prefs.getString('firstName');
    _lastName = prefs.getString('lastName');
    _profileImageUrl = prefs.getString('profileImageUrl');

    // One-time migration: move token from SharedPreferences to secure storage
    final oldToken = prefs.getString('token');
    if (oldToken != null && oldToken.isNotEmpty) {
      await _secureStorage.write(key: 'token', value: oldToken);
      await prefs.remove('token');
    }

    _token = await _secureStorage.read(key: 'token');
    notifyListeners();
  }

  Future<void> login(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setInt('userId', userData['user_id']);
    await prefs.setString('username', userData['username']);
    await prefs.setString('firstName', userData['first_name'] ?? '');
    await prefs.setString('lastName', userData['last_name'] ?? '');
    await prefs.setString('profileImageUrl', userData['profile_image_url'] ?? '');
    await _secureStorage.write(key: 'token', value: userData['token']);

    _isLoggedIn = true;
    _userId = userData['user_id'];
    _username = userData['username'];
    _firstName = userData['first_name'] ?? '';
    _lastName = userData['last_name'] ?? '';
    _profileImageUrl = userData['profile_image_url'] ?? '';
    _token = userData['token'];
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('userId');
    await prefs.remove('username');
    await prefs.remove('firstName');
    await prefs.remove('lastName');
    await prefs.remove('profileImageUrl');
    await _secureStorage.delete(key: 'token');
    _isLoggedIn = false;
    _userId = null;
    _username = null;
    _firstName = null;
    _lastName = null;
    _profileImageUrl = null;
    _token = null;
    notifyListeners();
  }

  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? profileImageUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (firstName != null) {
      _firstName = firstName;
      await prefs.setString('firstName', firstName);
    }
    if (lastName != null) {
      _lastName = lastName;
      await prefs.setString('lastName', lastName);
    }
    if (profileImageUrl != null) {
      _profileImageUrl = profileImageUrl;
      await prefs.setString('profileImageUrl', profileImageUrl);
    }
    notifyListeners();
  }
}
