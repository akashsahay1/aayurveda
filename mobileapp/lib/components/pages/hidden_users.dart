import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../models/user.dart';
import '../../constants/apis.dart';
import '../common/appbar.dart';

class HiddenUsers extends StatefulWidget {
  const HiddenUsers({super.key});

  @override
  State<HiddenUsers> createState() => _HiddenUsersState();
}

class _HiddenUsersState extends State<HiddenUsers> {
  List<Map<String, dynamic>> _blockedUsers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBlockedUsers();
  }

  Future<void> _loadBlockedUsers() async {
    final userState = Provider.of<UserState>(context, listen: false);
    if (!userState.isLoggedIn || userState.token == null) return;

    try {
      final response = await http.get(
        Uri.parse(blockedUsersApi),
        headers: {'Authorization': 'Bearer ${userState.token}'},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> users = data['blocked_users'] ?? data['blocked_user_ids']?.map((id) => {'id': id, 'display_name': 'User $id'}).toList() ?? [];
        setState(() {
          _blockedUsers = users
              .map((u) => {
                    'id': u['id'] as int,
                    'display_name': u['display_name'] ?? 'User ${u['id']}',
                  })
              .toList();
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _unblockUser(int userId, String name) async {
    final userState = Provider.of<UserState>(context, listen: false);
    if (userState.token == null) return;

    try {
      final response = await http.delete(
        Uri.parse(blockUserApi(userId)),
        headers: {'Authorization': 'Bearer ${userState.token}'},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          _blockedUsers.removeWhere((u) => u['id'] == userId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$name has been unhidden.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to unhide user. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Appbar(title: 'Hidden Users'),
      backgroundColor: Colors.white,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xfff7770f)))
          : _blockedUsers.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_off_outlined, size: 64.0, color: Colors.grey),
                        SizedBox(height: 16.0),
                        Text(
                          'No hidden users',
                          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'Users you hide from comments will appear here. You can unhide them at any time.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  itemCount: _blockedUsers.length,
                  separatorBuilder: (_, __) => const Divider(height: 1.0),
                  itemBuilder: (context, index) {
                    final user = _blockedUsers[index];
                    final name = user['display_name'] as String;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xfff7770f),
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'U',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                      title: Text(name),
                      trailing: TextButton(
                        onPressed: () => _unblockUser(user['id'] as int, name),
                        child: const Text(
                          'Unhide',
                          style: TextStyle(color: Color(0xfff7770f)),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
