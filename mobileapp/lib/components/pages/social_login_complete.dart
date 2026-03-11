import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../services/social_auth_service.dart';
import 'account.dart';

class SocialLoginComplete extends StatefulWidget {
  final String provider;
  final String providerId;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? profileImageUrl;
  final bool needsEmail;
  final bool needsName;

  const SocialLoginComplete({
    super.key,
    required this.provider,
    required this.providerId,
    this.email,
    this.firstName,
    this.lastName,
    this.profileImageUrl,
    this.needsEmail = false,
    this.needsName = false,
  });

  @override
  State<SocialLoginComplete> createState() => _SocialLoginCompleteState();
}

class _SocialLoginCompleteState extends State<SocialLoginComplete> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.email ?? '');
    _firstNameController = TextEditingController(text: widget.firstName ?? '');
    _lastNameController = TextEditingController(text: widget.lastName ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await SocialAuthService.completeLogin(
      provider: widget.provider,
      providerId: widget.providerId,
      email: _emailController.text.trim(),
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      profileImageUrl: widget.profileImageUrl ?? '',
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success && result.userData != null) {
      await Provider.of<UserState>(context, listen: false).login(result.userData!);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const Account()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.errorMessage ?? 'Something went wrong.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage("assets/images/login-bg.png"),
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Complete Your Profile",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    "We need a few more details to set up your account.",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 15.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  if (widget.needsEmail || (widget.email ?? '').isEmpty)
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email address is required';
                        }
                        final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                        if (!emailRegex.hasMatch(value.trim())) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(right: 10.0),
                          child: Icon(Icons.email_outlined),
                        ),
                        hintText: 'Email Address',
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                        prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                      ),
                      style: const TextStyle(color: Colors.black, fontSize: 17.0),
                    ),
                  if (widget.needsEmail || (widget.email ?? '').isEmpty)
                    const SizedBox(height: 12.0),
                  TextFormField(
                    controller: _firstNameController,
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'First name is required';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(right: 10.0),
                        child: Icon(Icons.person_outline),
                      ),
                      hintText: 'First Name',
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                      prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                    ),
                    style: const TextStyle(color: Colors.black, fontSize: 17.0),
                  ),
                  const SizedBox(height: 12.0),
                  TextFormField(
                    controller: _lastNameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(right: 10.0),
                        child: Icon(Icons.person_outline),
                      ),
                      hintText: 'Last Name',
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                      prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                    ),
                    style: const TextStyle(color: Colors.black, fontSize: 17.0),
                  ),
                  const SizedBox(height: 24.0),
                  SizedBox(
                    width: double.infinity,
                    height: 50.0,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Color(0xfff7770f)),
                        foregroundColor: WidgetStatePropertyAll(Colors.white),
                        shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30.0)),
                          ),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 18.0,
                              height: 18.0,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0),
                            )
                          : const Text(
                              "Continue",
                              style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
