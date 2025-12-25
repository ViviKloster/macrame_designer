import 'package:flutter/material.dart';
import 'package:macrame_designer/features/designer/screens/designer_screen.dart';
import 'package:macrame_designer/features/patterns/screens/patterns_screen.dart';

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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B4513),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF8B4513),
          foregroundColor: Colors.white,
          elevation: 4,
          centerTitle: true,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF8B4513),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B4513),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF8B4513),
            side: const BorderSide(color: Color(0xFF8B4513)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B4513),
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF5D2906),
          elevation: 4,
        ),
      ),
      themeMode: ThemeMode.light,
      home: const HomeScreen(), // Cambiado a HomeScreen
      routes: {
        '/designer': (context) => const DesignerScreen(),
        '/patterns': (context) => const PatternsScreen(),
      },
    );
  }
}

// Pantalla de inicio con navegación
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Lista de pantallas
  static final List<Widget> _screens = [
    const DesignerScreen(),
    const PatternsScreen(),
  ];

  // Lista de títulos para AppBar
  static final List<String> _titles = [
    'Diseñador de Macramé',
    'Patrones Prediseñados',
  ];

  // Lista de items para BottomNavigationBar
  static final List<BottomNavigationBarItem> _navItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.edit),
      label: 'Diseñador',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.workspaces_filled),
      label: 'Patrones',
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
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: _selectedIndex == 0 
            ? [
                // Acciones específicas para el diseñador
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: () {
                    // Acción de guardar
                  },
                  tooltip: 'Guardar diseño',
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    // Acción de compartir
                  },
                  tooltip: 'Compartir',
                ),
              ]
            : [
                // Acciones específicas para patrones
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    // Acción de búsqueda
                  },
                  tooltip: 'Buscar patrones',
                ),
                IconButton(
                  icon: const Icon(Icons.filter_alt),
                  onPressed: () {
                    // Acción de filtro
                  },
                  tooltip: 'Filtrar',
                ),
              ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: _navItems,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF8B4513),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        backgroundColor: Theme.of(context).cardColor,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}