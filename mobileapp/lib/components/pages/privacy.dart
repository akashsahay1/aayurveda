import 'package:flutter/material.dart';
import '../../constants/texts.dart';
import '../common/appbar.dart';
import '../common/bottombar.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Appbar(title: AppPrivacyText.title),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppPrivacyText.lastUpdated,
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 20.0),
              ...AppPrivacyText.sections.map((section) => Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section['heading']!,
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      section['body']!,
                      style: const TextStyle(
                        fontSize: 16.0,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const Bottombar(currentIndex: 2),
    );
  }
}
