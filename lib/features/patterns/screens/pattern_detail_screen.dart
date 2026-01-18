// lib/src/features/patterns/screens/pattern_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:macrame_designer/features/patterns/models/pattern_model.dart';
import 'package:macrame_designer/features/designer/screens/designer_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class PatternDetailScreen extends StatefulWidget {
  final PatternDesign pattern;
  const PatternDetailScreen({super.key, required this.pattern});

  @override
  State<PatternDetailScreen> createState() => _PatternDetailScreenState();
}

class _PatternDetailScreenState extends State<PatternDetailScreen> {
  bool _showDoubled = false;
  bool _showMaterials = true;
  bool _showCuts = true;
  bool _showInstructions = false;

  double get totalLength {
    if (_showDoubled && widget.pattern.canBeDoubled) {
      return widget.pattern.totalLengthRequired * widget.pattern.doubledSizeMultiplier!;
    }
    return widget.pattern.totalLengthRequired;
  }

  Future<void> _launchTutorial() async {
    final uri = Uri.parse(widget.pattern.youtubeTutorialUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo abrir el tutorial'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _launchStore() async {
    final uri = Uri.parse(widget.pattern.storeUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo abrir la tienda'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _openInDesigner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DesignerScreen(
          initialPattern: widget.pattern,
        ),
      ),
    );
  }

  Widget _buildDifficultyBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: widget.pattern.difficulty.color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.pattern.difficulty.icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            widget.pattern.difficulty.displayName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isExpanded, VoidCallback onToggle) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: Icon(
        isExpanded ? Icons.expand_less : Icons.expand_more,
        color: const Color(0xFF8B4513),
      ),
      onTap: onToggle,
    );
  }

  Widget _buildMaterialCard(MaterialRequirement material) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              material.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildDetailRow('Grosor:', '${material.thickness} mm'),
            _buildDetailRow('Longitud por unidad:', '${material.lengthPerUnit} m'),
            _buildDetailRow('Cantidad:', '${material.quantity} unidades'),
            _buildDetailRow('Longitud total:', '${material.totalLength.toStringAsFixed(1)} m'),
            if (material.knottedReduction != null && material.knottedReduction! > 0)
              _buildDetailRow(
                'Reducción por anudado:',
                '${(material.knottedReduction! * 100).toInt()}%',
              ),
            if (material.knottedReduction != null && material.knottedReduction! > 0)
              _buildDetailRow(
                'Longitud final:',
                '${material.knottedLength.toStringAsFixed(1)} m',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCordCutCard(CordCut cut) {
    final effectiveLength = _showDoubled && widget.pattern.canBeDoubled 
        ? cut.length * widget.pattern.doubledSizeMultiplier!
        : cut.length;
    
    final effectiveQuantity = _showDoubled && widget.pattern.canBeDoubled 
        ? cut.quantity * 2
        : cut.quantity;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  cut.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (cut.isDoubled)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: const Text(
                      'DOBLADO',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            _buildDetailRow('Cantidad:', '$effectiveQuantity tiras'),
            _buildDetailRow('Largo por tira:', '${effectiveLength.toStringAsFixed(1)} m'),
            if (cut.unknottedLength != null)
              _buildDetailRow('Largo sin anudar:', '${cut.unknottedLength!.toStringAsFixed(1)} m'),
            _buildDetailRow('Largo total:', '${(effectiveLength * effectiveQuantity).toStringAsFixed(1)} m'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, size: 16, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Corta ${cut.recommendedCutLength.toStringAsFixed(1)} m por tira',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pattern.name),
        backgroundColor: const Color(0xFF8B4513),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: _launchStore,
            tooltip: 'Comprar materiales',
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _openInDesigner,
            tooltip: 'Abrir en diseñador',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagen del patrón
            Container(
              height: 250,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.pattern.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título y dificultad
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.pattern.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildDifficultyBadge(),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.amber[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.amber),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.timer, size: 20, color: Colors.amber),
                                const SizedBox(height: 4),
                                Text(
                                  '${widget.pattern.estimatedHours}h',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.texture, size: 20, color: Colors.blue),
                                const SizedBox(height: 4),
                                Text(
                                  '${totalLength.toStringAsFixed(1)}m',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Descripción
                  Text(
                    widget.pattern.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Tags
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: widget.pattern.tags.map((tag) {
                      return Chip(
                        label: Text(
                          '#$tag',
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: Colors.grey[100],
                        visualDensity: VisualDensity.compact,
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Opción doble tamaño
                  if (widget.pattern.canBeDoubled)
                    Card(
                      color: Colors.amber[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Switch(
                              value: _showDoubled,
                              onChanged: (value) {
                                setState(() {
                                  _showDoubled = value;
                                });
                              },
                              activeColor: const Color(0xFF8B4513),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Modo tamaño doble',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Actívalo para calcular materiales para un tamaño ${widget.pattern.doubledSizeMultiplier}x mayor.',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Material necesario: ${totalLength.toStringAsFixed(1)} metros',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF8B4513),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Materiales requeridos
                  Card(
                    child: Column(
                      children: [
                        _buildSectionTitle(
                          '📦 Materiales Requeridos',
                          _showMaterials,
                          () => setState(() => _showMaterials = !_showMaterials),
                        ),
                        if (_showMaterials) ...[
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: widget.pattern.materials
                                  .map(_buildMaterialCard)
                                  .toList(),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Cortes de cuerda
                  Card(
                    child: Column(
                      children: [
                        _buildSectionTitle(
                          '✂️ Cortes de Cuerda',
                          _showCuts,
                          () => setState(() => _showCuts = !_showCuts),
                        ),
                        if (_showCuts) ...[
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: widget.pattern.cordCuts
                                  .map(_buildCordCutCard)
                                  .toList(),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Instrucciones (sección plegable)
                  Card(
                    child: Column(
                      children: [
                        _buildSectionTitle(
                          '📝 Instrucciones Básicas',
                          _showInstructions,
                          () => setState(() => _showInstructions = !_showInstructions),
                        ),
                        if (_showInstructions) ...[
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Pasos generales para realizar este proyecto:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
                                _buildInstructionStep(1, 'Prepara todos los materiales según las cantidades indicadas'),
                                _buildInstructionStep(2, 'Realiza los cortes de cuerda según las especificaciones'),
                                _buildInstructionStep(3, 'Sigue el tutorial en video para los nudos específicos'),
                                _buildInstructionStep(4, 'Comienza desde el centro y trabaja hacia los extremos'),
                                _buildInstructionStep(5, 'Ajusta la tensión uniformemente mientras trabajas'),
                                _buildInstructionStep(6, 'Realiza los acabados finales según el diseño'),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    '💡 Consejo: Mira el tutorial completo antes de comenzar para entender la secuencia de nudos.',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Botones de acción principales
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _openInDesigner,
                          icon: const Icon(Icons.edit),
                          label: const Text(
                            'Abrir en Diseñador',
                            style: TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B4513),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _launchTutorial,
                          icon: const Icon(Icons.play_circle_fill),
                          label: const Text(
                            'Ver Tutorial Completo',
                            style: TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _launchStore,
                          icon: const Icon(Icons.shopping_bag),
                          label: const Text(
                            'Comprar Materiales',
                            style: TextStyle(fontSize: 16),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF8B4513),
                            side: const BorderSide(color: Color(0xFF8B4513)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep(int number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFF8B4513),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}