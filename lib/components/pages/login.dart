import 'package:ayurveda/components/pages/home.dart';
import 'package:ayurveda/components/pages/signup.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailField = TextEditingController();
  TextEditingController passwordField = TextEditingController();

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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              const Text(
                "Login",
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
                "Please sign in to continue",
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () => {},
                    style: const ButtonStyle(
                      backgroundColor:
                          WidgetStatePropertyAll(Color(0xfff7770f)),
                      foregroundColor: WidgetStatePropertyAll(Colors.white),
                      shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                          side: BorderSide(
                            color: Color(0xfff7770f),
                          ),
                        ),
                      ),
                      minimumSize: WidgetStatePropertyAll(Size(140.0, 55.0)),
                    ),
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  GestureDetector(
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: Color(0xfff7770f),
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 60.0,
              ),
              Row(
                children: [
                  const Text(
                    "Dont have an account?",
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
                          builder: (context) => const Signup(),
                        ),
                      )
                    },
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                        color: Color(0xfff7770f),
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 30.0,
              ),
              GestureDetector(
                onTap: () => {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const Home(),
                    ),
                  )
                },
                child: const Text(
                  "Skip to home",
                  style: TextStyle(
                    color: Color(0xfff7770f),
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    ));
  }
}
