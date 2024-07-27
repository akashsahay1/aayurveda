import 'package:flutter/material.dart';
import './constants/texts.dart';
import './components/pages/home.dart';

void main() {
  runApp(
    MaterialApp(
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 252, 166, 8),
        ),
        useMaterial3: true,
      ),
      home: const Home(),
    ),
  );
}
