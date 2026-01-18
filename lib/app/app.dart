import 'package:flutter/material.dart';
import 'package:macrame_designer/app/theme.dart';
import 'package:macrame_designer/features/designer/screens/designer_screen.dart';
import 'package:macrame_designer/features/patterns/screens/app_store_patterns_screen.dart';


class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int _selectedIndex = 0;

  static final List<Widget> _screens = [
    const DesignerScreen(),
    const AppStorePatternsScreen(),
    Scaffold(
      body: Center(
        child: Text(
          'Galería',
          style: TextStyle(fontSize: 24),
        ),
      ),
    ),
    Scaffold(
      body: Center(
        child: Text(
          'Perfil',
          style: TextStyle(fontSize: 24),
        ),
      ),
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.primary,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.design_services),
            label: 'Diseñar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pattern),
            label: 'Patrones',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: 'Galería',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Acción para crear nuevo diseño
        },
        backgroundColor: AppTheme.secondaryColor,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}