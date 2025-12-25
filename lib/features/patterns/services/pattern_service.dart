// lib/src/features/patterns/services/pattern_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pattern_model.dart';

class PatternService {
  static const String _apiBaseUrl = 'http://localhost:3001'; // Cambia según tu backend
  
  // Cargar todos los patrones desde la API
  static Future<List<PatternDesign>> loadPatternsFromApi() async {
    try {
      print('🔄 Cargando patrones desde API...');
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/api/patterns'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        
        if (responseData['success'] == true && responseData['data'] is List) {
          final List<dynamic> patternsData = responseData['data'];
          
          final patterns = patternsData.map((patternData) {
            return PatternDesign.fromJson(patternData);
          }).toList();
          
          print('✅ ${patterns.length} patrones cargados desde API');
          return patterns;
        } else {
          print('⚠️ Formato de respuesta inválido, usando ejemplos');
          return PatternService.getSamplePatterns();
        }
      } else {
        print('⚠️ Error HTTP ${response.statusCode}, usando ejemplos');
        return PatternService.getSamplePatterns();
      }
    } catch (e) {
      print('❌ Error cargando patrones: $e');
      return PatternService.getSamplePatterns();
    }
  }

  // Guardar un patrón en la API
  static Future<bool> savePatternToApi(PatternDesign pattern) async {
    try {
      print('💾 Guardando patrón en API: ${pattern.name}');
      
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/api/patterns'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(pattern.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Patrón guardado exitosamente');
        return true;
      } else {
        print('❌ Error HTTP ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error guardando patrón: $e');
      return false;
    }
  }

  // Método para cargar patrones prediseñados (ejemplos)
  static List<PatternDesign> getSamplePatterns() {
    return [
      PatternDesign(
        id: '1',
        name: 'Tapiz triangular básico',
        description: 'Perfecto para principiantes. Diseño minimalista con nudos cuadrados y medios nudos.',
        imageUrl: 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400&h=300&fit=crop',
        youtubeTutorialUrl: 'https://www.youtube.com/watch?v=HxYjM-4rT7g',
        storeUrl: 'https://tu-tienda.com/patterns/triangular-basic',
        difficulty: PatternDifficulty.beginner,
        estimatedHours: 2.5,
        tags: ['principiante', 'decorativo', 'pared', 'triangular'],
        canBeDoubled: true,
        doubledSizeMultiplier: 1.8,
        materials: [
          MaterialRequirement(
            materialId: 'cord_5mm',
            name: 'Cordón de algodón 5mm',
            thickness: 5.0,
            lengthPerUnit: 4.0,
            quantity: 10,
            knottedReduction: 0.25,
          ),
        ],
        cordCuts: [
          CordCut(
            name: 'Tiras principales',
            length: 2.5,
            quantity: 8,
            isDoubled: true,
            unknottedLength: 5.5,
          ),
          CordCut(
            name: 'Tiras decorativas',
            length: 1.2,
            quantity: 4,
            isDoubled: false,
            unknottedLength: 1.4,
          ),
        ],
      ),
      PatternDesign(
        id: '2',
        name: 'Portamacetas colgante',
        description: 'Portamacetas con diseño de nudos espirales y bayas. Ideal para interiores.',
        imageUrl: 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400&h=300&fit=crop',
        youtubeTutorialUrl: 'https://www.youtube.com/watch?v=ejemplo2',
        storeUrl: 'https://tu-tienda.com/patterns/plant-hanger',
        difficulty: PatternDifficulty.intermediate,
        estimatedHours: 4.0,
        tags: ['plantas', 'colgante', 'interior', 'decorativo'],
        canBeDoubled: false,
        materials: [
          MaterialRequirement(
            materialId: 'cord_4mm',
            name: 'Cordón de yute 4mm',
            thickness: 4.0,
            lengthPerUnit: 3.0,
            quantity: 6,
            knottedReduction: 0.3,
          ),
          MaterialRequirement(
            materialId: 'beads',
            name: 'Cuentas de madera',
            thickness: 0.0,
            lengthPerUnit: 0.0,
            quantity: 8,
          ),
        ],
        cordCuts: [
          CordCut(
            name: 'Cuerdas de soporte',
            length: 3.0,
            quantity: 4,
            isDoubled: true,
            unknottedLength: 6.5,
          ),
          CordCut(
            name: 'Cuerdas decorativas',
            length: 2.0,
            quantity: 4,
            isDoubled: false,
            unknottedLength: 2.3,
          ),
        ],
      ),
      PatternDesign(
        id: '3',
        name: 'Cortina de macramé',
        description: 'Cortina decorativa con patrones complejos de nudos cuadrados y espirales.',
        imageUrl: 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400&h=300&fit=crop',
        youtubeTutorialUrl: 'https://www.youtube.com/watch?v=ejemplo3',
        storeUrl: 'https://tu-tienda.com/patterns/curtain',
        difficulty: PatternDifficulty.advanced,
        estimatedHours: 8.0,
        tags: ['cortina', 'decoración', 'ventana', 'grande'],
        canBeDoubled: true,
        doubledSizeMultiplier: 2.2,
        materials: [
          MaterialRequirement(
            materialId: 'cord_6mm',
            name: 'Cordón de algodón grueso 6mm',
            thickness: 6.0,
            lengthPerUnit: 8.0,
            quantity: 15,
            knottedReduction: 0.35,
          ),
        ],
        cordCuts: [
          CordCut(
            name: 'Tiras largas',
            length: 7.0,
            quantity: 12,
            isDoubled: true,
            unknottedLength: 15.0,
          ),
          CordCut(
            name: 'Tiras cortas decorativas',
            length: 1.5,
            quantity: 10,
            isDoubled: false,
            unknottedLength: 1.8,
          ),
        ],
      ),
      PatternDesign(
        id: '4',
        name: 'Espejo con marco de macramé',
        description: 'Marco decorativo para espejos con diseño circular y nudos de baya.',
        imageUrl: 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400&h=300&fit=crop',
        youtubeTutorialUrl: 'https://www.youtube.com/watch?v=ejemplo4',
        storeUrl: 'https://tu-tienda.com/patterns/mirror-frame',
        difficulty: PatternDifficulty.expert,
        estimatedHours: 6.5,
        tags: ['espejo', 'marco', 'circular', 'decorativo'],
        canBeDoubled: false,
        materials: [
          MaterialRequirement(
            materialId: 'cord_3mm',
            name: 'Cordón fino de algodón 3mm',
            thickness: 3.0,
            lengthPerUnit: 6.0,
            quantity: 8,
            knottedReduction: 0.4,
          ),
          MaterialRequirement(
            materialId: 'hoop',
            name: 'Aro de madera 30cm',
            thickness: 0.0,
            lengthPerUnit: 0.0,
            quantity: 1,
          ),
        ],
        cordCuts: [
          CordCut(
            name: 'Tiras para nudos',
            length: 5.0,
            quantity: 16,
            isDoubled: false,
            unknottedLength: 5.0,
          ),
          CordCut(
            name: 'Tiras para colgar',
            length: 0.8,
            quantity: 4,
            isDoubled: true,
            unknottedLength: 1.0,
          ),
        ],
      ),
      PatternDesign(
        id: '5',
        name: 'Pulsera básica de macramé',
        description: 'Pulsera simple con nudos cuadrados. Perfecta para principiantes y regalos.',
        imageUrl: 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400&h=300&fit=crop',
        youtubeTutorialUrl: 'https://www.youtube.com/watch?v=ejemplo5',
        storeUrl: 'https://tu-tienda.com/patterns/basic-bracelet',
        difficulty: PatternDifficulty.beginner,
        estimatedHours: 1.0,
        tags: ['pulsera', 'accesorio', 'principiante', 'regalo'],
        canBeDoubled: false,
        materials: [
          MaterialRequirement(
            materialId: 'cord_2mm',
            name: 'Cordón fino 2mm',
            thickness: 2.0,
            lengthPerUnit: 1.5,
            quantity: 4,
            knottedReduction: 0.2,
          ),
          MaterialRequirement(
            materialId: 'clasp',
            name: 'Cierre de pulsera',
            thickness: 0.0,
            lengthPerUnit: 0.0,
            quantity: 1,
          ),
        ],
        cordCuts: [
          CordCut(
            name: 'Cuerdas para pulsera',
            length: 1.5,
            quantity: 4,
            isDoubled: false,
            unknottedLength: 1.7,
          ),
        ],
      ),
    ];
  }

  // Filtrar patrones por múltiples criterios
  static List<PatternDesign> filterPatterns({
    required List<PatternDesign> patterns,
    PatternDifficulty? difficulty,
    String? searchQuery,
    List<String>? tags,
    bool? canBeDoubled,
  }) {
    var filtered = patterns;
    
    if (difficulty != null) {
      filtered = filtered.where((p) => p.difficulty == difficulty).toList();
    }
    
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((p) =>
        p.name.toLowerCase().contains(query) ||
        p.description.toLowerCase().contains(query) ||
        p.tags.any((tag) => tag.toLowerCase().contains(query))
      ).toList();
    }
    
    if (tags != null && tags.isNotEmpty) {
      filtered = filtered.where((p) =>
        p.tags.any((tag) => tags.contains(tag))
      ).toList();
    }
    
    if (canBeDoubled != null) {
      filtered = filtered.where((p) => p.canBeDoubled == canBeDoubled).toList();
    }
    
    return filtered;
  }

  // Ordenar patrones por diferentes criterios
  static List<PatternDesign> sortPatterns({
    required List<PatternDesign> patterns,
    String sortBy = 'name',
    bool ascending = true,
  }) {
    final sorted = List<PatternDesign>.from(patterns);
    
    switch (sortBy) {
      case 'name':
        sorted.sort((a, b) => ascending 
            ? a.name.compareTo(b.name)
            : b.name.compareTo(a.name));
        break;
      case 'difficulty':
        sorted.sort((a, b) => ascending
            ? a.difficulty.index.compareTo(b.difficulty.index)
            : b.difficulty.index.compareTo(a.difficulty.index));
        break;
      case 'hours':
        sorted.sort((a, b) => ascending
            ? a.estimatedHours.compareTo(b.estimatedHours)
            : b.estimatedHours.compareTo(a.estimatedHours));
        break;
      case 'length':
        sorted.sort((a, b) => ascending
            ? a.totalLengthRequired.compareTo(b.totalLengthRequired)
            : b.totalLengthRequired.compareTo(a.totalLengthRequired));
        break;
    }
    
    return sorted;
  }

  // Obtener todos los tags únicos de los patrones
  static List<String> getAllTags(List<PatternDesign> patterns) {
    final allTags = <String>{};
    for (final pattern in patterns) {
      allTags.addAll(pattern.tags);
    }
    return allTags.toList()..sort();
  }

  // Obtener estadísticas de patrones
  static Map<String, dynamic> getPatternStats(List<PatternDesign> patterns) {
    final stats = {
      'total': patterns.length,
      'beginner': patterns.where((p) => p.difficulty == PatternDifficulty.beginner).length,
      'intermediate': patterns.where((p) => p.difficulty == PatternDifficulty.intermediate).length,
      'advanced': patterns.where((p) => p.difficulty == PatternDifficulty.advanced).length,
      'expert': patterns.where((p) => p.difficulty == PatternDifficulty.expert).length,
      'canBeDoubled': patterns.where((p) => p.canBeDoubled).length,
      'avgHours': patterns.isEmpty ? 0 : 
          patterns.map((p) => p.estimatedHours).reduce((a, b) => a + b) / patterns.length,
      'avgLength': patterns.isEmpty ? 0 : 
          patterns.map((p) => p.totalLengthRequired).reduce((a, b) => a + b) / patterns.length,
    };
    
    return stats;
  }
}