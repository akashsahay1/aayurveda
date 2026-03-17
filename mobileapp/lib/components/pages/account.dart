import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../models/user.dart';
import '../../constants/apis.dart';
import '../common/appbar.dart';
import '../common/bottombar.dart';
import 'about.dart';
import 'privacy.dart';
import 'terms.dart';
import 'login.dart';
import 'edit_profile.dart';
import 'home.dart';
import 'reading_history.dart';
import 'hidden_users.dart';

class Account extends StatelessWidget {
  const Account({super.key});

  Future<void> _deleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action is permanent and cannot be undone. All your data, including likes and comments, will be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    final userState = Provider.of<UserState>(context, listen: false);
    final token = userState.token;
    if (token == null) return;

    try {
      final response = await http.delete(
        Uri.parse(deleteAccountApi),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!context.mounted) return;

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 1) {
        await userState.logout();
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account deleted successfully.')),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const Home()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? 'Failed to delete account.'),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connection error. Please try again.')),
      );
    }
  }

  Future<void> _logout(BuildContext context) async {
    final userState = Provider.of<UserState>(context, listen: false);
    final token = userState.token;

    // Call server logout
    if (token != null) {
      try {
        await http.post(
          Uri.parse(logoutApi),
          headers: {'Authorization': 'Bearer $token'},
        );
      } catch (_) {}
    }

    await userState.logout();

    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const Login()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);
    final fullName = [userState.firstName, userState.lastName]
        .where((s) => s != null && s.isNotEmpty)
        .join(' ');
    final displayName = fullName.isNotEmpty ? fullName : userState.username ?? '';

    return Scaffold(
      appBar: const Appbar(title: 'My Account'),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30.0),
              // Avatar
              CircleAvatar(
                radius: 45.0,
                backgroundColor: const Color(0xfff7770f),
                backgroundImage: (userState.profileImageUrl != null &&
                        userState.profileImageUrl!.isNotEmpty)
                    ? NetworkImage(userState.profileImageUrl!)
                    : null,
                child: (userState.profileImageUrl == null ||
                        userState.profileImageUrl!.isEmpty)
                    ? Text(
                        displayName.isNotEmpty
                            ? displayName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          fontSize: 36.0,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 15.0),
              // Greeting
              Text(
                'Hi, $displayName!',
                style: const TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 5.0),
              Text(
                '@${userState.username ?? ''}',
                style: const TextStyle(
                  fontSize: 16.0,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 12.0),
              ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfile()),
                ),
                icon: const Icon(Icons.edit, size: 16.0),
                label: const Text('Edit Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xfff7770f),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 8.0),
                ),
              ),
              const SizedBox(height: 20.0),
              const Divider(height: 1.0),
              // Menu items
              ListTile(
                leading: const Icon(Icons.history, color: Color(0xfff7770f)),
                title: const Text('Reading History'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ReadingHistory()),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person_off_outlined, color: Color(0xfff7770f)),
                title: const Text('Hidden Users'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HiddenUsers()),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline, color: Color(0xfff7770f)),
                title: const Text('About Us'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const About()),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined, color: Color(0xfff7770f)),
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PrivacyPolicy()),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined, color: Color(0xfff7770f)),
                title: const Text('Terms of Service'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TermsOfService()),
                ),
              ),
              const Divider(height: 1.0),
              const SizedBox(height: 20.0),
              // Logout button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _logout(context),
                    icon: const Icon(Icons.logout),
                    label: const Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[50],
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => _deleteAccount(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                    ),
                    child: const Text(
                      'Delete Account',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              // App version
              const Text(
                'Aayurveda v1.1.0',
                style: TextStyle(
                  fontSize: 13.0,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const Bottombar(currentIndex: 4),
    );
  }
}
