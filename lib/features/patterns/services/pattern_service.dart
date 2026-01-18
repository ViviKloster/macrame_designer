import 'package:macrame_designer/features/patterns/models/pattern_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:macrame_designer/core/constants.dart';

class PatternService {
  // Usar la misma variable de AppConstants que usamos en DesignerScreen
  String get _apiBaseUrl => AppConstants.apiBaseUrl;
  
  // URL para patrones
  String get _patternsBaseUrl => '$_apiBaseUrl/api/patterns';
  
  Future<List<PatternDesign>> getPatterns() async {
    try {
      print('🔄 Cargando patrones desde API...');
      print('🌐 URL: $_patternsBaseUrl');
      
      final response = await http.get(
        Uri.parse(_patternsBaseUrl),
        headers: {'Accept': 'application/json'},
      );
      
      print('📥 Status Code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        // Manejar diferentes formatos de respuesta
        final dynamic responseData = jsonDecode(response.body);
        List<dynamic> patternsList = [];
        
        if (responseData is List) {
          // La API devolvió una lista directa
          patternsList = responseData;
        } else if (responseData is Map) {
          // Buscar la lista dentro del objeto
          if (responseData['data'] is List) {
            patternsList = responseData['data'];
          } else if (responseData['patterns'] is List) {
            patternsList = responseData['patterns'];
          } else if (responseData['results'] is List) {
            patternsList = responseData['results'];
          } else {
            // Buscar cualquier propiedad que sea lista
            for (var key in responseData.keys) {
              if (responseData[key] is List) {
                patternsList = responseData[key];
                break;
              }
            }
          }
        }
        
        // Convertir JSON a objetos PatternDesign
        final patterns = patternsList.map((patternJson) {
          try {
            return PatternDesign.fromJson(patternJson);
          } catch (e) {
            print('❌ Error parseando patrón: $e');
            print('📄 Datos del patrón: $patternJson');
            return _createFallbackPattern();
          }
        }).toList();
        
        print('✅ ${patterns.length} patrones cargados exitosamente');
        return patterns.where((p) => p.id.isNotEmpty).toList();
      } else {
        print('⚠️ API devolvió código ${response.statusCode}');
        print('📄 Respuesta: ${response.body}');
        return _getMockPatterns();
      }
    } catch (e) {
      print('❌ Error cargando patrones: $e');
      print('📄 Stack trace: ${e.toString()}');
      
      // Retornar datos de ejemplo para desarrollo
      return _getMockPatterns();
    }
  }
  
  // Patrón de respaldo si falla el parsing
  PatternDesign _createFallbackPattern() {
    return PatternDesign(
      id: 'fallback_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Patrón de ejemplo',
      author: 'Sistema',
      description: 'Patrón cargado automáticamente',
      imageUrl: '',
      youtubeTutorialUrl: '',
      storeUrl: '',
      difficulty: PatternDifficulty.beginner,
      estimatedHours: 3.0,
      tags: ['ejemplo', 'respaldo'],
      canBeDoubled: false,
      doubledSizeMultiplier: 1.0,
      materials: [
        MaterialRequirement(
          materialId: 'cord_default',
          name: 'Cordón estándar',
          thickness: 3.0,
          lengthPerUnit: 2.0,
          quantity: 10,
          knottedReduction: 0.25,
        ),
      ],
      cordCuts: [],
    );
  }
  
