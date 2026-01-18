// lib/features/patterns/screens/appstore_patterns_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:image_picker/image_picker.dart';
import 'package:macrame_designer/features/patterns/models/pattern_model.dart';
import 'package:macrame_designer/features/patterns/services/pattern_service.dart';
import 'package:macrame_designer/features/patterns/widgets/pattern_detail_dialog.dart';
import 'package:macrame_designer/features/marketplace/marketplace_screen.dart';

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
  
  // Para el selector de imágenes
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  
  // Categorías estilo Instagram
  final List<Map<String, dynamic>> _instagramCategories = [
    {'name': 'Todos', 'icon': Icons.grid_view, 'count': 0, 'isActive': true},
    {'name': 'Tapices', 'icon': Icons.wallpaper, 'count': 0, 'isActive': false},
    {'name': 'Decoración', 'icon': Icons.home, 'count': 0, 'isActive': false},
    {'name': 'Accesorios', 'icon': Icons.workspace_premium, 'count': 0, 'isActive': false},
    {'name': 'Ropa', 'icon': Icons.checkroom, 'count': 0, 'isActive': false},
    {'name': 'Plantillas', 'icon': Icons.description, 'count': 0, 'isActive': false},
    {'name': 'Materiales', 'icon': Icons.shopping_basket, 'count': 0, 'isActive': false},
  ];

  // Base de datos de trabajos (actualizada)
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
      'materialPrice': 45.50,
      'sellingPrice': 89.99,
      'rating': 4.8,
      'images': [
        'assets/images/Tapiz_angel1.jpg',
        'assets/images/Tapiz_angel2.jpg',
        'assets/images/Tapiz_angel3.jpg',
      ],
      'materials': [
        {'name': 'Cordón de algodón 4mm', 'quantity': '150 metros', 'color': 'Blanco', 'price': 25.00},
        {'name': 'Anillo de madera 40cm', 'quantity': '1', 'size': '40cm diámetro', 'price': 8.50},
        {'name': 'Tijeras profesionales', 'quantity': '1', 'price': 12.00},
        {'name': 'Kit de inicio', 'quantity': '1', 'includes': 'Medidor + Peine', 'price': 15.00},
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
      'canSell': true,
      'profitMargin': '98%',
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
      'materialPrice': 68.75,
      'sellingPrice': 149.99,
      'rating': 4.9,
      'images': [
        'assets/images/Centro-de-mesa1.jpg',
        'assets/images/Centro_de_mesa2.jpg',
        'assets/images/Centro_de_mesa3.jpg',
      ],
      'materials': [
        {'name': 'Cordón de yute premium', 'quantity': '200 metros', 'color': 'Natural', 'price': 35.00},
        {'name': 'Aros metálicos (3)', 'quantity': '3', 'size': '30/25/20cm', 'price': 18.75},
        {'name': 'Cuentas decorativas', 'quantity': '50 unidades', 'price': 15.00},
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
      'canSell': true,
      'profitMargin': '118%',
    },
    {
      'id': 'corazon',
      'name': 'Corazón Decorativo',
      'category': 'Decoración',
      'description': 'Diseño romántico en forma de corazón, perfecto para regalos.',
      'difficulty': 'Principiante',
      'difficultyLevel': 1,
      'time': '8-10 horas',
      'price': 19.99,
      'materialPrice': 28.40,
      'sellingPrice': 59.99,
      'rating': 4.7,
      'images': [
        'assets/images/Corazon2.jpg',
        'assets/images/Corazon3.jpg',
        'assets/images/Corazon4.jpg',
      ],
      'materials': [
        {'name': 'Cordón rojo 4mm', 'quantity': '80 metros', 'color': 'Rojo', 'price': 12.00},
        {'name': 'Varilla de metal', 'quantity': '1', 'size': '35cm', 'price': 6.40},
        {'name': 'Kit principiante', 'quantity': '1', 'includes': 'Herramientas básicas', 'price': 10.00},
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
      'canSell': true,
      'profitMargin': '111%',
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
      'materialPrice': 32.50,
      'sellingPrice': 79.99,
      'rating': 4.5,
      'images': [
        'assets/images/cartera_de_mano.jpg',
      ],
      'materials': [
        {'name': 'Cordón de cuero sintético', 'quantity': '40 metros', 'color': 'Marrón', 'price': 20.00},
        {'name': 'Cierre metálico 20cm', 'quantity': '1', 'price': 7.50},
        {'name': 'Forro interior', 'quantity': '1 metro', 'price': 5.00},
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
      'canSell': true,
      'profitMargin': '146%',
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
      'materialPrice': 52.80,
      'sellingPrice': 129.99,
      'rating': 4.8,
      'images': [
        'assets/images/Tapiz_flor_de_loto.jpg',
      ],
      'materials': [
        {'name': 'Cordón de seda artificial', 'quantity': '180 metros', 'color': 'Rosa/Blanco', 'price': 36.00},
        {'name': 'Aro de metal 45cm', 'quantity': '1', 'price': 12.80},
        {'name': 'Hilos decorativos', 'quantity': 'paquete', 'price': 4.00},
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
      'canSell': true,
      'profitMargin': '146%',
    },
  ];

  // Materiales disponibles para compra
  final List<Map<String, dynamic>> _availableMaterials = [
    {
      'id': 'cord_algodon_4mm',
      'name': 'Cordón de Algodón 4mm',
      'category': 'Materiales',
      'description': 'Ideal para tapices y decoraciones',
      'price': 0.25,
      'unit': 'metro',
      'colors': ['Blanco', 'Beige', 'Negro', 'Rojo', 'Azul'],
      'image': 'assets/images/material_cordon.jpg',
      'inStock': true,
    },
    {
      'id': 'anillo_madera',
      'name': 'Anillo de Madera',
      'category': 'Materiales',
      'description': 'Para colgar tapices, varios tamaños',
      'price': 8.50,
      'unit': 'unidad',
      'sizes': ['30cm', '40cm', '50cm'],
      'image': 'assets/images/material_anillo.jpg',
      'inStock': true,
    },
    {
      'id': 'kit_herramientas',
      'name': 'Kit de Herramientas',
      'category': 'Materiales',
      'description': 'Todo lo necesario para empezar',
      'price': 24.99,
      'unit': 'kit',
      'includes': ['Tijeras', 'Peine', 'Medidor', 'Agujas'],
      'image': 'assets/images/material_kit.jpg',
      'inStock': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadPatterns();
    _updateCategoryCounts();
  }

  Future<void> _loadPatterns() async {
    try {
      final patterns = await _patternService.getPatterns();
      setState(() {
        _patterns = patterns;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateCategoryCounts() {
    for (var category in _instagramCategories) {
      final categoryName = category['name'] as String;
      if (categoryName == 'Todos') {
        category['count'] = _worksDatabase.length + _availableMaterials.length;
      } else if (categoryName == 'Materiales') {
        category['count'] = _availableMaterials.length;
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
        child: Column(
          children: [
            // Header con búsqueda y acciones
            _buildHeader(),
            
            // Categorías estilo Instagram
            _buildInstagramCategories(),
            
            // Contenido principal
            Expanded(
              child: _buildMainContent(),
            ),
          ],
        ),
      ),
      
      // Botón flotante para vender
      floatingActionButton: FloatingActionButton(
        onPressed: _showSellOptions,
        backgroundColor: Color(0xFF4CAF50),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Header con búsqueda
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          // Logo
          Text(
            'MacraméHub',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2D3748),
              letterSpacing: -0.5,
            ),
          ),
          
          Spacer(),
          
          // Búsqueda
          Expanded(
            child: Container(
              height: 36,
              margin: EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar proyectos, materiales...',
                  hintStyle: TextStyle(fontSize: 13),
                  prefixIcon: Icon(Icons.search, size: 18),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
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
          ),
          
          // Iconos de acción
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MarketplaceScreen(),
                ),
              );
            },
            icon: Icon(Icons.store, size: 22, color: Colors.grey.shade700),
            tooltip: 'Marketplace',
          ),
          
          IconButton(
            onPressed: () {
              _showShoppingCart();
            },
            icon: Icon(Icons.shopping_cart, size: 22, color: Colors.grey.shade700),
            tooltip: 'Carrito de compras',
          ),
        ],
      ),
    );
  }

  // Categorías estilo Instagram
  Widget _buildInstagramCategories() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: _instagramCategories.length,
        itemBuilder: (context, index) {
          final category = _instagramCategories[index];
          final isSelected = _selectedCategory == category['name'];
          
          return Padding(
            padding: EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category['name'] as String;
                  // Actualizar estado de todas las categorías
                  for (var cat in _instagramCategories) {
                    cat['isActive'] = cat['name'] == category['name'];
                  }
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Color(0xFF4CAF50).withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Color(0xFF4CAF50) : Colors.grey.shade300,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      category['icon'] as IconData,
                      size: 16,
                      color: isSelected ? Color(0xFF4CAF50) : Colors.grey.shade600,
                    ),
                    SizedBox(width: 6),
                    Text(
                      category['name'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? Color(0xFF4CAF50) : Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(width: 4),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected ? Color(0xFF4CAF50) : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${category['count']}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Contenido principal
  Widget _buildMainContent() {
    final items = _getFilteredItems();
    
    return _isLoading
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
            child: items.isEmpty
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
                          'No se encontraron resultados',
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
                      crossAxisCount: _selectedCategory == 'Materiales' ? 2 : 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: _selectedCategory == 'Materiales' ? 0.85 : 0.75,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      if (_selectedCategory == 'Materiales') {
                        return _buildMaterialCard(items[index]);
                      } else {
                        return _buildProjectCard(items[index]);
                      }
                    },
                  ),
          );
  }

  List<Map<String, dynamic>> _getFilteredItems() {
    List<Map<String, dynamic>> items = [];
    
    if (_selectedCategory == 'Todos') {
      items.addAll(_worksDatabase);
      items.addAll(_availableMaterials);
    } else if (_selectedCategory == 'Materiales') {
      items.addAll(_availableMaterials);
    } else {
      items.addAll(_worksDatabase.where((work) => work['category'] == _selectedCategory).toList());
    }
    
    // Filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      items = items.where((item) =>
          item['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item['description'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (item['category'] as String).toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    
    // Ordenar
    switch (_selectedSort) {
      case 1: // Dificultad (solo proyectos)
        if (_selectedCategory != 'Materiales') {
          items.sort((a, b) => (a['difficultyLevel'] as int).compareTo(b['difficultyLevel'] as int));
        }
        break;
      case 2: // Precio
        items.sort((a, b) => (a['price'] as double).compareTo(b['price'] as double));
        break;
      default: // Popularidad/Relevancia
        if (_selectedCategory == 'Materiales') {
          // Ordenar materiales por stock
          items.sort((a, b) => (b['inStock'] == true ? 1 : 0).compareTo(a['inStock'] == true ? 1 : 0));
        } else {
          // Ordenar proyectos por completados
          items.sort((a, b) => (b['completedBy'] as int).compareTo(a['completedBy'] as int));
        }
        break;
    }
    
    return items;
  }

  // Card para proyectos
  Widget _buildProjectCard(Map<String, dynamic> work) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade100, width: 1),
      ),
      child: InkWell(
        onTap: () {
          _showProjectDetails(work);
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
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
                              Colors.black.withOpacity(0.5),
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
                          borderRadius: BorderRadius.circular(6),
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
                    
                    // Badge de ganancia
                    if (work['canSell'] == true)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Gana ${work['profitMargin']}',
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
                    ],
                  ),
                  
                  SizedBox(height: 8),
                  
                  // Precios
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Patrón',
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
                      
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Materiales',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          Text(
                            '\$${work['materialPrice']}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2196F3),
                            ),
                          ),
                        ],
                      ),
                      
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Venta',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          Text(
                            '\$${work['sellingPrice']}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 8),
                  
                  // Acciones rápidas
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            _addMaterialsToCart(work['materials']);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            side: BorderSide(color: Color(0xFF2196F3)),
                          ),
                          child: Text(
                            'Comprar Materiales',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF2196F3),
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(width: 8),
                      
                      IconButton(
                        onPressed: () {
                          _showSellProduct(work);
                        },
                        icon: Icon(Icons.sell, size: 18, color: Colors.green),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
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

  // Card para materiales
  Widget _buildMaterialCard(Map<String, dynamic> material) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade100, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen del material
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              color: Colors.grey.shade100,
              image: material['image'] != null
                  ? DecorationImage(
                      image: AssetImage(material['image'] as String),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: material['image'] == null
                ? Center(
                    child: Icon(
                      Icons.inventory_2,
                      size: 40,
                      color: Colors.grey.shade400,
                    ),
                  )
                : null,
          ),
          
          // Información
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  material['name'],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                SizedBox(height: 4),
                
                Text(
                  material['description'],
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                SizedBox(height: 8),
                
                // Variantes (colores/tamaños)
                if (material['colors'] != null)
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: (material['colors'] as List<String>).take(3).map((color) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getColorFromName(color),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          color,
                          style: TextStyle(
                            fontSize: 9,
                            color: _getTextColorForBackground(_getColorFromName(color)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                
                if (material['sizes'] != null)
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: (material['sizes'] as List<String>).take(2).map((size) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          size,
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                
                SizedBox(height: 8),
                
                // Precio y acción
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Precio',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        Text(
                          '\$${material['price']}/${material['unit']}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                      ],
                    ),
                    
                    ElevatedButton(
                      onPressed: () {
                        _addMaterialToCart(material);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4CAF50),
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: Size(0, 0),
                      ),
                      child: Text(
                        'Agregar',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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

  Color _getColorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'blanco': return Colors.white;
      case 'beige': return Color(0xFFF5F5DC);
      case 'negro': return Colors.black;
      case 'rojo': return Colors.red;
      case 'azul': return Colors.blue;
      case 'verde': return Colors.green;
      case 'amarillo': return Colors.yellow;
      case 'rosa': return Colors.pink;
      case 'marrón': return Colors.brown;
      case 'gris': return Colors.grey;
      case 'natural': return Color(0xFFF0E68C);
      default: return Colors.grey.shade300;
    }
  }

  Color _getTextColorForBackground(Color backgroundColor) {
    final brightness = backgroundColor.computeLuminance();
    return brightness > 0.5 ? Colors.black : Colors.white;
  }

  void _showProjectDetails(Map<String, dynamic> work) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => PatternDetailDialog(work: work),
    );
  }

  void _showSellOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vender tu trabajo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D3748),
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Elige cómo quieres vender tu producto terminado:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 20),
            
            ListTile(
              leading: Icon(Icons.camera_alt, color: Color(0xFF4CAF50)),
              title: Text(
                'Tomar foto con cámara',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text('Usa la cámara de tu dispositivo'),
              onTap: () {
                Navigator.pop(context);
                _takePhotoFromCamera();
              },
            ),
            
            Divider(),
            
            ListTile(
              leading: Icon(Icons.photo_library, color: Color(0xFF2196F3)),
              title: Text(
                'Seleccionar de galería',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text('Elige una foto de tu dispositivo'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            
            Divider(),
            
            ListTile(
              leading: Icon(Icons.cloud_upload, color: Color(0xFF9C27B0)),
              title: Text(
                'Subir desde archivo',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text('Sube desde tu computadora o celular'),
              onTap: () {
                Navigator.pop(context);
                _uploadFromFile();
              },
            ),
            
            SizedBox(height: 20),
            
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
              ),
              child: Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _takePhotoFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        _showSellProductForm();
      }
    } catch (e) {
      _showError('Error al tomar foto: $e');
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        _showSellProductForm();
      }
    } catch (e) {
      _showError('Error al seleccionar imagen: $e');
    }
  }

  void _uploadFromFile() {
    // En una app real, aquí se implementaría el file picker nativo
    // Por ahora simulamos con un diálogo
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Subir archivo'),
        content: Text('Selecciona un archivo de imagen desde tu dispositivo'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSellProductForm();
            },
            child: Text('Continuar'),
          ),
        ],
      ),
    );
  }

  void _showSellProduct(Map<String, dynamic>? work) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Vender producto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              work != null
                  ? '¿Quieres vender tu versión de "${work['name']}"?'
                  : 'Vende tu producto terminado',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            Text(
              'Precio sugerido: \$${work?['sellingPrice'] ?? '49.99'}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Ganancia estimada: \$${work != null ? (work['sellingPrice'] - work['materialPrice']).toStringAsFixed(2) : '30.00'}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.green.shade700,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSellOptions();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: Text('Continuar'),
          ),
        ],
      ),
    );
  }

  void _showSellProductForm() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          double _price = 49.99;
          String _description = '';
          String _title = 'Mi producto terminado';
          
          return AlertDialog(
            title: Text('Publicar producto'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Vista previa de imagen
                  if (_selectedImage != null)
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: FileImage(_selectedImage!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  else
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image, size: 40, color: Colors.grey.shade400),
                          Text('Sin imagen seleccionada'),
                        ],
                      ),
                    ),
                  
                  SizedBox(height: 16),
                  
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Título del producto',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => _title = value,
                  ),
                  
                  SizedBox(height: 12),
                  
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Descripción',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    onChanged: (value) => _description = value,
                  ),
                  
                  SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Text('Precio:'),
                      SizedBox(width: 12),
                      Expanded(
                        child: Slider(
                          value: _price,
                          min: 5,
                          max: 500,
                          divisions: 99,
                          label: '\$$_price',
                          onChanged: (value) {
                            setState(() {
                              _price = value;
                            });
                          },
                        ),
                      ),
                      Text(
                        '\$${_price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  _publishProduct(_title, _description, _price);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: Text('Publicar'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _publishProduct(String title, String description, double price) {
    // En una app real, aquí se subiría a un servidor
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Producto "$title" publicado en el marketplace'),
        backgroundColor: Colors.green,
      ),
    );
    
    // Navegar al marketplace
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MarketplaceScreen(),
      ),
    );
  }

  void _addMaterialsToCart(List<dynamic> materials) {
    double total = 0;
    for (var material in materials) {
      if (material['price'] != null) {
        total += material['price'] as double;
      }
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agregar materiales al carrito'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Se agregarán ${materials.length} materiales:',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 12),
            ...materials.take(3).map((material) => ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green, size: 20),
              title: Text(material['name']),
              subtitle: Text('\$${material['price'] ?? '0.00'}'),
            )).toList(),
            if (materials.length > 3)
              Text('... y ${materials.length - 3} más'),
            SizedBox(height: 12),
            Divider(),
            ListTile(
              title: Text(
                'Total',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              trailing: Text(
                '\$${total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF4CAF50),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              _showShoppingCart();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF4CAF50),
            ),
            child: Text('Ir al carrito'),
          ),
        ],
      ),
    );
  }

  void _addMaterialToCart(Map<String, dynamic> material) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${material['name']} agregado al carrito'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
  }

  void _showShoppingCart() {
    // En una app real, aquí se navegaría a la pantalla del carrito
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Carrito de compras'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.shopping_basket, color: Color(0xFF4CAF50)),
              title: Text('Materiales para proyectos'),
              subtitle: Text('3 items - \$128.75'),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.delivery_dining, color: Color(0xFF2196F3)),
              title: Text('Envío'),
              subtitle: Text('Gratis para compras +\$50'),
            ),
            Divider(),
            ListTile(
              title: Text(
                'Total',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              trailing: Text(
                '\$128.75',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF4CAF50),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Seguir comprando'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _checkout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF4CAF50),
            ),
            child: Text('Pagar ahora'),
          ),
        ],
      ),
    );
  }

  void _checkout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Completar compra'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 60, color: Colors.green),
            SizedBox(height: 20),
            Text(
              '¡Compra exitosa!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Los materiales llegarán en 3-5 días hábiles',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Continuar'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}