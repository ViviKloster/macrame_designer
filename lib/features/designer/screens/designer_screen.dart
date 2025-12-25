import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:macrame_designer/core/constants.dart';
import 'package:macrame_designer/features/designer/widgets/interleaved_grid.dart';
import 'package:macrame_designer/features/designer/models/grid_model.dart';
import 'package:macrame_designer/features/patterns/models/pattern_model.dart';
import 'package:macrame_designer/features/designer/services/material_calculator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class DesignerScreen extends StatefulWidget {
  final PatternDesign? initialPattern;
  final File? initialImage;
  
  const DesignerScreen({super.key, this.initialPattern, this.initialImage});

  @override
  State<DesignerScreen> createState() => _DesignerScreenState();
}

class _DesignerScreenState extends State<DesignerScreen> with WidgetsBindingObserver {
  // Variables de estado
  final List<PlacedKnot> _placedKnots = [];
  final List<List<PlacedKnot>> _undoStack = [];
  
  Color _cordColor = const Color(0xFF8B4513);
  double _cellSize = AppConstants.defaultCellSize;
  double _cordThickness = AppConstants.defaultCordThickness;
  String _projectName = AppConstants.defaultProjectName;
  KnotType? _selectedKnotForPlacement;
  bool _hasUnsavedChanges = false;
  File? _loadedImage;
  
  // URL de tu backend API
  static const String _apiBaseUrl = 'http://localhost:3001';
  
  // Tipos de nudos disponibles
  final List<KnotType> _knotTypes = [
    KnotType(
      id: 'square_knot',
      name: 'Nudo Cuadrado',
      icon: Icons.square,
      color: const Color(0xFF8B4513),
      lengthMultiplier: 8.0,
      description: 'Nudo básico para patrones principales',
    ),
    KnotType(
      id: 'half_hitch',
      name: 'Medio Nudo',
      icon: Icons.change_history,
      color: const Color(0xFFA0522D),
      lengthMultiplier: 4.0,
      description: 'Para bordes y terminaciones',
    ),
    KnotType(
      id: 'spiral_knot',
      name: 'Nudo Espiral',
      icon: Icons.autorenew,
      color: const Color(0xFFD2691E),
      lengthMultiplier: 12.0,
      description: 'Patrón decorativo en espiral',
    ),
    KnotType(
      id: 'berry_knot',
      name: 'Nudo Baya',
      icon: Icons.circle,
      color: const Color(0xFF8B7355),
      lengthMultiplier: 15.0,
      description: 'Nudo decorativo en forma de bolitas',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Si hay un patrón inicial, cargarlo
    if (widget.initialPattern != null) {
      _loadFromPattern(widget.initialPattern!);
    }
    
    // Si hay una imagen inicial, procesarla
    if (widget.initialImage != null) {
      _loadedImage = widget.initialImage;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _processLoadedImage();
      });
    }

    // Seleccionar el primer nudo por defecto
    if (_knotTypes.isNotEmpty) {
      _selectedKnotForPlacement = _knotTypes.first;
    }
    
    // Preguntar nombre al inicio solo si no hay imagen o patrón inicial
    if (widget.initialPattern == null && widget.initialImage == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _askForProjectName();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<bool> didPopRoute() async {
    return await _handleExit();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && _hasUnsavedChanges) {
      _showExitConfirmation();
    }
  }

  Future<bool> _handleExit() async {
    if (!_hasUnsavedChanges) return true;
    
    return await _showExitConfirmation();
  }

