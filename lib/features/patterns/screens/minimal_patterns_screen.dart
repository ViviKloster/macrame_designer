// lib/features/patterns/screens/minimal_patterns_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:macrame_designer/features/patterns/models/pattern_model.dart';
import 'package:macrame_designer/features/patterns/services/pattern_service.dart';

class MinimalPatternsScreen extends StatefulWidget {
  const MinimalPatternsScreen({super.key});

  @override
  State<MinimalPatternsScreen> createState() => _MinimalPatternsScreenState();
}

class _MinimalPatternsScreenState extends State<MinimalPatternsScreen> {
  final PatternService _patternService = PatternService();
  List<PatternDesign> _patterns = [];
  bool _isLoading = true;
  String _searchQuery = '';
  PatternDifficulty? _selectedDifficulty;

  // Paleta de colores para imágenes
  final List<Color> _imageColors = [
    const Color(0xFF2A2D43),
    const Color(0xFF3C3D59),
    const Color(0xFF4A4B6D),
    const Color(0xFF5C5D8D),
    const Color(0xFF6E6FAD),
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
      backgroundColor: const Color(0xFF0A0A0A),
      body: CustomScrollView(
        slivers: [
          // Header minimalista
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF0A0A0A),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Patrones',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 2,
                ),
              ),
              centerTitle: true,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A1A1A), Color(0xFF0A0A0A)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white70),
                onPressed: () {},
              ),
            ],
          ),

          // Búsqueda
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Buscar...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.search, color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF1A1A1A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),

          // Filtros minimalistas
          SliverToBoxAdapter(
            child: SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildMinimalFilter('Todos', null),
                  const SizedBox(width: 8),
                  _buildMinimalFilter('Principiante', PatternDifficulty.beginner),
                  const SizedBox(width: 8),
                  _buildMinimalFilter('Intermedio', PatternDifficulty.intermediate),
                  const SizedBox(width: 8),
                  _buildMinimalFilter('Avanzado', PatternDifficulty.advanced),
                ],
              ),
            ),
          ),

          // Grid de patrones
          if (_isLoading)
            SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
            )
          else if (_patterns.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 64,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay patrones',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85, // Cambiado para acomodar imagen
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final pattern = _patterns[index];
                    return _buildMinimalCard(pattern, index);
                  },
                  childCount: _patterns.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMinimalFilter(String text, PatternDifficulty? difficulty) {
    final isSelected = _selectedDifficulty == difficulty;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDifficulty = difficulty;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.white70,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalCard(PatternDesign pattern, int index) {
    final color = _imageColors[index % _imageColors.length];
    
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Imagen con patrón de macramé
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Stack(
                children: [
                  // Patrón de líneas (simulando macramé)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _MacramePatternPainter(
                        color: color.withOpacity(0.3),
                      ),
                    ),
                  ),
                  
                  // Ícono central
                  Center(
                    child: Icon(
                      _getPatternIcon(pattern),
                      size: 40,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  
                  // Badge de dificultad
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(pattern.difficulty).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getDifficultyText(pattern.difficulty).substring(0, 1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
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
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  // Autor y stats
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pattern.author,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: Colors.white.withOpacity(0.4),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${pattern.estimatedHours}h',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.attach_money,
                            size: 12,
                            color: Colors.white.withOpacity(0.4),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '\$${_calculateCost(pattern).toInt()}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 11,
                            ),
                          ),
                        ],
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

  // Painter para crear patrón de macramé
  class _MacramePatternPainter extends CustomPainter {
    final Color color;
    
    _MacramePatternPainter({required this.color});
    
    @override
    void paint(Canvas canvas, Size size) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      
      // Dibujar líneas diagonales
      for (double i = 0; i < size.width; i += 15) {
        canvas.drawLine(
          Offset(i, 0),
          Offset(0, i * 0.7),
          paint,
        );
        canvas.drawLine(
          Offset(size.width - i, size.height),
          Offset(size.width, size.height - i * 0.7),
          paint,
        );
      }
    }
    
    @override
    bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
  }

  IconData _getPatternIcon(PatternDesign pattern) {
    final name = pattern.name.toLowerCase();
    if (name.contains('tapiz')) return Icons.grid_on;
    if (name.contains('porta') || name.contains('maceta')) return Icons.local_florist;
    if (name.contains('espejo')) return Icons.mirror;
    if (name.contains('cortina')) return Icons.vertical_shades;
    if (name.contains('pulsera')) return Icons.watch;
    return Icons.design_services;
  }

  Color _getDifficultyColor(PatternDifficulty difficulty) {
    switch (difficulty) {
      case PatternDifficulty.beginner:
        return const Color(0xFF00D4AA);
      case PatternDifficulty.intermediate:
        return const Color(0xFFFFB74D);
      case PatternDifficulty.advanced:
        return const Color(0xFFF44336);
      default:
        return Colors.white;
    }
  }

  String _getDifficultyText(PatternDifficulty difficulty) {
    switch (difficulty) {
      case PatternDifficulty.beginner:
        return 'Principiante';
      case PatternDifficulty.intermediate:
        return 'Intermedio';
      case PatternDifficulty.advanced:
        return 'Avanzado';
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
      return 15.0;
    }
  }
}