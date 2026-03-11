import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:http/http.dart' as http;
import '../constants/apis.dart';

class SocialAuthResult {
  final bool success;
  final bool needsMoreInfo;
  final bool needsEmail;
  final bool needsName;
  final Map<String, dynamic>? userData;
  final String? errorMessage;
  // Partial data from provider (used when needsMoreInfo)
  final String? provider;
  final String? providerId;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? profileImageUrl;

  SocialAuthResult({
    this.success = false,
    this.needsMoreInfo = false,
    this.needsEmail = false,
    this.needsName = false,
    this.userData,
    this.errorMessage,
    this.provider,
    this.providerId,
    this.email,
    this.firstName,
    this.lastName,
    this.profileImageUrl,
  });
}

class SocialAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    clientId: Platform.isIOS ? '898013498394-otr672937ct09l18m1j2aj7ebomt46ef.apps.googleusercontent.com' : null,
  );

  static Future<SocialAuthResult> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        return SocialAuthResult(errorMessage: 'Sign in cancelled.');
      }

      return _callBackend(
        provider: 'google',
        providerId: account.id,
        email: account.email,
        firstName: account.displayName?.split(' ').first ?? '',
        lastName: account.displayName?.split(' ').skip(1).join(' ') ?? '',
        profileImageUrl: account.photoUrl ?? '',
      );
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      return SocialAuthResult(errorMessage: 'Google sign-in failed. Please try again.');
    }
  }

  static Future<SocialAuthResult> signInWithFacebook() async {
    try {
      final result = await FacebookAuth.instance.login(permissions: ['email', 'public_profile']);

      if (result.status == LoginStatus.cancelled) {
        return SocialAuthResult(errorMessage: 'Sign in cancelled.');
      }

      if (result.status != LoginStatus.success) {
        return SocialAuthResult(errorMessage: result.message ?? 'Facebook sign-in failed.');
      }

      final userData = await FacebookAuth.instance.getUserData(fields: 'id,email,first_name,last_name,picture.width(200)');

      return _callBackend(
        provider: 'facebook',
        providerId: userData['id'] ?? '',
        email: userData['email'] ?? '',
        firstName: userData['first_name'] ?? '',
        lastName: userData['last_name'] ?? '',
        profileImageUrl: userData['picture']?['data']?['url'] ?? '',
      );
    } catch (e) {
      debugPrint('Facebook sign-in error: $e');
      return SocialAuthResult(errorMessage: 'Facebook sign-in failed. Please try again.');
    }
  }

  static Future<SocialAuthResult> signInWithApple() async {
    try {
      // Generate nonce for security
      final rawNonce = _generateNonce();
      final nonce = sha256.convert(utf8.encode(rawNonce)).toString();

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      return _callBackend(
        provider: 'apple',
        providerId: credential.userIdentifier ?? '',
        email: credential.email ?? '',
        firstName: credential.givenName ?? '',
        lastName: credential.familyName ?? '',
        profileImageUrl: '',
      );
    } catch (e) {
      debugPrint('Apple sign-in error: $e');
      if (e.toString().contains('canceled')) {
        return SocialAuthResult(errorMessage: 'Sign in cancelled.');
      }
      return SocialAuthResult(errorMessage: 'Apple sign-in failed. Please try again.');
    }
  }

  static Future<SocialAuthResult> _callBackend({
    required String provider,
    required String providerId,
    required String email,
    required String firstName,
    required String lastName,
    required String profileImageUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(socialLoginApi),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'provider': provider,
          'provider_id': providerId,
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
          'profile_image_url': profileImageUrl,
        }),
      );

      final data = jsonDecode(response.body);

      if (data['status'] == 1) {
        return SocialAuthResult(success: true, userData: data);
      }

      if (data['status'] == 2) {
        // Needs more info
        return SocialAuthResult(
          needsMoreInfo: true,
          needsEmail: data['needs_email'] == true,
          needsName: data['needs_name'] == true,
          provider: provider,
          providerId: providerId,
          email: email,
          firstName: firstName,
          lastName: lastName,
          profileImageUrl: profileImageUrl,
        );
      }

      return SocialAuthResult(errorMessage: data['message'] ?? 'Login failed.');
    } catch (e) {
      debugPrint('Social login backend error: $e');
      return SocialAuthResult(errorMessage: 'Connection error. Please try again.');
    }
  }

  /// Complete login when additional info was needed
  static Future<SocialAuthResult> completeLogin({
    required String provider,
    required String providerId,
    required String email,
    required String firstName,
    required String lastName,
    String profileImageUrl = '',
  }) async {
    return _callBackend(
      provider: provider,
      providerId: providerId,
      email: email,
      firstName: firstName,
      lastName: lastName,
      profileImageUrl: profileImageUrl,
    );
  }

  static String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }
}
