import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/texts.dart';
import 'home.dart';

class Disclaimer extends StatelessWidget {
  const Disclaimer({super.key});

  Future<void> _accept(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasAcceptedDisclaimer', true);
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const Home()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          AppDisclaimers.disclaimerTitle,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xfff7770f),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.health_and_safety,
                      size: 48.0,
                      color: Color(0xfff7770f),
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'Please Read Before Continuing',
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Text(
                      AppDisclaimers.fullDisclaimer,
                      style: TextStyle(
                        fontSize: 16.0,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 20.0),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _accept(context),
                  style: const ButtonStyle(
                    backgroundColor:
                        WidgetStatePropertyAll(Color(0xfff7770f)),
                    foregroundColor: WidgetStatePropertyAll(Colors.white),
                    shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30.0)),
                      ),
                    ),
                    minimumSize: WidgetStatePropertyAll(Size(double.infinity, 55.0)),
                  ),
                  child: const Text(
                    'I Understand and Accept',
                    style: TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