  // Datos de ejemplo para desarrollo
  List<PatternDesign> _getMockPatterns() {
    return [
      PatternDesign(
        id: '1',
        name: 'Tapiz Diamante',
        author: 'Ana López',
        description: 'Tapiz moderno con diseño geométrico en forma de diamante',
        imageUrl: '',
        youtubeTutorialUrl: 'https://youtube.com/watch?v=abc123',
        storeUrl: 'https://tienda.com/tapiz-diamante',
        difficulty: PatternDifficulty.beginner,
        estimatedHours: 4.5,
        tags: ['tapiz', 'geometrico', 'principiante'],
        canBeDoubled: true,
        doubledSizeMultiplier: 2.0,
        materials: [
          MaterialRequirement(
            materialId: 'cord_3mm',
            name: 'Cordón de algodón 3mm',
            thickness: 3.0,
            lengthPerUnit: 2.5,
            quantity: 20,
            knottedReduction: 0.3,
          ),
        ],
        cordCuts: [
          CordCut(
            name: 'Tiras principales',
            length: 2.0,
            quantity: 10,
            isDoubled: true,
            unknottedLength: 2.4,
          ),
        ],
      ),
      PatternDesign(
        id: '2',
        name: 'Portamacetas Colgante',
        author: 'Carlos Ruiz',
        description: 'Portamacetas tejido con nudos espirales',
        imageUrl: '',
        youtubeTutorialUrl: 'https://youtube.com/watch?v=def456',
        storeUrl: 'https://tienda.com/portamacetas-colgante',
        difficulty: PatternDifficulty.intermediate,
        estimatedHours: 6.0,
        tags: ['portamacetas', 'colgante', 'intermedio'],
        canBeDoubled: false,
        doubledSizeMultiplier: 1.0,
        materials: [
          MaterialRequirement(
            materialId: 'cord_4mm',
            name: 'Cordón de yute 4mm',
            thickness: 4.0,
            lengthPerUnit: 3.0,
            quantity: 15,
            knottedReduction: 0.25,
          ),
        ],
        cordCuts: [],
      ),
      PatternDesign(
        id: '3',
        name: 'Espejo Boho',
        author: 'María González',
        description: 'Marco de espejo con detalles boho chic',
        imageUrl: '',
        youtubeTutorialUrl: 'https://youtube.com/watch?v=ghi789',
        storeUrl: 'https://tienda.com/espejo-boho',
        difficulty: PatternDifficulty.advanced,
        estimatedHours: 10.0,
        tags: ['espejo', 'decoracion', 'avanzado'],
        canBeDoubled: true,
        doubledSizeMultiplier: 1.5,
        materials: [
          MaterialRequirement(
            materialId: 'cord_5mm',
            name: 'Cordón de algodón trenzado 5mm',
            thickness: 5.0,
            lengthPerUnit: 4.0,
            quantity: 25,
            knottedReduction: 0.35,
          ),
        ],
        cordCuts: [],
      ),
      PatternDesign(
        id: '4',
        name: 'Colgante Lunar',
        author: 'Lucía Martínez',
        description: 'Colgante decorativo con forma de luna creciente',
        imageUrl: '',
        youtubeTutorialUrl: 'https://youtube.com/watch?v=jkl012',
        storeUrl: 'https://tienda.com/colgante-lunar',
        difficulty: PatternDifficulty.intermediate,
        estimatedHours: 5.0,
        tags: ['colgante', 'decorativo', 'luna'],
        canBeDoubled: false,
        doubledSizeMultiplier: 1.0,
        materials: [
          MaterialRequirement(
            materialId: 'cord_2mm',
            name: 'Cordón delgado 2mm',
            thickness: 2.0,
            lengthPerUnit: 1.5,
            quantity: 8,
            knottedReduction: 0.2,
          ),
        ],
        cordCuts: [],
      ),
      PatternDesign(
        id: '5',
        name: 'Cortina de Macramé',
        author: 'Roberto Sánchez',
        description: 'Cortina decorativa con diseño de hojas',
        imageUrl: '',
        youtubeTutorialUrl: 'https://youtube.com/watch?v=mno345',
        storeUrl: 'https://tienda.com/cortina-macrame',
        difficulty: PatternDifficulty.advanced,
        estimatedHours: 12.0,
        tags: ['cortina', 'decoracion', 'grande'],
        canBeDoubled: true,
        doubledSizeMultiplier: 2.5,
        materials: [
          MaterialRequirement(
            materialId: 'cord_6mm',
            name: 'Cordón grueso 6mm',
            thickness: 6.0,
            lengthPerUnit: 5.0,
            quantity: 30,
            knottedReduction: 0.4,
          ),
        ],
        cordCuts: [],
      ),
      PatternDesign(
        id: '6',
        name: 'Pulsera Friendship',
        author: 'Sofía Ramírez',
        description: 'Pulsera de amistad con colores vibrantes',
        imageUrl: '',
        youtubeTutorialUrl: 'https://youtube.com/watch?v=pqr678',
        storeUrl: 'https://tienda.com/pulsera-friendship',
        difficulty: PatternDifficulty.beginner,
        estimatedHours: 1.5,
        tags: ['pulsera', 'accesorio', 'rapido'],
        canBeDoubled: false,
        doubledSizeMultiplier: 1.0,
        materials: [
          MaterialRequirement(
            materialId: 'cord_1mm',
            name: 'Hilo de algodón 1mm',
            thickness: 1.0,
            lengthPerUnit: 0.8,
            quantity: 6,
            knottedReduction: 0.1,
          ),
        ],
        cordCuts: [],
      ),
    ];
  }
  
  // Método para guardar patrones
  Future<bool> savePattern(PatternDesign pattern) async {
    try {
      print('💾 Guardando patrón: ${pattern.name}');
      print('🌐 URL: $_patternsBaseUrl');
      
      final response = await http.post(
        Uri.parse(_patternsBaseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(pattern.toJson()),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Patrón guardado exitosamente');
        return true;
      } else {
        print('❌ Error guardando patrón. Status: ${response.statusCode}');
        print('📄 Respuesta: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error de conexión al guardar patrón: $e');
      return false;
    }
  }
  
  // Método para actualizar un patrón
  Future<bool> updatePattern(PatternDesign pattern) async {
    try {
      final response = await http.put(
        Uri.parse('$_patternsBaseUrl/${pattern.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(pattern.toJson()),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error actualizando patrón: $e');
      return false;
    }
  }
  
  // Método para eliminar un patrón
  Future<bool> deletePattern(String patternId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_patternsBaseUrl/$patternId'),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error eliminando patrón: $e');
      return false;
    }
  }
  
  // Método para buscar patrones por nombre o tags
  Future<List<PatternDesign>> searchPatterns(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_patternsBaseUrl/search?q=$query'),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => PatternDesign.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error buscando patrones: $e');
      return [];
    }
  }
  
  // Método para obtener un patrón específico
  Future<PatternDesign?> getPatternById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$_patternsBaseUrl/$id'),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return PatternDesign.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error obteniendo patrón: $e');
      return null;
    }
  }
}