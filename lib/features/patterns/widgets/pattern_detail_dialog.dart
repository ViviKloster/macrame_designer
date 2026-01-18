// lib/features/patterns/widgets/pattern_detail_dialog.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PatternDetailDialog extends StatefulWidget {
  final Map<String, dynamic> work;
  
  const PatternDetailDialog({super.key, required this.work});

  @override
  State<PatternDetailDialog> createState() => _PatternDetailDialogState();
}

class _PatternDetailDialogState extends State<PatternDetailDialog> {
  int _currentImageIndex = 0;
  bool _showSimpleCord = true;
  bool _isPurchasing = false;

  @override
  Widget build(BuildContext context) {
    final work = widget.work;
    
    return Dialog(
      insetPadding: EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 1000, maxHeight: 800),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          work['name'],
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        Text(
                          work['category'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, size: 20),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Galería de imágenes
                    _buildImageGallery(work),
                    
                    SizedBox(height: 24),
                    
                    // Información principal en columnas
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Columna izquierda - Información básica
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Descripción
                              Text(
                                'Descripción',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2D3748),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                work['description'],
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                  height: 1.5,
                                ),
                              ),
                              
                              SizedBox(height: 24),
                              
                              // Especificaciones
                              Text(
                                'Especificaciones',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2D3748),
                                ),
                              ),
                              SizedBox(height: 12),
                              _buildSpecifications(work),
                              
                              SizedBox(height: 24),
                              
                              // Materiales necesarios
                              Text(
                                'Materiales necesarios',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2D3748),
                                ),
                              ),
                              SizedBox(height: 8),
                              _buildMaterialsList(work['materials']),
                            ],
                          ),
                        ),
                        
                        SizedBox(width: 32),
                        
                        // Columna derecha - Medidas y acciones
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Medidas de cordón
                              _buildCordMeasurements(work),
                              
                              SizedBox(height: 24),
                              
                              // Estadísticas
                              _buildProjectStats(work),
                              
                              SizedBox(height: 24),
                              
                              // Acciones
                              _buildActionButtons(work),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 32),
                    
                    // Video tutorial
                    if (work['youtubeUrl'] != null)
                      _buildVideoSection(work),
                  ],
                ),
              ),
            ),
            
            // Footer con precio y compra
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFF8F9FA),
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Precio del patrón',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        '\$${work['price']}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    ],
                  ),
                  
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          _watchVideoTutorial(work['youtubeUrl']);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          side: BorderSide(color: Color(0xFF4CAF50)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.play_circle_fill, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              'Ver Tutorial',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF4CAF50),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(width: 12),
                      
                      ElevatedButton(
                        onPressed: _isPurchasing ? null : () => _purchasePattern(work),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4CAF50),
                          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        ),
                        child: _isPurchasing
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                children: [
                                  Icon(Icons.shopping_cart, size: 16),
                                  SizedBox(width: 8),
                                  Text(
                                    'Comprar Patrón',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
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
          ],
        ),
      ),
    );
  }

  Widget _buildImageGallery(Map<String, dynamic> work) {
    final images = work['images'] as List<String>;
    
    return Column(
      children: [
        // Imagen principal
        Container(
          height: 300,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: AssetImage(images[_currentImageIndex]),
              fit: BoxFit.cover,
            ),
          ),
        ),
        
        // Miniaturas
        if (images.length > 1)
          Padding(
            padding: EdgeInsets.only(top: 12),
            child: SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    child: Container(
                      width: 80,
                      margin: EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        image: DecorationImage(
                          image: AssetImage(images[index]),
                          fit: BoxFit.cover,
                        ),
                        border: Border.all(
                          color: _currentImageIndex == index
                              ? Color(0xFF4CAF50)
                              : Colors.grey.shade300,
                          width: _currentImageIndex == index ? 2 : 1,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSpecifications(Map<String, dynamic> work) {
    return Table(
      columnWidths: {
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth(2),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Text(
                'Dificultad:',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(work['difficultyLevel'] as int),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      work['difficulty'],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Text(
                'Tiempo estimado:',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Text(
                work['time'],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2D3748),
                ),
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Text(
                'Pasos:',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Text(
                '${work['steps']} pasos detallados',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2D3748),
                ),
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Text(
                'Completado por:',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Text(
                '${work['completedBy']} personas',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2D3748),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMaterialsList(List<dynamic> materials) {
    return Column(
      children: materials.map<Widget>((material) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4,
                height: 4,
                margin: EdgeInsets.only(top: 6, right: 12),
                decoration: BoxDecoration(
                  color: Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      material['name'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    Text(
                      '${material['quantity']}${material['color'] != null ? ' • ${material['color']}' : ''}${material['size'] != null ? ' • ${material['size']}' : ''}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCordMeasurements(Map<String, dynamic> work) {
    final measurements = work['cordMeasurements'];
    final currentMeasurements = _showSimpleCord ? measurements['simple'] : measurements['double'];
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Medidas de cordón',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
              Row(
                children: [
                  Text(
                    'Simple',
                    style: TextStyle(
                      fontSize: 11,
                      color: _showSimpleCord ? Color(0xFF4CAF50) : Colors.grey.shade500,
                      fontWeight: _showSimpleCord ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  Switch(
                    value: !_showSimpleCord,
                    onChanged: (value) {
                      setState(() {
                        _showSimpleCord = !value;
                      });
                    },
                    activeColor: Color(0xFF4CAF50),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  Text(
                    'Doble',
                    style: TextStyle(
                      fontSize: 11,
                      color: !_showSimpleCord ? Color(0xFF4CAF50) : Colors.grey.shade500,
                      fontWeight: !_showSimpleCord ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          SizedBox(height: 12),
          
          Text(
            _showSimpleCord 
                ? 'Usa estas medidas si trabajas con cordón simple'
                : 'Usa estas medidas si doblas el cordón al empezar',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
          
          SizedBox(height: 12),
          
          ...currentMeasurements.map<Widget>((measure) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    child: Text(
                      measure['length'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                  ),
                  Container(
                    width: 40,
                    child: Text(
                      'x${measure['quantity']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      measure['purpose'],
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildProjectStats(Map<String, dynamic> work) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estadísticas del proyecto',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          
          SizedBox(height: 12),
          
          Row(
            children: [
              _buildStatCircle('Rating', '${work['rating']}', Icons.star, Colors.amber),
              SizedBox(width: 16),
              _buildStatCircle('Completado', '${work['completedBy']}', Icons.check_circle, Colors.green),
              SizedBox(width: 16),
              _buildStatCircle('Pasos', '${work['steps']}', Icons.list_alt, Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCircle(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(icon, size: 20, color: color),
            ),
          ),
          SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D3748),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> work) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            // Navegar a la pantalla de venta
            _navigateToMarketplace(work);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF2196F3),
            minimumSize: Size(double.infinity, 44),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.store, size: 16),
              SizedBox(width: 8),
              Text(
                'Ver en Mercado',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
        
        SizedBox(height: 8),
        
        OutlinedButton(
          onPressed: () {
            // Compartir proyecto
            _shareProject(work);
          },
          style: OutlinedButton.styleFrom(
            minimumSize: Size(double.infinity, 44),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.share, size: 16, color: Colors.grey.shade600),
              SizedBox(width: 8),
              Text(
                'Compartir',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(height: 8),
        
        TextButton(
          onPressed: () {
            // Añadir a favoritos
            _addToFavorites(work);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_border, size: 16, color: Colors.grey.shade600),
              SizedBox(width: 8),
              Text(
                'Añadir a favoritos',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVideoSection(Map<String, dynamic> work) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.play_circle_filled, size: 20, color: Colors.red),
              SizedBox(width: 8),
              Text(
                'Video Tutorial',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 12),
          
          Text(
            'Aprende paso a paso cómo realizar este proyecto con nuestro video tutorial en YouTube.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          
          SizedBox(height: 12),
          
          ElevatedButton.icon(
            onPressed: () {
              _watchVideoTutorial(work['youtubeUrl']);
            },
            icon: Icon(Icons.play_arrow, size: 16),
            label: Text('Ver Tutorial Completo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
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

  void _watchVideoTutorial(String? url) async {
    if (url == null) return;
    
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo abrir el video'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _purchasePattern(Map<String, dynamic> work) {
    setState(() {
      _isPurchasing = true;
    });
    
    // Simular proceso de compra
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _isPurchasing = false;
      });
      
      Navigator.pop(context); // Cerrar diálogo
      
      // Navegar a pantalla de checkout o mercado
      _navigateToMarketplace(work);
    });
  }

  void _navigateToMarketplace(Map<String, dynamic> work) {
    // Aquí iría la navegación a la pantalla de ventas/marketplace
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Redirigiendo al mercado para: ${work['name']}'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
  }

  void _shareProject(Map<String, dynamic> work) {
    // Implementar lógica para compartir
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Proyecto compartido: ${work['name']}'),
      ),
    );
  }

  void _addToFavorites(Map<String, dynamic> work) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Añadido a favoritos: ${work['name']}'),
        backgroundColor: Colors.pink,
      ),
    );
  }
}