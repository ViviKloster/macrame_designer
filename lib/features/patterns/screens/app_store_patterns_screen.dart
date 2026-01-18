// lib/features/patterns/screens/appstore_patterns_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:macrame_designer/features/patterns/models/pattern_model.dart';
import 'package:macrame_designer/features/patterns/services/pattern_service.dart';
import 'package:macrame_designer/features/patterns/widgets/pattern_detail_dialog.dart';

class AppStorePatternsScreen extends StatefulWidget {
  const AppStorePatternsScreen({super.key});

  @override
  State<AppStorePatternsScreen> createState() => _AppStorePatternsScreenState();
}

class _AppStorePatternsScreenState extends State<AppStorePatternsScreen> {
  final PatternService _patternService = PatternService();
  List<PatternDesign> _patterns = [];
  bool _isLoading = true;
  String _selectedCategory = 'Todos';
  String _searchQuery = '';
  int _selectedSort = 0;
  
  // Sidebar state
  double _sidebarWidth = 240.0;

  // Categorías
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Todos', 'icon': Icons.grid_view, 'count': 0},
    {'name': 'Tapices', 'icon': Icons.wallpaper, 'count': 0},
    {'name': 'Decoración', 'icon': Icons.home, 'count': 0},
    {'name': 'Accesorios', 'icon': Icons.workspace_premium, 'count': 0},
    {'name': 'Plantillas', 'icon': Icons.description, 'count': 0},
  ];

  // Base de datos de trabajos
  final List<Map<String, dynamic>> _worksDatabase = [
    {
      'id': 'tapiz_angel',
      'name': 'Tapiz Ángel',
      'category': 'Tapices',
      'description': 'Diseño angelical con alas detalladas, perfecto para decoración de pared.',
      'difficulty': 'Intermedio',
      'difficultyLevel': 2,
      'time': '15-20 horas',
      'price': 29.99,
      'rating': 4.8,
      'images': [
        'assets/images/Tapiz_angel1.jpg',
        'assets/images/Tapiz_angel2.jpg',
        'assets/images/Tapiz_angel3.jpg',
      ],
      'materials': [
        {'name': 'Cordón de algodón 4mm', 'quantity': '150 metros', 'color': 'Blanco'},
        {'name': 'Anillo de madera', 'quantity': '1', 'size': '40cm diámetro'},
        {'name': 'Tijeras', 'quantity': '1'},
        {'name': 'Cinta métrica', 'quantity': '1'},
      ],
      'cordMeasurements': {
        'simple': [
          {'length': '2 metros', 'quantity': '20', 'purpose': 'Cuerdas principales'},
          {'length': '1.5 metros', 'quantity': '15', 'purpose': 'Cuerdas secundarias'},
          {'length': '1 metro', 'quantity': '10', 'purpose': 'Detalles'},
        ],
        'double': [
          {'length': '4 metros', 'quantity': '20', 'purpose': 'Cuerdas principales'},
          {'length': '3 metros', 'quantity': '15', 'purpose': 'Cuerdas secundarias'},
          {'length': '2 metros', 'quantity': '10', 'purpose': 'Detalles'},
        ],
      },
      'youtubeUrl': 'https://youtube.com/watch?v=ejemplo_angel',
      'steps': 8,
      'completedBy': 125,
    },
    {
      'id': 'tapiz_central',
      'name': 'Tapiz Central',
      'category': 'Tapices',
      'description': 'Diseño simétrico para pared, con patrones geométricos.',
      'difficulty': 'Intermedio',
      'difficultyLevel': 2,
      'time': '12-16 horas',
      'price': 24.99,
      'rating': 4.5,
      'images': [
        'assets/images/Tapiz_central1.jpg',
        'assets/images/tapiz_central2.jpg',
      ],
      'materials': [
        {'name': 'Cordón de algodón 5mm', 'quantity': '120 metros', 'color': 'Beige'},
        {'name': 'Barra de madera', 'quantity': '1', 'size': '50cm'},
        {'name': 'Tijeras', 'quantity': '1'},
        {'name': 'Peine', 'quantity': '1'},
      ],
      'cordMeasurements': {
        'simple': [
          {'length': '1.8 metros', 'quantity': '25', 'purpose': 'Cuerdas base'},
          {'length': '1.2 metros', 'quantity': '15', 'purpose': 'Patrones'},
        ],
        'double': [
          {'length': '3.6 metros', 'quantity': '25', 'purpose': 'Cuerdas base'},
          {'length': '2.4 metros', 'quantity': '15', 'purpose': 'Patrones'},
        ],
      },
      'youtubeUrl': 'https://youtube.com/watch?v=ejemplo_central',
      'steps': 6,
      'completedBy': 89,
    },
    {
      'id': 'centro_mesa',
      'name': 'Centro de Mesa',
      'category': 'Decoración',
      'description': 'Conjunto de tres piezas para decorar mesas de comedor.',
      'difficulty': 'Avanzado',
      'difficultyLevel': 3,
      'time': '20-25 horas',
      'price': 39.99,
      'rating': 4.9,
      'images': [
        'assets/images/Centro-de-mesa1.jpg',
        'assets/images/Centro_de_mesa2.jpg',
        'assets/images/Centro_de_mesa3.jpg',
      ],
      'materials': [
        {'name': 'Cordón de yute 3mm', 'quantity': '200 metros', 'color': 'Natural'},
        {'name': 'Aros metálicos', 'quantity': '3', 'size': '30cm, 25cm, 20cm'},
        {'name': 'Cuentas de madera', 'quantity': '50', 'size': '1cm'},
        {'name': 'Aguja de macramé', 'quantity': '1'},
      ],
      'cordMeasurements': {
        'simple': [
          {'length': '2.5 metros', 'quantity': '30', 'purpose': 'Base grande'},
          {'length': '2 metros', 'quantity': '25', 'purpose': 'Base mediana'},
          {'length': '1.5 metros', 'quantity': '20', 'purpose': 'Base pequeña'},
        ],
        'double': [
          {'length': '5 metros', 'quantity': '30', 'purpose': 'Base grande'},
          {'length': '4 metros', 'quantity': '25', 'purpose': 'Base mediana'},
          {'length': '3 metros', 'quantity': '20', 'purpose': 'Base pequeña'},
        ],
      },
      'youtubeUrl': 'https://youtube.com/watch?v=ejemplo_centro_mesa',
      'steps': 12,
      'completedBy': 67,
    },
    {
      'id': 'corazon',
      'name': 'Corazón',
      'category': 'Decoración',
      'description': 'Diseño romántico en forma de corazón, perfecto para regalos.',
      'difficulty': 'Principiante',
      'difficultyLevel': 1,
      'time': '8-10 horas',
      'price': 19.99,
      'rating': 4.7,
      'images': [
        'assets/images/Corazon2.jpg',
        'assets/images/Corazon3.jpg',
        'assets/images/Corazon4.jpg',
      ],
      'materials': [
        {'name': 'Cordón de algodón 4mm', 'quantity': '80 metros', 'color': 'Rojo'},
        {'name': 'Varilla de metal', 'quantity': '1', 'size': '35cm'},
        {'name': 'Tijeras', 'quantity': '1'},
        {'name': 'Regla', 'quantity': '1'},
      ],
      'cordMeasurements': {
        'simple': [
          {'length': '1.2 metros', 'quantity': '25', 'purpose': 'Contorno'},
          {'length': '0.8 metros', 'quantity': '15', 'purpose': 'Relleno'},
        ],
        'double': [
          {'length': '2.4 metros', 'quantity': '25', 'purpose': 'Contorno'},
          {'length': '1.6 metros', 'quantity': '15', 'purpose': 'Relleno'},
        ],
      },
      'youtubeUrl': 'https://youtube.com/watch?v=ejemplo_corazon',
      'steps': 5,
      'completedBy': 203,
    },
    {
      'id': 'girasol',
      'name': 'Girasol',
      'category': 'Decoración',
      'description': 'Representación de girasol con pétalos detallados.',
      'difficulty': 'Intermedio',
      'difficultyLevel': 2,
      'time': '14-18 horas',
      'price': 27.99,
      'rating': 4.6,
      'images': [
        'assets/images/Girasol1.jpg',
        'assets/images/Girasol2.jpg',
      ],
      'materials': [
        {'name': 'Cordón de algodón 4mm', 'quantity': '110 metros', 'color': 'Amarillo/Negro'},
        {'name': 'Aro de madera', 'quantity': '1', 'size': '35cm diámetro'},
        {'name': 'Tijeras', 'quantity': '1'},
        {'name': 'Pinzas', 'quantity': '1'},
      ],
      'cordMeasurements': {
        'simple': [
          {'length': '1.5 metros', 'quantity': '30', 'purpose': 'Pétalos'},
          {'length': '1 metro', 'quantity': '20', 'purpose': 'Centro'},
        ],
        'double': [
          {'length': '3 metros', 'quantity': '30', 'purpose': 'Pétalos'},
          {'length': '2 metros', 'quantity': '20', 'purpose': 'Centro'},
        ],
      },
      'youtubeUrl': 'https://youtube.com/watch?v=ejemplo_girasol',
      'steps': 7,
      'completedBy': 94,
    },
    {
      'id': 'almohadon',
      'name': 'Almohadón',
      'category': 'Decoración',
      'description': 'Funda decorativa para almohadón con textura de nudos.',
      'difficulty': 'Principiante',
      'difficultyLevel': 1,
      'time': '6-8 horas',
      'price': 17.99,
      'rating': 4.4,
      'images': [
        'assets/images/almohadon.jpg',
      ],
      'materials': [
        {'name': 'Cordón de algodón 5mm', 'quantity': '60 metros', 'color': 'Gris'},
        {'name': 'Almohadón relleno', 'quantity': '1', 'size': '40x40cm'},
        {'name': 'Tijeras', 'quantity': '1'},
        {'name': 'Aguja gruesa', 'quantity': '1'},
      ],
      'cordMeasurements': {
        'simple': [
          {'length': '2 metros', 'quantity': '15', 'purpose': 'Cubierta frontal'},
          {'length': '2 metros', 'quantity': '15', 'purpose': 'Cubierta trasera'},
        ],
        'double': [
          {'length': '4 metros', 'quantity': '15', 'purpose': 'Cubierta frontal'},
          {'length': '4 metros', 'quantity': '15', 'purpose': 'Cubierta trasera'},
        ],
      },
      'youtubeUrl': 'https://youtube.com/watch?v=ejemplo_almohadon',
      'steps': 4,
      'completedBy': 156,
    },
    {
      'id': 'banderin',
      'name': 'Banderín',
      'category': 'Decoración',
      'description': 'Guirnalda decorativa con formas triangulares.',
      'difficulty': 'Principiante',
      'difficultyLevel': 1,
      'time': '5-7 horas',
      'price': 14.99,
      'rating': 4.3,
      'images': [
        'assets/images/banderin.jpg',
      ],
      'materials': [
        {'name': 'Cordón de algodón 3mm', 'quantity': '50 metros', 'color': 'Multicolor'},
        {'name': 'Palito de madera', 'quantity': '1', 'size': '60cm'},
        {'name': 'Tijeras', 'quantity': '1'},
        {'name': 'Regla', 'quantity': '1'},
      ],
      'cordMeasurements': {
        'simple': [
          {'length': '0.8 metros', 'quantity': '20', 'purpose': 'Triángulos'},
          {'length': '1.5 metros', 'quantity': '1', 'purpose': 'Soporte'},
        ],
        'double': [
          {'length': '1.6 metros', 'quantity': '20', 'purpose': 'Triángulos'},
          {'length': '3 metros', 'quantity': '1', 'purpose': 'Soporte'},
        ],
      },
      'youtubeUrl': 'https://youtube.com/watch?v=ejemplo_banderin',
      'steps': 3,
      'completedBy': 112,
    },
    {
      'id': 'cartera_mano',
      'name': 'Cartera de Mano',
      'category': 'Accesorios',
      'description': 'Bolsillo tejido con asa, ideal para uso diario.',
      'difficulty': 'Intermedio',
      'difficultyLevel': 2,
      'time': '10-12 horas',
      'price': 22.99,
      'rating': 4.5,
      'images': [
        'assets/images/cartera_de_mano.jpg',
      ],
      'materials': [
        {'name': 'Cordón de cuero sintético', 'quantity': '40 metros', 'color': 'Marrón'},
        {'name': 'Cierre metálico', 'quantity': '1', 'size': '20cm'},
        {'name': 'Tijeras especiales', 'quantity': '1'},
        {'name': 'Pegamento textil', 'quantity': '1'},
      ],
      'cordMeasurements': {
        'simple': [
          {'length': '1.2 metros', 'quantity': '15', 'purpose': 'Cuerpo'},
          {'length': '0.8 metros', 'quantity': '5', 'purpose': 'Asa'},
        ],
        'double': [
          {'length': '2.4 metros', 'quantity': '15', 'purpose': 'Cuerpo'},
          {'length': '1.6 metros', 'quantity': '5', 'purpose': 'Asa'},
        ],
      },
      'youtubeUrl': 'https://youtube.com/watch?v=ejemplo_cartera',
      'steps': 6,
      'completedBy': 78,
    },
    {
      'id': 'flor_loto',
      'name': 'Flor de Loto',
      'category': 'Tapices',
      'description': 'Representación floral con pétalos superpuestos.',
      'difficulty': 'Avanzado',
      'difficultyLevel': 3,
      'time': '18-22 horas',
      'price': 34.99,
      'rating': 4.8,
      'images': [
        'assets/images/Tapiz_flor_de_loto.jpg',
      ],
      'materials': [
        {'name': 'Cordón de seda artificial', 'quantity': '180 metros', 'color': 'Rosa/Blanco'},
        {'name': 'Aro de metal', 'quantity': '1', 'size': '45cm diámetro'},
        {'name': 'Tijeras finas', 'quantity': '1'},
        {'name': 'Peine especial', 'quantity': '1'},
      ],
      'cordMeasurements': {
        'simple': [
          {'length': '2.2 metros', 'quantity': '25', 'purpose': 'Pétalos externos'},
          {'length': '1.8 metros', 'quantity': '20', 'purpose': 'Pétalos internos'},
          {'length': '1.2 metros', 'quantity': '15', 'purpose': 'Centro'},
        ],
        'double': [
          {'length': '4.4 metros', 'quantity': '25', 'purpose': 'Pétalos externos'},
          {'length': '3.6 metros', 'quantity': '20', 'purpose': 'Pétalos internos'},
          {'length': '2.4 metros', 'quantity': '15', 'purpose': 'Centro'},
        ],
      },
      'youtubeUrl': 'https://youtube.com/watch?v=ejemplo_flor_loto',
      'steps': 10,
      'completedBy': 45,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadPatterns();
  }

  Future<void> _loadPatterns() async {
    try {
      final patterns = await _patternService.getPatterns();
      setState(() {
        _patterns = patterns;
        _updateCategoryCounts();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateCategoryCounts() {
    for (var category in _categories) {
      final categoryName = category['name'] as String;
      if (categoryName == 'Todos') {
        category['count'] = _worksDatabase.length;
      } else {
        category['count'] = _worksDatabase.where((work) => work['category'] == categoryName).length;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Row(
          children: [
            // Sidebar de navegación
            _buildSidebar(),
            
            // Contenido principal
            Expanded(
              child: _buildMainContent(),
            ),
          ],
        ),
      ),
    );
  }

  // Sidebar
  Widget _buildSidebar() {
    return Container(
      width: _sidebarWidth,
      decoration: BoxDecoration(
        color: Color(0xFFF8F9FA),
        border: Border(
          right: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        children: [
          // Logo
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MACRAMÉ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2D3748),
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  'PROJECTS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4CAF50),
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          
          // Búsqueda
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar proyectos...',
                hintStyle: TextStyle(fontSize: 13),
                prefixIcon: Icon(Icons.search, size: 18),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // Filtros
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FILTRAR POR',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 12),
                ..._buildFilterChips(),
              ],
            ),
          ),
          
          // Categorías
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                Text(
                  'CATEGORÍAS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 12),
                ..._categories.map((category) => _buildCategoryItem(category)).toList(),
              ],
            ),
          ),
          
          // Estadísticas
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ESTADÍSTICAS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 12),
                _buildStatItem('Proyectos', '${_worksDatabase.length}'),
                _buildStatItem('Completados', '856'),
                _buildStatItem('Rating promedio', '4.7'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFilterChips() {
    final filters = [
      {'label': 'Principiante', 'color': Colors.green},
      {'label': 'Intermedio', 'color': Colors.orange},
      {'label': 'Avanzado', 'color': Colors.red},
      {'label': 'Menos de 10h', 'color': Colors.blue},
      {'label': 'Con video', 'color': Colors.purple},
    ];
    
    return filters.map((filter) {
      return Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: filter['color'] as Color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            SizedBox(width: 8),
            Text(
              filter['label'] as String,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildCategoryItem(Map<String, dynamic> category) {
    final isSelected = _selectedCategory == category['name'];
    final count = category['count'] as int;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category['name'] as String;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        margin: EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF4CAF50).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(
              category['icon'] as IconData,
              size: 16,
              color: isSelected ? Color(0xFF4CAF50) : Colors.grey.shade600,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                category['name'] as String,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Color(0xFF2D3748) : Colors.grey.shade700,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Color(0xFF4CAF50) : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
        ],
      ),
    );
  }

  // Contenido principal
  Widget _buildMainContent() {
    final filteredWorks = _getFilteredWorks();
    
    return Column(
      children: [
        // Barra superior
        Container(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedCategory == 'Todos' ? 'Todos los Proyectos' : _selectedCategory,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  Text(
                    '${filteredWorks.length} proyectos encontrados',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              
              Row(
                children: [
                  PopupMenuButton<int>(
                    onSelected: (value) {
                      setState(() {
                        _selectedSort = value;
                      });
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 0,
                        child: Text('Más populares', style: TextStyle(fontSize: 13)),
                      ),
                      PopupMenuItem(
                        value: 1,
                        child: Text('Dificultad: baja a alta', style: TextStyle(fontSize: 13)),
                      ),
                      PopupMenuItem(
                        value: 2,
                        child: Text('Tiempo: corto a largo', style: TextStyle(fontSize: 13)),
                      ),
                      PopupMenuItem(
                        value: 3,
                        child: Text('Precio: bajo a alto', style: TextStyle(fontSize: 13)),
                      ),
                    ],
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.sort, size: 16, color: Colors.grey.shade600),
                          SizedBox(width: 6),
                          Text(
                            'Ordenar',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(width: 12),
                  
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.grid_view, size: 20, color: Colors.grey.shade600),
                    tooltip: 'Vista de cuadrícula',
                  ),
                  
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.view_list, size: 20, color: Colors.grey.shade600),
                    tooltip: 'Vista de lista',
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Grid de proyectos
        Expanded(
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF4CAF50),
                    strokeWidth: 2,
                  ),
                )
              : ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                    },
                  ),
                  child: filteredWorks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No se encontraron proyectos',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: EdgeInsets.all(16),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: filteredWorks.length,
                          itemBuilder: (context, index) {
                            return _buildProjectCard(filteredWorks[index]);
                          },
                        ),
                ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getFilteredWorks() {
    List<Map<String, dynamic>> filtered = List.from(_worksDatabase);
    
    // Filtrar por categoría
    if (_selectedCategory != 'Todos') {
      filtered = filtered.where((work) => work['category'] == _selectedCategory).toList();
    }
    
    // Filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((work) =>
          work['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          work['description'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          work['category'].toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    
    // Ordenar
    switch (_selectedSort) {
      case 1: // Dificultad
        filtered.sort((a, b) => (a['difficultyLevel'] as int).compareTo(b['difficultyLevel'] as int));
        break;
      case 2: // Tiempo (estimado por dificultad)
        filtered.sort((a, b) => (a['difficultyLevel'] as int).compareTo(b['difficultyLevel'] as int));
        break;
      case 3: // Precio
        filtered.sort((a, b) => (a['price'] as double).compareTo(b['price'] as double));
        break;
      default: // Popularidad
        filtered.sort((a, b) => (b['completedBy'] as int).compareTo(a['completedBy'] as int));
        break;
    }
    
    return filtered;
  }

  Widget _buildProjectCard(Map<String, dynamic> work) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade100, width: 1),
      ),
      child: InkWell(
        onTap: () {
          _showProjectDetails(work);
        },
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                  image: DecorationImage(
                    image: AssetImage(work['images'].first),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    // Overlay para información
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.6),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildImageBadge(Icons.schedule, work['time']),
                            if (work['images'].length > 1)
                              _buildImageBadge(Icons.photo_library, '${work['images'].length}'),
                          ],
                        ),
                      ),
                    ),
                    
                    // Badge de dificultad
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getDifficultyColor(work['difficultyLevel'] as int),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          work['difficulty'],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Información
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    work['name'],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  SizedBox(height: 4),
                  
                  Text(
                    work['description'],
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  SizedBox(height: 8),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Materiales',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          Text(
                            '${work['materials'].length} items',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                        ],
                      ),
                      
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Precio',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          Text(
                            '\$${work['price']}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 8),
                  
                  Row(
                    children: [
                      Icon(Icons.star, size: 12, color: Colors.amber),
                      SizedBox(width: 4),
                      Text(
                        '${work['rating']}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.people, size: 12, color: Colors.grey.shade500),
                      SizedBox(width: 4),
                      Text(
                        '${work['completedBy']}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Spacer(),
                      Icon(Icons.play_circle_fill, size: 14, color: Colors.red),
                      SizedBox(width: 4),
                      Text(
                        'Video',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageBadge(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: Colors.white),
          SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(int level) {
    switch (level) {
      case 1: return Colors.green;
      case 2: return Colors.orange;
      case 3: return Colors.red;
      default: return Colors.grey;
    }
  }

  void _showProjectDetails(Map<String, dynamic> work) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => PatternDetailDialog(work: work),
    );
  }
}