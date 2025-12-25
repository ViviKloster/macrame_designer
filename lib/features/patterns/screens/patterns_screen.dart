// lib/src/features/patterns/screens/patterns_screen.dart
import 'package:flutter/material.dart';
import 'package:macrame_designer/features/patterns/models/pattern_model.dart';
import 'package:macrame_designer/features/patterns/services/pattern_service.dart';
import 'package:macrame_designer/features/patterns/screens/pattern_detail_screen.dart';
import 'package:macrame_designer/features/patterns/widgets/pattern_card.dart';
import 'package:macrame_designer/features/designer/screens/designer_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PatternsScreen extends StatefulWidget {
  const PatternsScreen({super.key});

  @override
  State<PatternsScreen> createState() => _PatternsScreenState();
}

class _PatternsScreenState extends State<PatternsScreen> {
  final List<PatternDesign> _patterns = [];
  final List<PatternDesign> _filteredPatterns = [];
  String _selectedFilter = 'all';
  String _sortBy = 'name';
  bool _sortAscending = true;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPatterns();
  }

  Future<void> _loadPatterns() async {
    setState(() {
      _isLoading = true;
    });

    // Cargar desde API o ejemplos
    final patterns = await PatternService.loadPatternsFromApi();
    
    setState(() {
      _patterns.clear();
      _patterns.addAll(patterns);
      _updateFilteredPatterns();
      _isLoading = false;
    });
  }

  void _updateFilteredPatterns() {
    // Primero filtrar
    PatternDifficulty? difficultyFilter;
    if (_selectedFilter == 'beginner') {
      difficultyFilter = PatternDifficulty.beginner;
    } else if (_selectedFilter == 'intermediate') {
      difficultyFilter = PatternDifficulty.intermediate;
    } else if (_selectedFilter == 'advanced') {
      difficultyFilter = PatternDifficulty.advanced;
    } else if (_selectedFilter == 'expert') {
      difficultyFilter = PatternDifficulty.expert;
    }

    var filtered = PatternService.filterPatterns(
      patterns: _patterns,
      difficulty: difficultyFilter,
      searchQuery: _searchController.text,
    );

    // Luego ordenar
    filtered = PatternService.sortPatterns(
      patterns: filtered,
      sortBy: _sortBy,
      ascending: _sortAscending,
    );

    setState(() {
      _filteredPatterns.clear();
      _filteredPatterns.addAll(filtered);
    });
  }

  void _navigateToDetail(PatternDesign pattern) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatternDetailScreen(pattern: pattern),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo abrir: $url'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadFromGallery() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      
      if (pickedFile != null) {
        // Navegar directamente al diseñador con la imagen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DesignerScreen(
              initialImage: File(pickedFile.path),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      
      if (pickedFile != null) {
        // Navegar directamente al diseñador con la imagen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DesignerScreen(
              initialImage: File(pickedFile.path),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al tomar foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showStatsDialog() {
    final stats = PatternService.getPatternStats(_patterns);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.analytics, color: Color(0xFF8B4513)),
            SizedBox(width: 8),
            Text('Estadísticas de Patrones'),
          ],
        ),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatRow('Total patrones:', '${stats['total']}'),
              _buildStatRow('Principiantes:', '${stats['beginner']}'),
              _buildStatRow('Intermedios:', '${stats['intermediate']}'),
              _buildStatRow('Avanzados:', '${stats['advanced']}'),
              _buildStatRow('Expertos:', '${stats['expert']}'),
              _buildStatRow('Pueden duplicarse:', '${stats['canBeDoubled']}'),
              _buildStatRow('Horas promedio:', '${(stats['avgHours'] as double).toStringAsFixed(1)}h'),
              _buildStatRow('Longitud promedio:', '${(stats['avgLength'] as double).toStringAsFixed(1)}m'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber),
                ),
                child: const Text(
                  '📊 Estos patrones representan una variedad de proyectos para todos los niveles.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showSortOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ordenar por'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSortOption('Nombre', 'name'),
            _buildSortOption('Dificultad', 'difficulty'),
            _buildSortOption('Tiempo estimado', 'hours'),
            _buildSortOption('Longitud', 'length'),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _sortAscending,
                  onChanged: (value) {
                    setState(() {
                      _sortAscending = value ?? true;
                    });
                    Navigator.pop(context);
                    _updateFilteredPatterns();
                  },
                ),
                const Text('Ascendente'),
                const Spacer(),
                Checkbox(
                  value: !_sortAscending,
                  onChanged: (value) {
                    setState(() {
                      _sortAscending = !(value ?? false);
                    });
                    Navigator.pop(context);
                    _updateFilteredPatterns();
                  },
                ),
                const Text('Descendente'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildSortOption(String label, String value) {
    return ListTile(
      title: Text(label),
      trailing: _sortBy == value
          ? const Icon(Icons.check, color: Colors.green)
          : null,
      onTap: () {
        setState(() {
          _sortBy = value;
        });
        Navigator.pop(context);
        _updateFilteredPatterns();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patrones Prediseñados'),
        backgroundColor: const Color(0xFF8B4513),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: _showStatsDialog,
            tooltip: 'Ver estadísticas',
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortOptions,
            tooltip: 'Ordenar',
          ),
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: _uploadFromGallery,
            tooltip: 'Crear desde galería',
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: _takePhoto,
            tooltip: 'Crear desde cámara',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar patrones...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _updateFilteredPatterns();
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.filter_alt),
                      onPressed: () {
                        _updateFilteredPatterns();
                      },
                    ),
                  ],
                ),
              ),
              onChanged: (_) => _updateFilteredPatterns(),
            ),
          ),

          // Filtros por dificultad - MEJORADO
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            color: Colors.grey[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FILTRAR POR DIFICULTAD:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildFilterChip('Todos', 'all'),
                      _buildFilterChip('Principiante', 'beginner'),
                      _buildFilterChip('Intermedio', 'intermediate'),
                      _buildFilterChip('Avanzado', 'advanced'),
                      _buildFilterChip('Experto', 'expert'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Contador de resultados con filtro activo - CORREGIDO
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredPatterns.length} patrones encontrados',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                if (_selectedFilter != 'all')
                  Chip(
                    label: Text(
                      _selectedFilter == 'beginner' ? 'Principiante' : 
                      _selectedFilter == 'intermediate' ? 'Intermedio' :
                      _selectedFilter == 'advanced' ? 'Avanzado' : 'Experto',
                    ),
                    backgroundColor: const Color(0xFF8B4513).withOpacity(0.1),
                    labelStyle: const TextStyle(
                      color: Color(0xFF8B4513),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Lista de patrones
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Cargando patrones...'),
                      ],
                    ),
                  )
                : _filteredPatterns.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No se encontraron patrones',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Intenta con otros filtros o términos de búsqueda',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _loadPatterns,
                              child: const Text('Recargar patrones'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadPatterns,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _filteredPatterns.length,
                          itemBuilder: (context, index) {
                            final pattern = _filteredPatterns[index];
                            return PatternCard(
                              pattern: pattern,
                              onTap: () => _navigateToDetail(pattern),
                              onBuy: () => _launchUrl(pattern.storeUrl),
                              onTutorial: () => _launchUrl(pattern.youtubeTutorialUrl),
                              onEdit: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DesignerScreen(
                                      initialPattern: pattern,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DesignerScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFF8B4513),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Crear Nuevo'),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = value;
          });
          _updateFilteredPatterns();
        },
        backgroundColor: Colors.grey[200],
        selectedColor: const Color(0xFF8B4513),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
        ),
        checkmarkColor: Colors.white,
      ),
    );
  }
}