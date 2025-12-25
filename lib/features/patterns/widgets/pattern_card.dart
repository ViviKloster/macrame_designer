// lib/src/features/patterns/widgets/pattern_card.dart
import 'package:flutter/material.dart';
import 'package:macrame_designer/features/patterns/models/pattern_model.dart';

class PatternCard extends StatelessWidget {
  final PatternDesign pattern;
  final VoidCallback onTap;
  final VoidCallback onBuy;
  final VoidCallback onTutorial;
  final VoidCallback? onEdit;

  const PatternCard({
    super.key,
    required this.pattern,
    required this.onTap,
    required this.onBuy,
    required this.onTutorial,
    this.onEdit,
  });

  String get difficultyText {
    switch (pattern.difficulty) {
      case PatternDifficulty.beginner:
        return 'Principiante';
      case PatternDifficulty.intermediate:
        return 'Intermedio';
      case PatternDifficulty.advanced:
        return 'Avanzado';
      case PatternDifficulty.expert:
        return 'Experto';
    }
  }

  Color get difficultyColor {
    switch (pattern.difficulty) {
      case PatternDifficulty.beginner:
        return Colors.green;
      case PatternDifficulty.intermediate:
        return Colors.blue;
      case PatternDifficulty.advanced:
        return Colors.orange;
      case PatternDifficulty.expert:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // CABECERA CON IMAGEN (De tu versión original - MEJOR DISEÑO)
            Stack(
              children: [
                // Imagen de fondo con overlay
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    color: Colors.grey[300],
                    image: DecorationImage(
                      image: NetworkImage(pattern.imageUrl),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.2),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                ),
                
                // Overlay con información
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            pattern.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: difficultyColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  difficultyText,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Icon(
                                Icons.timer,
                                size: 16,
                                color: Colors.white.withOpacity(0.9),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${pattern.estimatedHours}h',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              if (pattern.canBeDoubled)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.zoom_out_map, size: 14, color: Colors.white),
                                      SizedBox(width: 4),
                                      Text(
                                        'Doble',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // CUERPO (Combinación de ambas versiones)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Descripción (De tu versión original)
                  Text(
                    pattern.description,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Tags (De tu versión original)
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: pattern.tags.take(3).map((tag) {
                      return Chip(
                        label: Text(
                          '#$tag',
                          style: const TextStyle(fontSize: 11),
                        ),
                        backgroundColor: Colors.grey[100],
                        visualDensity: VisualDensity.compact,
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // PANEL DE INFORMACIÓN MEJORADO (Fusión de ambas)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color.fromARGB(255, 238, 238, 238)),
                    ),
                    child: Column(
                      children: [
                        // Fila 1: Material y longitud
                        Row(
                          children: [
                            Icon(
                              Icons.texture,
                              size: 20,
                              color: const Color(0xFF8B4513),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Cordón requerido:',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              '${pattern.totalLengthRequired.toStringAsFixed(1)}m',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF8B4513),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Fila 2: Cortes y materiales (2 columnas)
                        Row(
                          children: [
                            // Columna izquierda: Cortes
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.content_cut,
                                    size: 18,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Cortes',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        '${pattern.cordCuts.length} tipos',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Separador vertical
                            Container(
                              width: 1,
                              height: 30,
                              color: Colors.grey[300],
                            ),

                            // Columna derecha: Materiales
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.grid_view,
                                    size: 18,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Materiales',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        '${pattern.materials.length} tipos',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // BOTONES DE ACCIÓN MEJORADOS (Con opción de editar)
                  Row(
                    children: [
                      // Botón Detalles
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onTap,
                          icon: const Icon(Icons.info_outline, size: 18),
                          label: const Text('Detalles'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF8B4513),
                            side: const BorderSide(color: Color(0xFF8B4513)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 8),
                      
                      // Botón Tutorial (solo si existe)
                      if (pattern.youtubeTutorialUrl.isNotEmpty)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onTutorial,
                            icon: const Icon(Icons.play_circle_outline, size: 18),
                            label: const Text('Tutorial'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      
                      if (pattern.youtubeTutorialUrl.isNotEmpty) const SizedBox(width: 8),
                      
                      // Botón Editar (solo si se proporciona)
                      if (onEdit != null)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onEdit,
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text('Editar'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blue,
                              side: const BorderSide(color: Colors.blue),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      
                      if (onEdit != null) const SizedBox(width: 8),
                      
                      // Botón Comprar (solo si existe)
                      if (pattern.storeUrl.isNotEmpty)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: onBuy,
                            icon: const Icon(Icons.shopping_cart, size: 18),
                            label: const Text('Comprar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8B4513),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
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
}