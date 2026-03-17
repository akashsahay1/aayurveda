import 'dart:io';
import 'package:provider/provider.dart';
import 'package:ayurveda/components/pages/account.dart';
import 'package:ayurveda/components/pages/login.dart';
import 'package:ayurveda/components/pages/privacy.dart';
import 'package:ayurveda/components/pages/social_login_complete.dart';
import 'package:ayurveda/components/pages/terms.dart';
import 'package:ayurveda/constants/apis.dart';
import 'package:ayurveda/constants/texts.dart';
import 'package:ayurveda/models/user.dart';
import 'package:ayurveda/services/social_auth_service.dart';
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
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptedPrivacy = false;
  bool _acceptedTerms = false;
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

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      if (passwordField.text != cpasswordField.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match.')),
        );
        return;
      }

      setState(() {
        _isloading = true;
      });

      try {
        final response = await http.post(
          Uri.parse(signupApi),
          headers: <String, String>{
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'fullname': fullName.text,
            'email': emailField.text.trim(),
            'password': passwordField.text,
          }),
        );

        if (!mounted) return;

        setState(() {
          _isloading = false;
        });

        final signupresponse = jsonDecode(response.body);

        if (response.statusCode == 201 && signupresponse['status'] == 1) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return OrientationBuilder(
                builder: (context, orientation) {
                  return Dialog(
                    insetPadding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 24.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Container(
                      width: orientation == Orientation.portrait
                          ? MediaQuery.of(context).size.width * 0.9
                          : MediaQuery.of(context).size.width * 0.7,
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.8,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Center(
                                      child: Container(
                                        padding: const EdgeInsets.all(8.0),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: const Color(0xfff7770f),
                                            width: 2.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(50.0),
                                        ),
                                        child: const Icon(
                                          Icons.check,
                                          size: 35.0,
                                          color: Color(0xfff7770f),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(top: 15.0),
                                    child: Text(
                                      "Account Created Successfully",
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        RichText(
                                          textAlign: TextAlign.center,
                                          text: const TextSpan(
                                            style: TextStyle(
                                              fontSize: 17.0,
                                              color: Colors.black,
                                            ),
                                            children: <TextSpan>[
                                              TextSpan(
                                                text:
                                                    "Thank you for creating your account with us! ",
                                              ),
                                              TextSpan(
                                                text:
                                                    "We're thrilled to have you on board. ",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              TextSpan(
                                                text:
                                                    "Please take a moment to log in and set up your new account.",
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 20.0),
                                        const Text(
                                          "By doing so, you'll be able to personalize your experience and start adding your favorite items to your custom list.",
                                          style: TextStyle(fontSize: 17.0),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 20.0),
                                        const Text(
                                          "We're committed to making your journey with us enjoyable and tailored to your preferences. Welcome to our community!",
                                          style: TextStyle(fontSize: 17.0),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const Login(),
                                  ),
                                );
                              },
                              style: ButtonStyle(
                                backgroundColor: const WidgetStatePropertyAll(
                                    Color(0xfff7770f)),
                                foregroundColor: const WidgetStatePropertyAll(
                                    Colors.white),
                                shape: WidgetStatePropertyAll<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                    side: const BorderSide(
                                      color: Color(0xfff7770f),
                                    ),
                                  ),
                                ),
                                minimumSize: const WidgetStatePropertyAll(
                                  Size(140.0, 55.0),
                                ),
                              ),
                              child: const Text(
                                AppStrings.btngetStarted,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  signupresponse['message'] ?? 'Failed to create account.'),
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isloading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Connection error. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canSubmit = _acceptedPrivacy && _acceptedTerms;

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
                  const SizedBox(height: 10.0),
                  const Text(
                    "Please sign up to continue",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 17.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  TextField(
                    controller: fullName,
                    decoration: const InputDecoration(
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(left: 0, right: 10.0),
                        child: Icon(Icons.face),
                      ),
                      hintText: 'Full Name',
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                      prefixIconConstraints:
                          BoxConstraints(minWidth: 0, minHeight: 0),
                    ),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 17.0,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  TextFormField(
                    controller: emailField,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email address is required';
                      }
                      final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                      if (!emailRegex.hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(left: 0, right: 10.0),
                        child: Icon(Icons.email_outlined),
                      ),
                      hintText: 'Email Address',
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                      prefixIconConstraints:
                          BoxConstraints(minWidth: 0, minHeight: 0),
                    ),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 17.0,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  TextField(
                    controller: passwordField,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(left: 0, right: 10.0),
                        child: Icon(Icons.lock),
                      ),
                      hintText: 'Password',
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      prefixIconConstraints:
                          const BoxConstraints(minWidth: 0, minHeight: 0),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 17.0,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  TextField(
                    controller: cpasswordField,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(left: 0, right: 10.0),
                        child: Icon(Icons.lock),
                      ),
                      hintText: 'Confirm password',
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      prefixIconConstraints:
                          const BoxConstraints(minWidth: 0, minHeight: 0),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),
                    ),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 17.0,
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  // Privacy Policy consent
                  Row(
                    children: [
                      Checkbox(
                        value: _acceptedPrivacy,
                        onChanged: (value) =>
                            setState(() => _acceptedPrivacy = value ?? false),
                        activeColor: const Color(0xfff7770f),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const PrivacyPolicy()),
                          ),
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                  color: Colors.black, fontSize: 14.0),
                              children: [
                                TextSpan(text: 'I agree to the '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(
                                    color: Color(0xfff7770f),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Terms of Service consent
                  Row(
                    children: [
                      Checkbox(
                        value: _acceptedTerms,
                        onChanged: (value) =>
                            setState(() => _acceptedTerms = value ?? false),
                        activeColor: const Color(0xfff7770f),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const TermsOfService()),
                          ),
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                  color: Colors.black, fontSize: 14.0),
                              children: [
                                TextSpan(text: 'I agree to the '),
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: TextStyle(
                                    color: Color(0xfff7770f),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: canSubmit ? () => _signup() : null,
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                            canSubmit
                                ? const Color(0xfff7770f)
                                : const Color(0xfff7770f).withValues(alpha: 0.5),
                          ),
                          foregroundColor:
                              const WidgetStatePropertyAll(Colors.white),
                          shape:
                              const WidgetStatePropertyAll<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30.0)),
                              side: BorderSide(
                                color: Color(0xfff7770f),
                              ),
                            ),
                          ),
                          minimumSize: const WidgetStatePropertyAll(
                              Size(140.0, 55.0)),
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
                                  SizedBox(width: 10.0),
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
                        "Already have an account?",
                        style: TextStyle(
                          color: Color(0xff000000),
                          fontSize: 18.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 5.0),
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const Login(),
                          ),
                        ),
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
