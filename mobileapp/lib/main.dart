import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './models/user.dart';
import './constants/texts.dart';
import './components/pages/home.dart';
import './components/pages/disclaimer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final userState = UserState();
  await userState.initializeState();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: userState),
      ],
      child: MaterialApp(
        title: AppStrings.appTitle,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xfff7770f),
          ),
          useMaterial3: true,
          fontFamily: 'OpenSans',
          textTheme: const TextTheme(
            displayLarge: TextStyle(letterSpacing: 0),
            displayMedium: TextStyle(letterSpacing: 0),
            displaySmall: TextStyle(letterSpacing: 0),
            headlineLarge: TextStyle(letterSpacing: 0),
            headlineMedium: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w700, letterSpacing: 0),
            headlineSmall: TextStyle(letterSpacing: 0),
            titleLarge: TextStyle(letterSpacing: 0),
            titleMedium: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600, letterSpacing: 0),
            titleSmall: TextStyle(letterSpacing: 0),
            bodyLarge: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w400, letterSpacing: 0),
            bodyMedium: TextStyle(letterSpacing: 0),
            bodySmall: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w400, letterSpacing: 0),
            labelLarge: TextStyle(letterSpacing: 0),
            labelMedium: TextStyle(letterSpacing: 0),
            labelSmall: TextStyle(letterSpacing: 0),
          ),
        ),
        home: const DisclaimerGate(),
      ),
    )
  );
}

class DisclaimerGate extends StatelessWidget {
  const DisclaimerGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: SharedPreferences.getInstance().then(
        (prefs) => prefs.getBool('hasAcceptedDisclaimer') ?? false,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xfff7770f),
              ),
            ),
          );
        }
        if (snapshot.data == true) {
          return const Home();
        }
        return const Disclaimer();
      },
    );
  }
}
