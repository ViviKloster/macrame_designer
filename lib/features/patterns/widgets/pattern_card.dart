// lib/features/patterns/widgets/pattern_card.dart - VERSIÓN CON AUTHOR
import 'package:flutter/material.dart';
import 'package:macrame_designer/features/patterns/models/pattern_model.dart';

class PatternCard extends StatelessWidget {
  final PatternDesign pattern;
  final VoidCallback onTap;
  final VoidCallback onBuy;
  final VoidCallback onTutorial;
  final VoidCallback? onEdit;
  final bool listView;

  const PatternCard({
    super.key,
    required this.pattern,
    required this.onTap,
    required this.onBuy,
    required this.onTutorial,
    this.onEdit,
    this.listView = false,
  });

  String get difficultyText {
    return pattern.difficulty.displayName;
  }

  Color get difficultyColor {
    return pattern.difficulty.color;
  }

  // Método para construir la versión grid
  Widget _buildGridView() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagen con overlay
            Stack(
              children: [
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    image: pattern.imageUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(pattern.imageUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: pattern.imageUrl.isEmpty
                      ? const Center(
                          child: Icon(
                            Icons.image,
                            size: 40,
                            color: Colors.grey,
                          ),
                        )
                      : null,
                ),
                
                // Overlay con gradiente
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.6),
                      ],
                    ),
                  ),
                ),
                
                // Badge de dificultad
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: difficultyColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      difficultyText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                // Indicador de tiempo
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.timer,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${pattern.estimatedHours.toStringAsFixed(1)}h',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Indicador de si puede duplicarse
                if (pattern.canBeDoubled)
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9C846).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.zoom_out_map,
                            size: 12,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Doble',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            
            // Contenido
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    pattern.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  
                  // Autor (NUEVO)
                  if (pattern.author.isNotEmpty)
                    Text(
                      'Por: ${pattern.author}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  
                  const SizedBox(height: 8),
                  
                  // Nivel de dificultad con icono
                  Row(
                    children: [
                      Icon(
                        pattern.difficulty.icon,
                        size: 14,
                        color: difficultyColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        difficultyText,
                        style: TextStyle(
                          fontSize: 13,
                          color: difficultyColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Información rápida en 2 filas
                  // Fila 1: Longitud y material
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Longitud requerida
                      Row(
                        children: [
                          Icon(
                            Icons.straighten,
                            size: 14,
                            color: const Color(0xFF6A4C93),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${pattern.totalLengthRequired.toStringAsFixed(1)}m',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6A4C93),
                            ),
                          ),
                        ],
                      ),
                      
                      // Materiales
                      Row(
                        children: [
                          Icon(
                            Icons.grid_view,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${pattern.materials.length} mat.',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  // Fila 2: Cortes y tags
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Cortes
                      Row(
                        children: [
                          Icon(
                            Icons.content_cut,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${pattern.cordCuts.length} cortes',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      
                      // Tags (primer tag si existe)
                      if (pattern.tags.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6A4C93).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '#${pattern.tags.first}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF6A4C93),
                              fontWeight: FontWeight.w500,
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
      ),
    );
  }

  // Método para construir la versión lista
  Widget _buildListView() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen en lista
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
              child: Container(
                width: 120,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  image: pattern.imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(pattern.imageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: pattern.imageUrl.isEmpty
                    ? const Center(
                        child: Icon(
                          Icons.image,
                          size: 30,
                          color: Colors.grey,
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.3),
                            ],
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: difficultyColor,
                              ),
                              child: Text(
                                difficultyText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            
            // Contenido en lista
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    Text(
                      pattern.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Autor (NUEVO)
                    if (pattern.author.isNotEmpty)
                      Text(
                        'Por: ${pattern.author}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    
                    const SizedBox(height: 8),
                    
                    // Información de dificultad y tiempo
                    Row(
                      children: [
                        Icon(
                          pattern.difficulty.icon,
                          size: 14,
                          color: difficultyColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          difficultyText,
                          style: TextStyle(
                            fontSize: 13,
                            color: difficultyColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.timer,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${pattern.estimatedHours.toStringAsFixed(1)}h',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Descripción breve
                    Text(
                      pattern.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Información detallada en 3 columnas
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Longitud
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.straighten,
                              size: 16,
                              color: const Color(0xFF6A4C93),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${pattern.totalLengthRequired.toStringAsFixed(1)}m',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6A4C93),
                              ),
                            ),
                            Text(
                              'Longitud',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        
                        // Materiales
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.grid_view,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${pattern.materials.length}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            Text(
                              'Materiales',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        
                        // Cortes
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.content_cut,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${pattern.cordCuts.length}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            Text(
                              'Cortes',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        
                        // Tags (solo si puede duplicarse)
                        if (pattern.canBeDoubled)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.zoom_out_map,
                                size: 16,
                                color: const Color(0xFFF9C846),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Doble',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFF9C846),
                                ),
                              ),
                              Text(
                                'Tamaño',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    
                    // Tags (solo en lista)
                    if (pattern.tags.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 4,
                        runSpacing: 2,
                        children: pattern.tags.take(3).map((tag) {
                          return Chip(
                            label: Text(
                              '#$tag',
                              style: const TextStyle(fontSize: 10),
                            ),
                            backgroundColor: const Color(0xFF6A4C93).withOpacity(0.1),
                            visualDensity: VisualDensity.compact,
                            side: BorderSide.none,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return listView ? _buildListView() : _buildGridView();
  }
}