class AppStrings {
  static const String appTitle = "Ayurveda";
  static const String catTitle = "Categories";
  static const String welcomeMessage = 'Welcome to Ayurveda';
  static const String buttonText = 'Click Me';
  static const String btngetStarted = 'Get Started';
  static const String errorText = 'An error occurred';
}

class AppCategories {
  static Map<String, String> categories = {
    "cat1": "Rasayana Chikitsa",
    "cat2": "Panchakarma",
    "cat3": "Swasthavritta",
    "cat4": "Rasashastra",
    "cat5": "Bhootavidya",
    "cat6": "Lepa",
    "cat7": "Bhaishajya Kalpana",
    "cat8": "Balachikitsa",
    "cat9": "Vajikarana",
    "cat10": "Nadi Pariksha",
    "cat11": "Graha Chikitsa",
    "cat12": "Jara Chikitsa",
  };
}

class AppDisclaimers {
  static const String disclaimerTitle = 'Medical Disclaimer';

  static const String fullDisclaimer =
      '''The content provided in this application, including information about Ayurvedic treatments such as Panchakarma, Rasashastra, Balachikitsa (pediatric care), Bhootavidya (mental health), Vajikarana, herbal remedies, home remedies, yoga practices, and all other health-related topics, is intended for general informational and educational purposes only.

This app does not provide medical advice, diagnosis, or treatment. The information presented should not be used as a substitute for professional medical advice from a qualified healthcare provider.

Always consult with a licensed physician or other qualified healthcare professional before starting any new treatment, medication, diet, exercise program, or health regimen. Never disregard professional medical advice or delay seeking it because of something you have read in this application.

If you are experiencing a medical emergency, call your local emergency services immediately.

The content in this app is sourced from publicly available references including Wikipedia and other educational resources. While we strive to present accurate information, we make no warranties about the completeness, reliability, or accuracy of this information.

Some content in this app discusses health topics including psychiatric treatments and reproductive health. This content is intended for adult users (18+). By accepting this disclaimer, you confirm that you are at least 18 years of age.

The developers and publishers of this application assume no liability for any injury, loss, or damage incurred as a result of using the information provided herein.''';

  static const String shortDisclaimer = 'Disclaimer: This content is for informational purposes only and is not medical advice. Consult a healthcare professional before acting on any information.';
}

class AppPrivacyText {
  static const String title = 'Privacy Policy';
  static const String lastUpdated = 'Last updated: February 2026';

  static const List<Map<String, String>> sections = [
    {
      'heading': 'Information We Collect',
      'body': 'When you create an account, we collect your full name, username, and password. Your password is securely stored and never shared. We also collect basic device information necessary for app functionality.',
    },
    {
      'heading': 'How We Use Your Information',
      'body': 'We use your information to provide and maintain your account, enable features such as liking and bookmarking articles, and improve the app experience. We do not sell your personal information to third parties.',
    },
    {
      'heading': 'Data Storage and Security',
      'body': 'Your account data is stored on our servers at aayurveda.stime.in and transmitted via HTTPS encryption. Authentication tokens are stored securely on your device using platform-native secure storage (Keychain on iOS, EncryptedSharedPreferences on Android).',
    },
    {
      'heading': 'Third-Party Services',
      'body': 'This app connects to our WordPress-based backend (aayurveda.stime.in) for content delivery and user authentication. Images are cached locally on your device for performance. We do not integrate third-party analytics or advertising services.',
    },
    {
      'heading': 'Data Retention',
      'body': 'We retain your account data for as long as your account is active. Bookmarks are stored locally on your device and are not transmitted to our servers.',
    },
    {
      'heading': 'Your Rights',
      'body': 'You have the right to access, update, or request deletion of your personal data. To request account deletion, please contact us using the information below. You may also log out at any time to remove locally stored authentication data.',
    },
    {
      'heading': "Children's Privacy",
      'body': 'This app is not directed at children under the age of 13. We do not knowingly collect personal information from children under 13. If you are a parent or guardian and believe your child has provided us with personal information, please contact us.',
    },
    {
      'heading': 'Changes to This Policy',
      'body': 'We may update this Privacy Policy from time to time. Changes will be reflected in the app with an updated "Last updated" date. Continued use of the app after changes constitutes acceptance of the revised policy.',
    },
    {
      'heading': 'Contact Us',
      'body': 'If you have questions about this Privacy Policy or wish to exercise your data rights, please contact us at: support@aayurveda.stime.in',
    },
  ];
}

class AppTermsText {
  static const String title = 'Terms of Service';
  static const String lastUpdated = 'Last updated: February 2026';

  static const List<Map<String, String>> sections = [
    {
      'heading': 'Acceptance of Terms',
      'body': 'By creating an account or using the Aayurveda app, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the app.',
    },
    {
      'heading': 'Description of Service',
      'body': 'Aayurveda is a mobile application that provides educational and informational content about Ayurvedic health and wellness practices. Content is sourced from publicly available references and is intended for general knowledge purposes only.',
    },
    {
      'heading': 'Medical Disclaimer',
      'body': 'The content in this app is NOT medical advice. It is for informational and educational purposes only. Always consult a qualified healthcare professional before making health-related decisions. See the full Medical Disclaimer for details.',
    },
    {
      'heading': 'User Accounts',
      'body': 'You are responsible for maintaining the confidentiality of your account credentials. You agree to provide accurate information when creating an account and to notify us of any unauthorized use of your account.',
    },
    {
      'heading': 'Acceptable Use',
      'body': 'You agree to use the app only for its intended purpose of accessing health and wellness information. You may not attempt to disrupt the app services, reverse-engineer the app, or use automated systems to access the content.',
    },
    {
      'heading': 'Intellectual Property',
      'body': 'All content, design, and branding in the app are the property of Aayurveda or its content licensors. Article content is sourced from cited references. You may not reproduce, distribute, or create derivative works from the app content without permission.',
    },
    {
      'heading': 'Limitation of Liability',
      'body': 'To the maximum extent permitted by law, Aayurveda and its developers shall not be liable for any indirect, incidental, special, or consequential damages arising from your use of the app or reliance on its content.',
    },
    {
      'heading': 'Termination',
      'body': 'We reserve the right to suspend or terminate your account at any time for violation of these terms. You may delete your account at any time by contacting us.',
    },
    {
      'heading': 'Changes to Terms',
      'body': 'We may update these Terms of Service from time to time. Continued use of the app after changes constitutes acceptance of the revised terms.',
    },
    {
      'heading': 'Contact',
      'body': 'For questions about these Terms of Service, please contact us at: support@aayurveda.stime.in',
    },
  ];
}
