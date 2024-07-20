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
  bool _isloading = false;

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isloading = true;
      });

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

      setState(() {
        _isloading = false;
      });

      if (response.statusCode == 200) {
        final responseData = response.body;
        if (responseData.isNotEmpty) {
          final signupresponse = jsonDecode(responseData);
          if (signupresponse['status'] == 1) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  icon: Center(
                    child: Container(
                      padding: const EdgeInsets.all(
                          8.0), // Padding inside the border
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xfff7770f), // Border color
                          width: 2.0, // Border width
                        ),
                        borderRadius: BorderRadius.circular(
                            50.0), // Optional: Add rounded corners
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 35.0,
                        color: Color(0xfff7770f), // Icon color
                      ),
                    ),
                  ),
                  iconColor: const Color(0xfff7770f),
                  title: const Padding(
                    padding: EdgeInsets.only(top: 15.0),
                    child: Text("Account Created Successfully"),
                  ),
                  content: Padding(
                    padding: const EdgeInsets.only(
                      top: 20.0,
                      bottom: 20.0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 17.0,
                              color: Colors
                                  .black, // Make sure to set the default text color
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                  text:
                                      "Thank you for creating your account with us! "),
                              TextSpan(
                                text: "We're thrilled to have you on board. ",
                                style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold), // Bold this part
                              ),
                              TextSpan(
                                text:
                                    "Please take a moment to log in and set up your new account.",
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        const Text(
                          "By doing so, you'll be able to personalize your experience and start adding your favorite items to your custom list.",
                          style: TextStyle(
                            fontSize: 17.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        const Text(
                          "We're committed to making your journey with us enjoyable and tailored to your preferences. Welcome to our community!",
                          style: TextStyle(
                            fontSize: 17.0,
                          ),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
                  actionsAlignment: MainAxisAlignment.center,
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: ElevatedButton(
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
                          minimumSize:
                              WidgetStatePropertyAll(Size(140.0, 55.0)),
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
                      fontSize: 17.0,
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
                      fontSize: 17.0,
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
                      fontSize: 17.0,
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
                      fontSize: 17.0,
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
                        child: _isloading
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 20.0,
                                    height: 20.0,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.0,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Text(
                                    "Processing...",
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              )
                            : const Text(
                                "Create account",
                                style: TextStyle(
                                  fontSize: 17.0,
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
