import 'package:flutter/material.dart';
import 'package:macrame_designer/app/routes.dart';
import 'package:macrame_designer/app/theme.dart';

class MacrameDesignerApp extends StatelessWidget {
  const MacrameDesignerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Macrame Designer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}