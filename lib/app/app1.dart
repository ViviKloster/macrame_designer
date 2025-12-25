import 'package:flutter/material.dart';
import 'package:macrame_designer/features/designer/screens/designer_screen.dart';

class AppScreen extends StatefulWidget {
  const AppScreen({super.key});

  @override
  State<AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DesignerScreen(),
    Container(color: Colors.blue, child: const Center(child: Text('Galería (en desarrollo)'))),
    Container(color: Colors.green, child: const Center(child: Text('Tienda (en desarrollo)'))),
    Container(color: Colors.orange, child: const Center(child: Text('Perfil (en desarrollo)'))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.design_services),
            label: 'Diseñar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: 'Galería',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Tienda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}