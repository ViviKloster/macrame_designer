// lib/features/patterns/screens/patterns_screen.dart
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

class _PatternsScreenState extends State<PatternsScreen> with SingleTickerProviderStateMixin {
  final List<PatternDesign> _patterns = [];
  final List<PatternDesign> _filteredPatterns = [];
  String _selectedFilter = 'all';
  String _sortBy = 'name';
  bool _sortAscending = true;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  bool _showAdvancedFilters = false;
  bool _gridView = true; // true para grid, false para lista
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadPatterns();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
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
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => PatternDetailScreen(pattern: pattern),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            )),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
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
            Icon(Icons.analytics, color: Color(0xFF6A4C93)),
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
                  color: const Color(0xFF6A4C93).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF6A4C93)),
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
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6A4C93))),
        ],
      ),
    );
  }

  void _toggleAdvancedFilters() {
    setState(() {
      _showAdvancedFilters = !_showAdvancedFilters;
      if (_showAdvancedFilters) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _toggleViewMode() {
    setState(() {
      _gridView = !_gridView;
    });
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ordenar por',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSortOptionTile('Nombre', 'name', Icons.sort_by_alpha),
            _buildSortOptionTile('Dificultad', 'difficulty', Icons.speed),
            _buildSortOptionTile('Tiempo estimado', 'hours', Icons.timer),
            _buildSortOptionTile('Longitud', 'length', Icons.straighten),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.arrow_upward, color: Color(0xFF6A4C93)),
                const SizedBox(width: 8),
                const Text('Orden', style: TextStyle(fontWeight: FontWeight.w500)),
                const Spacer(),
                Switch(
                  value: _sortAscending,
                  onChanged: (value) {
                    setState(() {
                      _sortAscending = value;
                    });
                    Navigator.pop(context);
                    _updateFilteredPatterns();
                  },
                  activeColor: const Color(0xFF6A4C93),
                ),
                Text(_sortAscending ? 'Ascendente' : 'Descendente'),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A4C93),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Aplicar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOptionTile(String label, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF6A4C93)),
      title: Text(label),
      trailing: _sortBy == value
          ? const Icon(Icons.check, color: Color(0xFF6A4C93))
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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Patrones de Macramé',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
      backgroundColor: const Color(0xFF6A4C93),
      foregroundColor: Colors.white,
      elevation: 4,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(_gridView ? Icons.view_list : Icons.grid_view),
          onPressed: _toggleViewMode,
          tooltip: _gridView ? 'Vista de lista' : 'Vista de cuadrícula',
        ),
        IconButton(
          icon: const Icon(Icons.analytics_outlined),
          onPressed: _showStatsDialog,
          tooltip: 'Estadísticas',
        ),
        IconButton(
          icon: const Icon(Icons.tune),
          onPressed: _toggleAdvancedFilters,
          tooltip: 'Filtros avanzados',
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'upload',
              child: Row(
                children: [
                  Icon(Icons.photo_library, size: 20),
                  SizedBox(width: 8),
                  Text('Crear desde galería'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'camera',
              child: Row(
                children: [
                  Icon(Icons.camera_alt, size: 20),
                  SizedBox(width: 8),
                  Text('Crear desde cámara'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'sort',
              child: Row(
                children: [
                  Icon(Icons.sort, size: 20),
                  SizedBox(width: 8),
                  Text('Opciones de orden'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'upload') _uploadFromGallery();
            if (value == 'camera') _takePhoto();
            if (value == 'sort') _showSortOptions();
          },
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Buscar patrones por nombre, autor o tags...',
            hintStyle: const TextStyle(color: Colors.grey),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF6A4C93)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      _searchController.clear();
                      _updateFilteredPatterns();
                    },
                  ),
                const SizedBox(width: 8),
                Container(
                  width: 1,
                  height: 24,
                  color: Colors.grey[300],
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list, size: 20),
                  onPressed: _toggleAdvancedFilters,
                ),
              ],
            ),
          ),
          onChanged: (_) => _updateFilteredPatterns(),
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildDifficultyFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: Colors.grey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'NIVEL DE DIFICULTAD',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildDifficultyChip('Todos', 'all', Colors.grey),
              _buildDifficultyChip('Principiante', 'beginner', Colors.green),
              _buildDifficultyChip('Intermedio', 'intermediate', Colors.orange),
              _buildDifficultyChip('Avanzado', 'advanced', Colors.red),
              _buildDifficultyChip('Experto', 'expert', Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyChip(String label, String value, Color color) {
    final isSelected = _selectedFilter == value;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : color,
          fontWeight: FontWeight.w500,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
        _updateFilteredPatterns();
      },
      backgroundColor: color.withOpacity(0.1),
      selectedColor: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? color : Colors.transparent,
          width: 1.5,
        ),
      ),
      labelPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildAdvancedFilters() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SizeTransition(
        sizeFactor: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Opciones Avanzadas',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: _toggleAdvancedFilters,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Ordenar por:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _buildSortOption('Nombre', 'name', Icons.sort_by_alpha),
                  _buildSortOption('Dificultad', 'difficulty', Icons.speed),
                  _buildSortOption('Tiempo', 'hours', Icons.timer),
                  _buildSortOption('Longitud', 'length', Icons.straighten),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 20,
                    color: const Color(0xFF6A4C93),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _sortAscending ? 'Ascendente' : 'Descendente',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  Switch(
                    value: _sortAscending,
                    onChanged: (value) {
                      setState(() {
                        _sortAscending = value;
                      });
                      _updateFilteredPatterns();
                    },
                    activeColor: const Color(0xFF6A4C93),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortOption(String label, String value, IconData icon) {
    final isSelected = _sortBy == value;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _sortBy = value;
        });
        _updateFilteredPatterns();
      },
      backgroundColor: isSelected ? const Color(0xFF6A4C93).withOpacity(0.1) : Colors.grey[100],
      selectedColor: const Color(0xFF6A4C93).withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? const Color(0xFF6A4C93) : Colors.transparent,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildPatternsView() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: const Color(0xFF6A4C93),
              strokeWidth: 3,
            ),
            const SizedBox(height: 20),
            const Text(
              'Cargando patrones...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (_filteredPatterns.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 80,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 20),
              const Text(
                'No se encontraron patrones',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Intenta con otros filtros o términos de búsqueda',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadPatterns,
                icon: const Icon(Icons.refresh),
                label: const Text('Recargar patrones'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A4C93),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF6A4C93),
      onRefresh: _loadPatterns,
      child: _gridView ? _buildGridView() : _buildListView(),
    );
  }


  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
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
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => DesignerScreen(
                  initialPattern: pattern,
                ),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredPatterns.length,
      itemBuilder: (context, index) {
        final pattern = _filteredPatterns[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: PatternCard(   
            pattern: pattern,
            onTap: () => _navigateToDetail(pattern),
            onBuy: () => _launchUrl(pattern.storeUrl),
            onTutorial: () => _launchUrl(pattern.youtubeTutorialUrl),
            onEdit: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => DesignerScreen(
                    initialPattern: pattern,
                  ),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                ),
              );
            },
            listView: true,
          ),
        );
      },
    );
  }

  Widget _buildResultsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'Encontrados ',
                  style: TextStyle(color: Colors.grey),
                ),
                TextSpan(
                  text: '${_filteredPatterns.length} ',
                  style: const TextStyle(
                    color: Color(0xFF6A4C93),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: _filteredPatterns.length == 1 ? 'patrón' : 'patrones',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          if (_selectedFilter != 'all')
            Chip(
              label: Text(
                _selectedFilter == 'beginner' ? 'Principiante' : 
                _selectedFilter == 'intermediate' ? 'Intermedio' :
                _selectedFilter == 'advanced' ? 'Avanzado' : 'Experto',
              ),
              backgroundColor: const Color(0xFF6A4C93).withOpacity(0.1),
              labelStyle: const TextStyle(
                color: Color(0xFF6A4C93),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              avatar: Icon(
                Icons.filter_alt,
                size: 16,
                color: const Color(0xFF6A4C93),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildDifficultyFilters(),
          if (_showAdvancedFilters) _buildAdvancedFilters(),
          _buildResultsHeader(),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildPatternsView(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const DesignerScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              },
            ),
          );
        },
        backgroundColor: const Color(0xFF6A4C93),
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        icon: const Icon(Icons.add_circle_outline),
        label: const Text(
          'Crear Patrón',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}