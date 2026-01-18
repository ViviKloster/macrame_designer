import 'package:flutter/material.dart';
import 'package:macrame_designer/app/app.dart';
import 'package:macrame_designer/app/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Macrame Designer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const App(), // Usamos App como home
    );
  }
}