import 'package:flutter/material.dart';
import 'package:macrame_designer/features/designer/screens/designer_screen.dart';
import 'package:macrame_designer/features/patterns/screens/patterns_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String designer = '/designer';
  static const String patterns = '/patterns';
  
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case designer:
        return MaterialPageRoute(builder: (_) => const DesignerScreen());
      case patterns:
        return MaterialPageRoute(builder: (_) => const PatternsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route for ${settings.name}')),
          ),
        );
    }
  }
}

// Necesitamos declarar HomeScreen aquí temporalmente
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const DesignerScreen(),
    const PatternsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'Diseñador'),
          BottomNavigationBarItem(icon: Icon(Icons.workspaces_filled), label: 'Patrones'),
        ],
      ),
    );
  }
}