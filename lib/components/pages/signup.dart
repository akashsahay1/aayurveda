import 'package:ayurveda/components/pages/login.dart';
import 'package:ayurveda/constants/apis.dart';
import 'package:ayurveda/constants/texts.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController fullName = TextEditingController();
  final TextEditingController emailField = TextEditingController();
  final TextEditingController passwordField = TextEditingController();
  final TextEditingController cpasswordField = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      final Map<String, String> data = {
        'signup': '1',
        'fullname': fullName.text,
        'username': Uri.encodeQueryComponent(emailField.text),
        'password': Uri.encodeQueryComponent(passwordField.text),
      };

      final response = await http.post(
        Uri.parse(ajaxApi),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: data,
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final responseData = response.body;
        if (responseData.isNotEmpty) {
          final signupresponse = jsonDecode(responseData);
          if (signupresponse['status'] == 1) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  icon: const Icon(Icons.check),
                  iconColor: const Color(0xfff7770f),
                  title: const Text("Account Created Successfully"),
                  content: const Text(
                    "Thank you for creating your account with us, please login to continue.",
                    textAlign: TextAlign.center,
                  ),
                  actionsAlignment: MainAxisAlignment.center,
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const Login(),
                          ),
                        );
                      },
                      style: const ButtonStyle(
                        backgroundColor:
                            WidgetStatePropertyAll(Color(0xfff7770f)),
                        foregroundColor: WidgetStatePropertyAll(Colors.white),
                        shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(30.0)),
                            side: BorderSide(
                              color: Color(0xfff7770f),
                            ),
                          ),
                        ),
                        minimumSize: WidgetStatePropertyAll(Size(140.0, 55.0)),
                      ),
                      child: const Text(
                        AppStrings.btngetStarted,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'OpenSans',
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                    )
                  ],
                );
              },
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No data returned from API')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create account')),
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
          child: Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  const Text(
                    "Create Account",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 26.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  const Text(
                    "Please sign up to continue",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 17.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  TextField(
                    controller: fullName,
                    decoration: const InputDecoration(
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(
                          left: 0,
                          right: 10.0,
                        ),
                        child: Icon(Icons.face),
                      ),
                      hintText: 'Full Name',
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10,
                      ),
                      prefixIconConstraints: BoxConstraints(
                        minWidth: 0,
                        minHeight: 0,
                      ),
                    ),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  TextField(
                    controller: emailField,
                    decoration: const InputDecoration(
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(
                          left: 0,
                          right: 10.0,
                        ),
                        child: Icon(Icons.person),
                      ),
                      hintText: 'Username',
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10,
                      ),
                      prefixIconConstraints: BoxConstraints(
                        minWidth: 0,
                        minHeight: 0,
                      ),
                    ),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  TextField(
                    controller: passwordField,
                    obscureText: true,
                    decoration: const InputDecoration(
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(
                          left: 0,
                          right: 10.0,
                        ),
                        child: Icon(Icons.lock),
                      ),
                      hintText: 'Password',
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10,
                      ), // Adjust vertical padding as needed
                      prefixIconConstraints: BoxConstraints(
                        minWidth: 0, // Remove minimum width constraint
                        minHeight: 0,
                      ),
                    ),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  TextField(
                    controller: cpasswordField,
                    obscureText: true,
                    decoration: const InputDecoration(
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(
                          left: 0,
                          right: 10.0,
                        ),
                        child: Icon(Icons.lock),
                      ),
                      hintText: 'Confirm password',
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10,
                      ), // Adjust vertical padding as needed
                      prefixIconConstraints: BoxConstraints(
                        minWidth: 0, // Remove minimum width constraint
                        minHeight: 0,
                      ),
                    ),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                    ),
                  ),
                  const SizedBox(
                    height: 30.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () => {
                          _signup(),
                        },
                        style: const ButtonStyle(
                          backgroundColor:
                              WidgetStatePropertyAll(Color(0xfff7770f)),
                          foregroundColor: WidgetStatePropertyAll(Colors.white),
                          shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30.0)),
                              side: BorderSide(
                                color: Color(0xfff7770f),
                              ),
                            ),
                          ),
                          minimumSize:
                              WidgetStatePropertyAll(Size(140.0, 55.0)),
                        ),
                        child: const Text(
                          "Create account",
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 40.0,
                  ),
                  Row(
                    children: [
                      const Text(
                        "Already have an account?",
                        style: TextStyle(
                          color: Color(0xff000000),
                          fontSize: 18.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(
                        width: 5.0,
                      ),
                      GestureDetector(
                        onTap: () => {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const Login(),
                            ),
                          )
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            color: Color(0xfff7770f),
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
