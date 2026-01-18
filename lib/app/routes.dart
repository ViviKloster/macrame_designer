import 'package:flutter/material.dart';
import 'package:macrame_designer/features/designer/screens/designer_screen.dart';
import 'package:macrame_designer/features/patterns/screens/patterns_screen.dart';
import 'package:macrame_designer/features/patterns/screens/pattern_detail_screen.dart';
import 'package:macrame_designer/features/patterns/models/pattern_model.dart';

class Routes {
  static const String designer = '/designer';
  static const String patterns = '/patterns';
  static const String patternDetail = '/pattern-detail';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case designer:
        return _fadeRoute(const DesignerScreen(), settings);
      case patterns:
        return _fadeRoute(const PatternsScreen(), settings);
      case patternDetail:
        // Asegúrate de que el argumento sea PatternDesign
        final pattern = settings.arguments as PatternDesign;
        return _fadeRoute(
          PatternDetailScreen(pattern: pattern),
          settings,
        );
      default:
        return _fadeRoute(
          Scaffold(
            body: Center(
              child: Text('Ruta ${settings.name} no encontrada'),
            ),
          ),
          settings,
        );
    }
  }

  static PageRouteBuilder _fadeRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}