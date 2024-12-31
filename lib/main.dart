import 'package:flutter/material.dart';
import './constants/texts.dart';
import './components/pages/home.dart';

void main() {
  runApp(
    MaterialApp(
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: true,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xfff7770f),
        ),
        useMaterial3: true,
      ),
      home: const Home(), 
    ),
  );
}
