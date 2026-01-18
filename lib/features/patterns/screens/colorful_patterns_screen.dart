// lib/features/patterns/screens/colorful_patterns_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:macrame_designer/features/patterns/models/pattern_model.dart';
import 'package:macrame_designer/features/patterns/services/pattern_service.dart';

class ColorfulPatternsScreen extends StatefulWidget {
  const ColorfulPatternsScreen({super.key});

  @override
  State<ColorfulPatternsScreen> createState() => _ColorfulPatternsScreenState();
}

class _ColorfulPatternsScreenState extends State<ColorfulPatternsScreen> {
  final PatternService _patternService = PatternService();
  List<PatternDesign> _patterns = [];
  bool _isLoading = true;
  String _searchQuery = '';
  int _selectedCategory = 0;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Todos', 'emoji': '🌈', 'color': Color(0xFFFF6B6B)},
    {'name': 'Tapices', 'emoji': '🎨', 'color': Color(0xFF4ECDC4)},
    {'name': 'Accesorios', 'emoji': '👜', 'color': Color(0xFFFFD166)},
    {'name': 'Decoración', 'emoji': '🏠', 'color': Color(0xFF06D6A0)},
    {'name': 'Regalos', 'emoji': '🎁', 'color': Color(0xFF118AB2)},
  ];

  // Imágenes con gradientes coloridos
  final List<List<Color>> _gradients = [
    [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
    [Color(0xFF4ECDC4), Color(0xFF7CE0D9)],
    [Color(0xFFFFD166), Color(0xFFFFE0A3)],
    [Color(0xFF06D6A0), Color(0xFF4CE8C0)],
    [Color(0xFF118AB2), Color(0xFF4DB8DB)],
    [Color(0xFF7209B7), Color(0xFF9D4EDD)],
    [Color(0xFFF15BB5), Color(0xFFF48FB1)],
    [Color(0xFF00BBF9), Color(0xFF00F5D4)],
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
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Column(
        children: [
          // Header divertido
          Container(
            padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFF6B6B),
                  const Color(0xFF4ECDC4),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.workspaces, color: Color(0xFFFF6B6B)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¡Hola, Creador!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${_patterns.length} patrones para explorar',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_none, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          decoration: const InputDecoration(
                            hintText: 'Busca tu próximo proyecto...',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.search, color: Color(0xFFFF6B6B)),
                            contentPadding: EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4ECDC4),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(15),
                            bottomRight: Radius.circular(15),
                          ),
                        ),
                        child: const Icon(Icons.tune, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Categorías divertidas
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = index;
                    });
                  },
                  child: Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: _selectedCategory == index
                          ? category['color'] as Color
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          category['emoji'] as String,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          category['name'] as String,
                          style: TextStyle(
                            color: _selectedCategory == index
                                ? Colors.white
                                : Colors.black,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Contenido
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: const Color(0xFFFF6B6B),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Cargando diversión...',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : _patterns.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/empty.png',
                              width: 150,
                              height: 150,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              '¡Oh no! No hay patrones',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Empieza creando tu primer diseño',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // Cambiado de 3 a 2 para mejor visualización
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.9,
                        ),
                        itemCount: _patterns.length,
                        itemBuilder: (context, index) {
                          final pattern = _patterns[index];
                          return _buildColorfulCard(pattern, index);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFFFF6B6B),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildColorfulCard(PatternDesign pattern, int index) {
    final gradient = _gradients[index % _gradients.length];
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Imagen con gradiente y patrón
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Stack(
                children: [
                  // Patrón decorativo
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _ColorfulPatternPainter(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                  ),
                  
                  // Ícono decorativo
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getPatternEmoji(pattern),
                        color: Colors.white,
                      ),
                    ),
                  ),
                  
                  // Emoji según categoría
                  Center(
                    child: Text(
                      _getPatternEmoji(pattern),
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                  
                  // Etiqueta de dificultad
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            size: 12,
                            color: _getDifficultyColor(pattern.difficulty),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getDifficultyText(pattern.difficulty),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _getDifficultyColor(pattern.difficulty),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Información
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Nombre
                  Text(
                    pattern.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  // Autor y tiempo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pattern.author,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                size: 12,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${pattern.estimatedHours}h',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      // Precio
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: gradient[0].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '\$${_calculateCost(pattern).toInt()}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: gradient[0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Painter para patrón colorido
  class _ColorfulPatternPainter extends CustomPainter {
    final Color color;
    
    _ColorfulPatternPainter({required this.color});
    
    @override
    void paint(Canvas canvas, Size size) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      
      final center = Offset(size.width / 2, size.height / 2);
      final radius = min(size.width, size.height) / 3;
      
      // Dibujar círculos concéntricos
      for (int i = 1; i <= 3; i++) {
        canvas.drawCircle(center, radius * i / 3, paint);
      }
      
      // Dibujar líneas radiales
      for (int i = 0; i < 8; i++) {
        final angle = i * (2 * pi / 8);
        final x = center.dx + radius * cos(angle);
        final y = center.dy + radius * sin(angle);
        canvas.drawLine(center, Offset(x, y), paint);
      }
    }
    
    @override
    bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
  }

  String _getPatternEmoji(PatternDesign pattern) {
    final name = pattern.name.toLowerCase();
    if (name.contains('tapiz')) return '🧶';
    if (name.contains('porta') || name.contains('maceta')) return '🌿';
    if (name.contains('espejo')) return '🪞';
    if (name.contains('cortina')) return '🪟';
    if (name.contains('pulsera')) return '📿';
    if (name.contains('colgante')) return '✨';
    if (name.contains('luna') || name.contains('lunar')) return '🌙';
    if (name.contains('sol')) return '☀️';
    if (name.contains('estrella')) return '⭐';
    return '🎨';
  }

  Color _getDifficultyColor(PatternDifficulty difficulty) {
    switch (difficulty) {
      case PatternDifficulty.beginner:
        return Colors.green;
      case PatternDifficulty.intermediate:
        return Colors.orange;
      case PatternDifficulty.advanced:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getDifficultyText(PatternDifficulty difficulty) {
    switch (difficulty) {
      case PatternDifficulty.beginner:
        return 'Fácil';
      case PatternDifficulty.intermediate:
        return 'Medio';
      case PatternDifficulty.advanced:
        return 'Difícil';
      default:
        return '';
    }
  }

  double _calculateCost(PatternDesign pattern) {
    try {
      return pattern.materials.fold(0.0, (total, material) {
        return total + (material.lengthPerUnit * material.quantity * 0.05);
      });
    } catch (e) {
      return Random().nextInt(50) + 10.0;
    }
  }
}