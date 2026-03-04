import 'package:flutter/material.dart';
import '../common/appbar.dart';
import '../common/bottombar.dart';
import 'privacy.dart';
import 'terms.dart';

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Appbar(title: 'About Us'),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'About Aayurveda',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 30.0,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 15.0),
                const Text(
                  'Aayurveda is a mobile app dedicated to sharing educational content about Ayurveda, the ancient Indian system of holistic health and wellness. Our goal is to make authentic Ayurvedic knowledge accessible to everyone in a convenient, easy-to-browse format.',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 15.0),
                const Text(
                  'The app provides curated articles across categories including home remedies, Ayurvedic medicines, yoga, daily fitness routines, beauty tips, herbal cures, and more. All content is sourced from publicly available references such as Wikipedia and other educational resources, and each article includes its source citation.',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 15.0),
                const Text(
                  'Important: The content in this app is for informational and educational purposes only. It is not intended as medical advice. Please consult a qualified healthcare professional before making any health-related decisions.',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16.0,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 30.0),
                const Divider(),
                const SizedBox(height: 15.0),
                const Text(
                  'Legal',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 22.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10.0),
                ListTile(
                  leading: const Icon(
                    Icons.privacy_tip,
                    color: Color(0xfff7770f),
                  ),
                  title: const Text(
                    'Privacy Policy',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Color(0xfff7770f),
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PrivacyPolicy(),
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.description,
                    color: Color(0xfff7770f),
                  ),
                  title: const Text(
                    'Terms of Service',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Color(0xfff7770f),
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TermsOfService(),
                    ),
                  ),
                ),
                const SizedBox(height: 15.0),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const Bottombar(currentIndex: 2),
    );
  }
}