  Future<bool> _showExitConfirmation() async {
    if (!_hasUnsavedChanges) return true;
    
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('¿Guardar cambios?'),
          content: Text(
            'Tienes cambios sin guardar en "$_projectName". '
            '¿Quieres guardar antes de salir?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Salir sin guardar'),
              onPressed: () {
                Navigator.of(context).pop(true); // Salir
              },
            ),
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(false); // Quedarse
              },
            ),
            ElevatedButton(
              child: const Text('Guardar y salir'),
              onPressed: () async {
                Navigator.of(context).pop(false);
                await _saveDesign(askForName: false);
                if (mounted && !_hasUnsavedChanges) {
                  Navigator.of(context).pop(true);
                }
              },
            ),
          ],
        );
      },
    );
    
    return result ?? false;
  }

  void _processLoadedImage() {
    if (_loadedImage == null) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Imagen cargada'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.file(
              _loadedImage!,
              height: 150,
              width: 150,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 16),
            const Text('¿Qué deseas hacer con esta imagen?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _createFromImage();
            },
            child: const Text('Crear diseño'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _analyzeImage();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue,
            ),
            child: const Text('Analizar patrón'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _loadedImage = null;
            },
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _createFromImage() {
    // Aquí puedes implementar conversión de imagen a patrón
    // Por ahora, simplemente usamos la imagen como inspiración
    _updateProjectName('Diseño desde imagen');
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Imagen cargada como inspiración. Ahora puedes crear tu diseño.'),
        ),
      );
    }
  }

  void _analyzeImage() {
    // Función para analizar patrones en la imagen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Analizar imagen'),
        content: const Text(
          'Esta función analiza la imagen para detectar patrones de nudos.\n\n'
          'Funcionalidades incluidas:\n'
          '• Detección automática de nudos\n'
          '• Estimación de dificultad\n'
          '• Sugerencias de materiales\n\n'
          'Próximamente...',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // NUEVA FUNCIÓN: Subir imagen desde galería directamente en el diseñador
  Future<void> _uploadImageFromGallery() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      
      if (pickedFile != null) {
        setState(() {
          _loadedImage = File(pickedFile.path);
        });
        _processLoadedImage();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // NUEVA FUNCIÓN: Tomar foto directamente en el diseñador
  Future<void> _takePhotoInDesigner() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      
      if (pickedFile != null) {
        setState(() {
          _loadedImage = File(pickedFile.path);
        });
        _processLoadedImage();
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

  // GUARDAR DISEÑO EN MYSQL VIA API (CON NUDOS)
  Future<void> _saveDesign({bool askForName = true, String? customName}) async {
    try {
      String designName;
      
      if (customName != null && customName.trim().isNotEmpty) {
        designName = customName.trim();
        _updateProjectName(designName);
      }
      else if (_projectName == 'Nuevo Diseño' || askForName) {
        final result = await _showSaveNameDialog(currentName: _projectName);
        if (result == null) return;
        designName = result;
        _updateProjectName(designName);
      }
      else {
        designName = _projectName;
      }

      final List<Map<String, dynamic>> knotsToSave = _placedKnots.map((knot) {
        return {
          'id': knot.id,
          'typeId': knot.type.id,
          'typeName': knot.type.name,
          'row': knot.cell.row,
          'col': knot.cell.col,
          'isOffsetRow': knot.cell.isOffsetRow,
          'color': '#${knot.type.color.value.toRadixString(16).padLeft(8, '0')}',
          'placedAt': knot.placedAt.toIso8601String(),
        };
      }).toList();

      final designData = {
        'name': designName,
        'description': 'Diseño creado en Macrame Designer',
        'cellSize': _cellSize,
        'cordThickness': _cordThickness,
        'cordColor': '#${_cordColor.value.toRadixString(16).padLeft(8, '0')}',
        'knots': knotsToSave,
        'imagePath': _loadedImage?.path,
      };

      print('📤 Guardando diseño: "$designName" con ${knotsToSave.length} nudos');
      
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/api/designs'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(designData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> result = jsonDecode(response.body);
        final projectId = result['projectId'];
        
        setState(() {
          _hasUnsavedChanges = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ "$designName" guardado (ID: $projectId)'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        
        print('✅ Diseño guardado. ID: $projectId');
      } else {
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error guardando: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<String?> _showSaveNameDialog({String currentName = ''}) async {
    final TextEditingController nameController = TextEditingController(
      text: currentName == 'Nuevo Diseño' ? '' : currentName,
    );
    
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Guardar Diseño'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Asigna un nombre a tu diseño:',
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del diseño',
                  hintText: 'Ej: Tapiz floral, Portamacetas...',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              if (_placedKnots.isNotEmpty)
                Text('🪢 Nudos colocados: ${_placedKnots.length}',
                    style: const TextStyle(color: Colors.grey)),
              if (_loadedImage != null)
                Text('🖼️ Imagen de referencia incluida',
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(null),
            ),
            ElevatedButton(
              child: const Text('Guardar'),
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  Navigator.of(context).pop(name);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor ingresa un nombre'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B4513),
              ),
            ),
          ],
        );
      },
    );
  }

  // CARGAR DISEÑOS DESDE MYSQL
  Future<void> _loadDesign() async {
    try {
      print('🔄 Iniciando carga de diseños desde MySQL...');
      
      final response = await http.get(Uri.parse('$_apiBaseUrl/api/designs'));
      
      print('📥 Respuesta HTTP: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        
        print('📊 Estructura de respuesta: ${responseData.keys}');
        print('✅ success: ${responseData['success']}');
        print('📊 count: ${responseData['count']}');
        print('📦 data type: ${responseData['data']?.runtimeType}');
        
        if (responseData['success'] == true && responseData['data'] is List) {
          final List<dynamic> designsList = responseData['data'];
          
          print('🎉 ${designsList.length} diseños encontrados');
          
          if (designsList.isEmpty) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Cargar Diseño'),
                content: const Text('No hay diseños guardados en la base de datos.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
            return;
          }
          
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Diseños Guardados en MySQL'),
              content: SizedBox(
                width: 400,
                height: 400,
                child: ListView.builder(
                  itemCount: designsList.length,
                  itemBuilder: (context, index) {
                    final design = designsList[index] as Map<String, dynamic>;
                    return ListTile(
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _parseColor(design['cord_color']?.toString() ?? '#000000'),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      title: Text(design['name']?.toString() ?? 'Sin nombre'),
                      subtitle: Text(
                        'Celda: ${design['cell_size'] ?? '?'}px • ${_formatDate(design['created_at']?.toString() ?? '')}'
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('ID: ${design['id']}'),
                          IconButton(
                            icon: const Icon(Icons.download, color: Colors.blue),
                            onPressed: () => _loadSpecificDesign(design['id']),
                          ),
                        ],
                      ),
                    );
                  },
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
        } else {
          throw Exception('Formato de respuesta inválido: ${response.body}');
        }
      } else {
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error cargando diseños: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error cargando: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  // Cargar un diseño específico desde MySQL (CON NUDOS)
  Future<void> _loadSpecificDesign(int projectId) async {
    // Mostrar diálogo de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Cargando diseño...'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('ID: $projectId'),
          ],
        ),
      ),
    );

    try {
      print('🎯 Cargando diseño específico ID: $projectId');
      
      final response = await http.get(Uri.parse('$_apiBaseUrl/api/designs/$projectId'));
      
      print('📥 Respuesta HTTP: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        
        if (responseData['success'] == true) {
          final Map<String, dynamic> design = responseData['data'];
          
          final List<dynamic> knotsData = 
              design['knots'] ?? design['gridData'] ?? [];
          
          print('✅ Diseño cargado desde MySQL:');
          print('  Nombre: ${design['name']}');
          print('  ID: ${design['id']}');
          print('  Celda: ${design['cell_size'] ?? design['cellSize']}px');
          print('  Color: ${design['cord_color'] ?? design['cordColor']}');
          print('  Grosor: ${design['cord_thickness'] ?? design['cordThickness']}');
          print('  Nudos encontrados: ${knotsData.length}');
          
          setState(() {
            _cellSize = ((design['cell_size'] ?? design['cellSize']) as num?)?.toDouble() ?? 60.0;
            _cordThickness = ((design['cord_thickness'] ?? design['cordThickness']) as num?)?.toDouble() ?? 3.0;
            _cordColor = _parseColor((design['cord_color'] ?? design['cordColor'])?.toString() ?? '#000000');
            
            _projectName = design['name']?.toString() ?? 'Diseño cargado';
            _hasUnsavedChanges = false;
            
            if (knotsData.isNotEmpty) {
              _saveForUndo();
              _placedKnots.clear();
              
              for (var knotData in knotsData) {
                try {
                  final knotTypeId = knotData['typeId']?.toString() ?? '';
                  
                  KnotType knotType = _knotTypes.firstWhere(
                    (type) => type.id == knotTypeId,
                    orElse: () => _knotTypes.first,
                  );
                  
                  final cell = GridCell(
                    (knotData['row'] as num?)?.toInt() ?? 0,
                    (knotData['col'] as num?)?.toInt() ?? 0,
                    isOffsetRow: knotData['isOffsetRow'] ?? false,
                  );
                  
                  final placedKnot = PlacedKnot(
                    id: knotData['id']?.toString() ?? 
                        '${DateTime.now().millisecondsSinceEpoch}_${knotType.id}',
                    type: knotType,
                    cell: cell,
                    placedAt: knotData['placedAt'] != null 
                        ? DateTime.tryParse(knotData['placedAt']) ?? DateTime.now()
                        : DateTime.now(),
                  );
                  
                  _placedKnots.add(placedKnot);
                  
                  print('    → Nudo: ${knotType.name} en (${cell.row}, ${cell.col}), offset: ${cell.isOffsetRow}');
                } catch (e) {
                  print('    ⚠️ Error procesando nudo: $e');
                  print('    ⚠️ Datos del nudo: $knotData');
                }
              }
              
              print('✅ ${_placedKnots.length} nudos restaurados exitosamente');
            } else {
              print('ℹ️ No hay datos de nudos para restaurar');
            }
          });
          
          if (mounted) {
            Navigator.pop(context);
            Navigator.pop(context);
          }
          
          if (mounted) {
            final message = knotsData.isNotEmpty 
                ? '✅ Diseño "${design['name']}" cargado\n📏 Celda: ${_cellSize.toInt()}px | 🎨 Color: ${design['cord_color']} | 🪢 Nudos: ${knotsData.length}'
                : '✅ Diseño "${design['name']}" cargado\n📏 Celda: ${_cellSize.toInt()}px | 🎨 Color: ${design['cord_color']}';
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 4),
                action: SnackBarAction(
                  label: 'OK',
                  onPressed: () {},
                ),
              ),
            );
          }
          
        } else {
          throw Exception('Error en respuesta del servidor');
        }
      } else if (response.statusCode == 404) {
        throw Exception('Diseño no encontrado (ID: $projectId)');
      } else {
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error cargando diseño específico: $e');
      
      if (mounted) {
        Navigator.pop(context);
        Navigator.pop(context);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error cargando diseño: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _saveForUndo() {
    _undoStack.add(List.from(_placedKnots));
    if (_undoStack.length > 10) {
      _undoStack.removeAt(0);
    }
  }
  
  void _undo() {
    if (_undoStack.isNotEmpty) {
      final previousState = _undoStack.removeLast();
      setState(() {
        _placedKnots.clear();
        _placedKnots.addAll(previousState);
        _hasUnsavedChanges = true;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Acción deshecha'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No hay acciones para deshacer'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => _askForProjectName(),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _projectName,
                  style: const TextStyle(fontSize: 18),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (_hasUnsavedChanges)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'No guardado',
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
        backgroundColor: const Color(0xFF8B4513),
        foregroundColor: Colors.white,
        actions: [
          // Botón para cargar imagen desde galería en el diseñador
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: _uploadImageFromGallery,
            tooltip: 'Cargar imagen como inspiración',
          ),
          // Botón para tomar foto en el diseñador
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: _takePhotoInDesigner,
            tooltip: 'Tomar foto como inspiración',
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _askForProjectName(),
            tooltip: 'Renombrar proyecto',
          ),
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.undo),
                if (_hasUnsavedChanges)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        '!',
                        style: TextStyle(
                          fontSize: 8,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _undo,
            tooltip: 'Deshacer última acción',
          ),
          IconButton(
            icon: const Icon(Icons.grid_on),
            onPressed: _showGridDebug,
            tooltip: 'Mostrar información de cuadrícula',
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_add),
            onPressed: _saveAsPattern,
            tooltip: 'Guardar como patrón',
          ),
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.save),
                if (_hasUnsavedChanges)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        '!',
                        style: TextStyle(
                          fontSize: 8,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () => _saveDesign(askForName: false),
            tooltip: 'Guardar en MySQL (rápido)',
          ),
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: _loadDesign,
            tooltip: 'Cargar desde MySQL',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareDesign,
            tooltip: 'Compartir',
          ),
          IconButton(
            icon: const Icon(Icons.bolt, color: Colors.amber),
            onPressed: _testApiConnection,
            tooltip: 'Probar conexión API',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildToolbar(),
          
          // Mostrar imagen cargada si existe
          if (_loadedImage != null)
            Container(
              height: 100,
              padding: const EdgeInsets.all(8),
              color: Colors.grey[100],
              child: Row(
                children: [
                  Image.file(
                    _loadedImage!,
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Imagen de referencia:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _loadedImage!.path.split('/').last,
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () {
                      setState(() {
                        _loadedImage = null;
                      });
                    },
                    tooltip: 'Quitar imagen',
                  ),
                ],
              ),
            ),
          
          Expanded(
            child: InterleavedGrid(
              cellSize: _cellSize,
              placedKnots: _placedKnots,
              rows: 30,
              columns: 30,
              onKnotPlaced: (GridCell cell, KnotType knotType, PlacedKnot? knotToReplace) {
                _saveForUndo();
                
                setState(() {
                  if (knotToReplace != null) {
                    _placedKnots.removeWhere((k) => k.id == knotToReplace.id);
                  }
                  
                  _placedKnots.add(PlacedKnot(
                    id: '${DateTime.now().millisecondsSinceEpoch}_${knotType.id}',
                    type: knotType,
                    cell: cell,
                    placedAt: DateTime.now(),
                  ));
                  
                  _hasUnsavedChanges = true;
                });
              },
              selectedKnotType: _selectedKnotForPlacement,
            ),
          ),
          
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Colors.grey[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.zoom_out),
                  onPressed: () {
                    setState(() {
                      _cellSize = (_cellSize - 10).clamp(30.0, 120.0);
                    });
                  },
                  tooltip: 'Achicar cuadrícula',
                ),
                const SizedBox(width: 8),
                Text(
                  'Tamaño celda: ${_cellSize.toInt()}px',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.zoom_in),
                  onPressed: () {
                    setState(() {
                      _cellSize = (_cellSize + 10).clamp(30.0, 120.0);
                    });
                  },
                  tooltip: 'Agrandar cuadrícula',
                ),
              ],
            ),
          ),
          
          _buildKnotsPalette(),
        ],
      ),
      
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCalculator(context),
        backgroundColor: const Color(0xFF8B4513),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.calculate),
        label: Text('Calcular (${_placedKnots.length})'),
      ),
    );
  }

  Future<void> _testApiConnection() async {
    try {
      print('🔌 Probando conexión a API...');
      final response = await http.get(Uri.parse('$_apiBaseUrl/api/health'));
      
      print('📥 Respuesta: ${response.statusCode}');
      print('📄 Body: ${response.body}');
      
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Conexión API exitosa'),
              backgroundColor: Colors.green,
            ),
          );
        }
        print('✅ API conectada correctamente');
      } else {
        throw Exception('API respondió con código ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error conectando a API: $e\nAsegúrate de que el backend esté corriendo en $_apiBaseUrl'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      print('❌ Error API: $e');
    }
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              Text('Grosor: ${_cordThickness.toStringAsFixed(1)}mm'),
              Slider(
                value: _cordThickness,
                min: 1.0,
                max: 10.0,
                divisions: 18,
                onChanged: (value) {
                  setState(() {
                    _cordThickness = value;
                    _hasUnsavedChanges = true;
                  });
                },
              ),
            ],
          ),
          
          Column(
            children: [
              const Text('Color'),
              GestureDetector(
                onTap: _changeColor,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _cordColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          Column(
            children: [
              const Text('Nudo activo'),
              if (_selectedKnotForPlacement != null)
                GestureDetector(
                  onTap: _showKnotSelector,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _selectedKnotForPlacement!.color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      _selectedKnotForPlacement!.icon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                )
              else
                GestureDetector(
                  onTap: _showKnotSelector,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: const Icon(Icons.question_mark),
                  ),
                ),
            ],
          ),
          
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.red),
            onPressed: _clearAll,
            tooltip: 'Borrar todo',
          ),
        ],
      ),
    );
  }

  Widget _buildKnotsPalette() {
    return Container(
      height: 100,
      color: Colors.grey[50],
      padding: const EdgeInsets.all(8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _knotTypes.map((knotType) {
          final isSelected = _selectedKnotForPlacement?.id == knotType.id;
          
          return Draggable<KnotType>(
            data: knotType,
            feedback: _buildKnotWidget(knotType, isDragging: true),
            childWhenDragging: Opacity(
              opacity: 0.5,
              child: _buildKnotWidget(knotType),
            ),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedKnotForPlacement = knotType;
                });
              },
              child: _buildKnotWidget(knotType, isSelected: isSelected),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKnotWidget(KnotType type, {bool isDragging = false, bool isSelected = false}) {
    return Container(
      width: 80,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: isDragging ? 60 : (isSelected ? 55 : 50),
            height: isDragging ? 60 : (isSelected ? 55 : 50),
            decoration: BoxDecoration(
              color: type.color,
              borderRadius: BorderRadius.circular(isDragging ? 15 : 10),
              boxShadow: isDragging
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
              border: Border.all(
                color: isDragging ? Colors.white : 
                      isSelected ? Colors.blue : Colors.black,
                width: isDragging ? 2 : (isSelected ? 2 : 1),
              ),
            ),
            child: Icon(
              type.icon,
              color: Colors.white,
              size: isDragging ? 35 : (isSelected ? 30 : 28),
            ),
          ),
          if (!isDragging) ...[
            const SizedBox(height: 4),
            Text(
              type.name.split(' ').last,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.blue : Colors.black,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _askForProjectName() async {
    final TextEditingController nameController = TextEditingController(
      text: _projectName == 'Nuevo Diseño' ? '' : _projectName,
    );

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Nombre del Proyecto'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Nombre del proyecto',
              hintText: 'Ej: Tapiz floral, Portamacetas...',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                _updateProjectName(value.trim());
                Navigator.of(context).pop();
              }
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Omitir'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Guardar'),
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  _updateProjectName(name);
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B4513),
              ),
            ),
          ],
        );
      },
    );
  }

  void _updateProjectName(String newName) {
    setState(() {
      _projectName = newName;
      _hasUnsavedChanges = true;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Proyecto renombrado a: "$newName"'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _loadFromPattern(PatternDesign pattern) {
    setState(() {
      _projectName = pattern.name;
      _cordThickness = pattern.materials.isNotEmpty 
          ? pattern.materials.first.thickness 
          : AppConstants.defaultCordThickness;
      
      _hasUnsavedChanges = true;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Patrón "${pattern.name}" cargado en diseñador'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
  
  Future<void> _saveAsPattern() async {
    final name = await _showPatternNameDialog();
    if (name == null) return;
    
    // Crear MaterialRequirement basado en los nudos actuales
    final totalLength = MaterialCalculator.calculateMaterial(
      placedKnots: _placedKnots,
      cordThickness: _cordThickness,
      safetyMargin: 15.0,
    ).totalLengthM;
    
    final newPattern = PatternDesign(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: 'Diseño personalizado creado en Macrame Designer',
      imageUrl: '', // Podrías generar un screenshot
      youtubeTutorialUrl: '',
      storeUrl: 'https://tu-tienda.com/user-designs',
      difficulty: _estimateDifficulty(),
      estimatedHours: _placedKnots.length * 0.1,
      tags: ['personalizado', 'usuario'],
      canBeDoubled: true,
      doubledSizeMultiplier: 2.0,
      materials: [
        MaterialRequirement(
          materialId: 'user_cord_${_cordThickness}mm',
          name: 'Cordón ${_cordThickness}mm',
          thickness: _cordThickness,
          lengthPerUnit: _placedKnots.isEmpty ? 0 : totalLength / _placedKnots.length,
          quantity: _placedKnots.length,
          knottedReduction: 0.3,
        ),
      ],
      cordCuts: _calculateCordCuts(totalLength),
    );
    
    // Guardar en tu API o localmente
    await _savePatternToApi(newPattern);
  }
  
  PatternDifficulty _estimateDifficulty() {
    final knotTypes = _placedKnots.map((k) => k.type.id).toSet();
    if (knotTypes.length > 3) return PatternDifficulty.advanced;
    if (knotTypes.length > 1) return PatternDifficulty.intermediate;
    return PatternDifficulty.beginner;
  }
  
  List<CordCut> _calculateCordCuts(double totalLength) {
    // Lógica simple para calcular cortes
    const avgCutLength = 2.5; // metros promedio por corte
    final numCuts = totalLength > 0 ? (totalLength / avgCutLength).ceil() : 0;
    
    return [
      CordCut(
        name: 'Tiras principales',
        length: avgCutLength,
        quantity: numCuts,
        isDoubled: false,
        unknottedLength: avgCutLength * 1.2,
      ),
    ];
  }
  
  Future<String?> _showPatternNameDialog() async {
    final controller = TextEditingController(text: _projectName);
    
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Guardar como Patrón'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nombre del patrón',
            hintText: 'Ej: Mi diseño personalizado',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(context, name);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  // Método para guardar patrón en API (implementar según tu backend)
  Future<void> _savePatternToApi(PatternDesign pattern) async {
    try {
      // TODO: Implementar llamada a tu API para guardar patrones
      print('📤 Guardando patrón en API: ${pattern.name}');
      
      // Por ahora solo muestra un mensaje
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Patrón "${pattern.name}" guardado localmente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ Error guardando patrón: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error guardando patrón: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showKnotSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar tipo de nudo'),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _knotTypes.map((knotType) {
              final isSelected = _selectedKnotForPlacement?.id == knotType.id;
              
              return ListTile(
                leading: Icon(
                  knotType.icon,
                  color: knotType.color,
                ),
                title: Text(knotType.name),
                subtitle: Text(knotType.description),
                trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
                tileColor: isSelected ? Colors.blue.withOpacity(0.1) : null,
                onTap: () {
                  setState(() {
                    _selectedKnotForPlacement = knotType;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
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

  void _showGridDebug() {
    if (_placedKnots.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay nudos colocados para debug')),
        );
      }
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🔍 Información de Cuadrícula'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total nudos: ${_placedKnots.length}'),
              Text('Tamaño celda: ${_cellSize.toInt()}px'),
              const Text('Filas: 30, Columnas: 30'),
              const SizedBox(height: 16),
              const Text('Tipos de nudos colocados:'),
              ..._knotTypes.map((type) {
                final count = _placedKnots.where((k) => k.type.id == type.id).length;
                if (count > 0) {
                  return Text('  • ${type.name}: $count');
                }
                return const SizedBox.shrink();
              }).toList(),
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

  void _showCalculator(BuildContext context) {
    final result = MaterialCalculator.calculateMaterial(
      placedKnots: _placedKnots,
      cordThickness: _cordThickness,
      safetyMargin: 15.0,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('📐 Calculadora de Material'),
          content: SizedBox(
            width: 350,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Cálculos basados en tus nudos:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildCalculationRow('Nudos colocados:', '${_placedKnots.length}'),
                _buildCalculationRow('Grosor del cordón:', '${_cordThickness.toStringAsFixed(1)} mm'),
                _buildCalculationRow('Longitud total:', '${result.totalLengthM.toStringAsFixed(1)} metros'),
                _buildCalculationRow('Rollos (50m):', '${result.standardRollsNeeded}'),
                _buildCalculationRow('Tiempo estimado:', '${result.estimatedHours.toStringAsFixed(1)} horas'),
                _buildCalculationRow('Costo aproximado:', '\$${result.estimatedCost.toStringAsFixed(2)}'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber),
                  ),
                  child: Text(
                    '💡 Recomendación: Compra ${(result.totalLengthM * 1.15).toStringAsFixed(1)} metros '
                    '(${(result.totalLengthM * 0.15).toStringAsFixed(1)}m extra) para margen.',
                    style: const TextStyle(fontSize: 12),
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
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showSaveDialog(context, result.totalLengthM, result.estimatedCost);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B4513),
              ),
              child: const Text('Guardar Diseño'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCalculationRow(String label, String value) {
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

  void _shareDesign() {
    // Implementar lógica de compartir
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Función de compartir en desarrollo')),
      );
    }
  }

  void _changeColor() {
    final colors = [
      const Color(0xFF8B4513),
      Colors.black,
      Colors.white,
      Colors.red,
      Colors.blue,
      Colors.green,
    ];
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Seleccionar color'),
          content: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: colors.map((color) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _cordColor = color;
                    _hasUnsavedChanges = true;
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _cordColor == color ? Colors.blue : Colors.grey,
                      width: _cordColor == color ? 3 : 1,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _clearAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Borrar todo?'),
        content: const Text('Se eliminarán todos los nudos del diseño.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              _saveForUndo();
              setState(() {
                _placedKnots.clear();
                _hasUnsavedChanges = true;
              });
              Navigator.pop(context);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Todos los nudos eliminados')),
                );
              }
            },
            child: const Text('Borrar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showSaveDialog(BuildContext context, double length, double cost) {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('💾 Guardar Diseño'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Asigna un nombre descriptivo a tu diseño:',
                style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del diseño',
                hintText: 'Ej: Tapiz floral grande',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              autofocus: true,
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  _saveDesign(customName: value.trim(), askForName: false);
                  Navigator.pop(context);
                }
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildInfoRow('🪢 Nudos colocados:', '${_placedKnots.length}'),
                  _buildInfoRow('📏 Tamaño celda:', '${_cellSize.toInt()}px'),
                  _buildInfoRow('📐 Longitud estimada:', '${length.toStringAsFixed(1)} m'),
                  _buildInfoRow('💰 Costo aproximado:', '\$${cost.toStringAsFixed(2)}'),
                ],
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                _saveDesign(customName: name, askForName: false);
                Navigator.pop(context);
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('⚠️ Por favor ingresa un nombre para tu diseño'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B4513),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.save, size: 18),
                SizedBox(width: 8),
                Text('Guardar en MySQL'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Color.fromARGB(255, 97, 97, 97))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Color _parseColor(String hexColor) {
    try {
      hexColor = hexColor.replaceAll('#', '');
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      print('❌ Error parseando color "$hexColor": $e');
      return const Color(0xFF8B4513);
    }
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return isoDate;
    }
  }
}