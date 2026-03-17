import 'dart:io';
import 'package:provider/provider.dart';
import 'package:ayurveda/components/pages/account.dart';
import 'package:ayurveda/components/pages/signup.dart';
import 'package:ayurveda/components/pages/social_login_complete.dart';
import 'package:ayurveda/constants/apis.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ayurveda/models/user.dart';
import 'package:ayurveda/services/social_auth_service.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailField = TextEditingController();
  TextEditingController passwordField = TextEditingController();
  late FocusNode _emailFocusNode;
  late FocusNode _passwordFocusNode;

  @override
  void initState() {
    super.initState();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _focusOnEmail() {
    FocusScope.of(context).requestFocus(_emailFocusNode);
  }

  void _focusOnPassword() {
    FocusScope.of(context).requestFocus(_passwordFocusNode);
  }

  final _formKey = GlobalKey<FormState>();
  bool _isloading = false;
  bool _obscurePassword = true;
  bool _socialLoading = false;

  Future<void> _handleSocialLogin(Future<SocialAuthResult> Function() signInMethod) async {
    setState(() => _socialLoading = true);

    final result = await signInMethod();

    if (!mounted) return;
    setState(() => _socialLoading = false);

    if (result.success && result.userData != null) {
      await Provider.of<UserState>(context, listen: false).login(result.userData!);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const Account()),
        (route) => false,
      );
    } else if (result.needsMoreInfo) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SocialLoginComplete(
            provider: result.provider!,
            providerId: result.providerId!,
            email: result.email,
            firstName: result.firstName,
            lastName: result.lastName,
            profileImageUrl: result.profileImageUrl,
            needsEmail: result.needsEmail,
            needsName: result.needsName,
          ),
        ),
      );
    } else if (result.errorMessage != null && result.errorMessage != 'Sign in cancelled.') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.errorMessage!)),
      );
    }
  }

  Widget _socialIconButton(String asset, VoidCallback onTap) {
    return GestureDetector(
      onTap: _socialLoading ? null : onTap,
      child: Image.asset(asset, width: 40.0, height: 40.0, fit: BoxFit.contain),
    );
  }

  Future _login() async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      setState(() {
        _isloading = true;
      });
      final username = emailField.text;
      final password = passwordField.text;

      if (username == "") {
        _focusOnEmail();
        setState(() {
          _isloading = false;
        });
        return false;
      }

      if (password == "") {
        _focusOnPassword();
        setState(() {
          _isloading = false;
        });
        return false;
      }

      try {
        final response = await http.post(
          Uri.parse(loginApi),
          headers: <String, String>{
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'email': username,
            'password': password,
          }),
        );

        if (!mounted) return;

        setState(() {
          _isloading = false;
        });

        final loginresponse = jsonDecode(response.body);
        if (response.statusCode == 200 && loginresponse['status'] == 1) {
          await Provider.of<UserState>(context, listen: false).login(loginresponse);
          if (!mounted) return;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const Account()),
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loginresponse['message'] ?? 'Invalid email or password.'),
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isloading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connection error. Please try again.')),
        );
      }
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
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Login",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 26.0,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8.0),
                const Text(
                  "Please sign in to continue",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20.0),
                TextField(
                  focusNode: _emailFocusNode,
                  controller: emailField,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 0, right: 10.0),
                      child: Icon(Icons.email_outlined),
                    ),
                    hintText: 'Email Address',
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                    prefixIconConstraints: BoxConstraints(
                      minWidth: 0,
                      minHeight: 0,
                    ),
                  ),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 17.0,
                  ),
                ),
                const SizedBox(height: 10.0),
                TextField(
                  focusNode: _passwordFocusNode,
                  controller: passwordField,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(left: 0, right: 10.0),
                      child: Icon(Icons.lock),
                    ),
                    hintText: 'Password',
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 0,
                      minHeight: 0,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 17.0,
                  ),
                ),
                const SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () => {_login()},
                      style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Color(0xfff7770f)),
                        foregroundColor: WidgetStatePropertyAll(Colors.white),
                        shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30.0)),
                            side: BorderSide(
                              color: Color(0xfff7770f),
                            ),
                          ),
                        ),
                        minimumSize: WidgetStatePropertyAll(Size(140.0, 50.0)),
                      ),
                      child: _isloading
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 18.0,
                                  height: 18.0,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.0,
                                  ),
                                ),
                                SizedBox(width: 8.0),
                                Text(
                                  "Processing...",
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            )
                          : const Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 17.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                    GestureDetector(
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: Color(0xfff7770f),
                          fontSize: 15.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 24.0),
                Row(
                  children: [
                    const Expanded(child: Divider(color: Colors.black26)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(color: Colors.black26)),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _socialIconButton('assets/images/google.png', () => _handleSocialLogin(SocialAuthService.signInWithGoogle)),
                    const SizedBox(width: 20.0),
                    _socialIconButton('assets/images/facebook.png', () => _handleSocialLogin(SocialAuthService.signInWithFacebook)),
                    if (Platform.isIOS) ...[
                      const SizedBox(width: 20.0),
                      _socialIconButton('assets/images/apple.png', () => _handleSocialLogin(SocialAuthService.signInWithApple)),
                    ],
                  ],
                ),
                if (_socialLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Center(
                      child: SizedBox(
                        width: 24.0,
                        height: 24.0,
                        child: CircularProgressIndicator(color: Color(0xfff7770f), strokeWidth: 2.0),
                      ),
                    ),
                  ),
                const SizedBox(height: 24.0),
                Row(
                  children: [
                    const Text(
                      "Dont have an account?",
                      style: TextStyle(
                        color: Color(0xff000000),
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 5.0),
                    GestureDetector(
                      onTap: () => {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const Signup(),
                          ),
                        )
                      },
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Color(0xfff7770f),
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
