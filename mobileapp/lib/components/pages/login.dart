import 'package:provider/provider.dart';
import 'package:ayurveda/components/pages/account.dart';
import 'package:ayurveda/components/pages/signup.dart';
import 'package:ayurveda/constants/apis.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ayurveda/models/user.dart';

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
            'username': username,
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
                  decoration: const InputDecoration(
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 0, right: 10.0),
                      child: Icon(Icons.person),
                    ),
                    hintText: 'Email address',
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
                const SizedBox(height: 40.0),
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
