import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ayurveda/models/user.dart';
import 'package:ayurveda/components/pages/disclaimer.dart';

void main() {
  testWidgets('Disclaimer page renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => UserState(),
        child: const MaterialApp(
          home: Disclaimer(),
        ),
      ),
    );

    expect(find.text('Medical Disclaimer'), findsOneWidget);
    expect(find.text('Please Read Before Continuing'), findsOneWidget);
    expect(find.text('I Understand and Accept'), findsOneWidget);
  });
}
