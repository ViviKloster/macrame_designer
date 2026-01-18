// lib/src/features/patterns/models/pattern_model.dart
import 'package:flutter/material.dart';

class PatternDesign {
  final String id;
  final String name;
  final String author;
  final String description;
  final String imageUrl;
  final String youtubeTutorialUrl;
  final String storeUrl;
  final List<MaterialRequirement> materials;
  final PatternDifficulty difficulty;
  final double estimatedHours;
  final List<String> tags;
  final List<CordCut> cordCuts;
  final bool canBeDoubled;
  final double? doubledSizeMultiplier;

  PatternDesign({
    required this.id,
    required this.name,
    required this.author,
    required this.description,
    required this.imageUrl,
    required this.youtubeTutorialUrl,
    required this.storeUrl,
    required this.materials,
    required this.difficulty,
    required this.estimatedHours,
    required this.tags,
    required this.cordCuts,
    this.canBeDoubled = false,
    this.doubledSizeMultiplier = 2.0,
  });

  double get totalLengthRequired {
    return materials.fold(0.0, (sum, material) => sum + material.totalLength);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'author': author,
      'description': description,
      'imageUrl': imageUrl,
      'youtubeTutorialUrl': youtubeTutorialUrl,
      'storeUrl': storeUrl,
      'materials': materials.map((m) => m.toJson()).toList(),
      'difficulty': difficulty.index,
      'estimatedHours': estimatedHours,
      'tags': tags,
      'cordCuts': cordCuts.map((c) => c.toJson()).toList(),
      'canBeDoubled': canBeDoubled,
      'doubledSizeMultiplier': doubledSizeMultiplier,
    };
  }

  factory PatternDesign.fromJson(Map<String, dynamic> json) {
    return PatternDesign(
      id: json['id'],
      name: json['name'],
      author: json['author'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      youtubeTutorialUrl: json['youtubeTutorialUrl'],
      storeUrl: json['storeUrl'],
      materials: (json['materials'] as List)
          .map((m) => MaterialRequirement.fromJson(m))
          .toList(),
      difficulty: PatternDifficulty.values[json['difficulty']],
      estimatedHours: json['estimatedHours'],
      tags: List<String>.from(json['tags']),
      cordCuts: (json['cordCuts'] as List)
          .map((c) => CordCut.fromJson(c))
          .toList(),
      canBeDoubled: json['canBeDoubled'] ?? false,
      doubledSizeMultiplier: json['doubledSizeMultiplier'] ?? 2.0,
    );
  }
}

class MaterialRequirement {
  final String materialId;
  final String name;
  final double thickness; // en mm
  final double lengthPerUnit; // metros por unidad
  final int quantity;
  final double? knottedReduction; // reducción por anudado (0-1)

  MaterialRequirement({
    required this.materialId,
    required this.name,
    required this.thickness,
    required this.lengthPerUnit,
    required this.quantity,
    this.knottedReduction = 0.3, // 30% de reducción por anudado
  });

  double get totalLength => lengthPerUnit * quantity;
  
  double get knottedLength => totalLength * (1 - (knottedReduction ?? 0));

  Map<String, dynamic> toJson() {
    return {
      'materialId': materialId,
      'name': name,
      'thickness': thickness,
      'lengthPerUnit': lengthPerUnit,
      'quantity': quantity,
      'knottedReduction': knottedReduction,
    };
  }

  factory MaterialRequirement.fromJson(Map<String, dynamic> json) {
    return MaterialRequirement(
      materialId: json['materialId'],
      name: json['name'],
      thickness: json['thickness'],
      lengthPerUnit: json['lengthPerUnit'],
      quantity: json['quantity'],
      knottedReduction: json['knottedReduction'],
    );
  }
}

class CordCut {
  final String name;
  final double length; // metros
  final int quantity;
  final bool isDoubled; // si se usa doblado
  final double? unknottedLength; // largo sin anudar

  CordCut({
    required this.name,
    required this.length,
    required this.quantity,
    this.isDoubled = false,
    this.unknottedLength,
  });

  double get totalLength => length * quantity * (isDoubled ? 2 : 1);
  
  double get recommendedCutLength {
    return unknottedLength ?? (length * (isDoubled ? 2.2 : 1.1)); // +10-20% de margen
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'length': length,
      'quantity': quantity,
      'isDoubled': isDoubled,
      'unknottedLength': unknottedLength,
    };
  }

  factory CordCut.fromJson(Map<String, dynamic> json) {
    return CordCut(
      name: json['name'],
      length: json['length'],
      quantity: json['quantity'],
      isDoubled: json['isDoubled'] ?? false,
      unknottedLength: json['unknottedLength'],
    );
  }
}

enum PatternDifficulty {
  beginner,
  intermediate,
  advanced,
  expert,
}

// Métodos de ayuda para trabajar con dificultades
extension PatternDifficultyExtension on PatternDifficulty {
  String get displayName {
    switch (this) {
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

  Color get color {
    switch (this) {
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

  IconData get icon {
    switch (this) {
      case PatternDifficulty.beginner:
        return Icons.school;
      case PatternDifficulty.intermediate:
        return Icons.trending_up;
      case PatternDifficulty.advanced:
        return Icons.star;
      case PatternDifficulty.expert:
        return Icons.emoji_events;
    }
  }
}

// Clase para calcular materiales basados en un PatternDesign
class PatternMaterialCalculator {
  static PatternMaterialResult calculateForPattern(
    PatternDesign pattern, {
    bool useDoubled = false,
    double safetyMarginPercent = 15.0,
  }) {
    double totalLength = pattern.totalLengthRequired;
    
    if (useDoubled && pattern.canBeDoubled) {
      totalLength *= pattern.doubledSizeMultiplier!;
    }
    
    // Calcular con margen de seguridad
    final lengthWithMargin = totalLength * (1 + safetyMarginPercent / 100);
    
    // Calcular rollos estándar (50m)
    final standardRollsNeeded = (lengthWithMargin / 50).ceil();
    
    // Calcular cortes necesarios
    final List<CordCutResult> cutResults = pattern.cordCuts.map((cut) {
      final effectiveLength = useDoubled && pattern.canBeDoubled
          ? cut.length * pattern.doubledSizeMultiplier!
          : cut.length;
          
      final effectiveQuantity = useDoubled && pattern.canBeDoubled
          ? cut.quantity * 2
          : cut.quantity;
      
      return CordCutResult(
        name: cut.name,
        originalCut: cut,
        actualLength: effectiveLength,
        actualQuantity: effectiveQuantity,
        totalLengthNeeded: effectiveLength * effectiveQuantity,
        recommendedCutLength: cut.recommendedCutLength,
      );
    }).toList();
    
    return PatternMaterialResult(
      pattern: pattern,
      useDoubled: useDoubled,
      totalLength: totalLength,
      lengthWithMargin: lengthWithMargin,
      standardRollsNeeded: standardRollsNeeded,
      cutResults: cutResults,
      estimatedCost: _estimateCost(totalLength, pattern.materials),
    );
  }
  
  static double _estimateCost(double length, List<MaterialRequirement> materials) {
    // Precio estimado por metro (ajusta según tus materiales)
    const pricePerMeter = 0.5; // $0.50 por metro
    return length * pricePerMeter;
  }
}

class PatternMaterialResult {
  final PatternDesign pattern;
  final bool useDoubled;
  final double totalLength;
  final double lengthWithMargin;
  final int standardRollsNeeded;
  final List<CordCutResult> cutResults;
  final double estimatedCost;
  
  PatternMaterialResult({
    required this.pattern,
    required this.useDoubled,
    required this.totalLength,
    required this.lengthWithMargin,
    required this.standardRollsNeeded,
    required this.cutResults,
    required this.estimatedCost,
  });
}

class CordCutResult {
  final String name;
  final CordCut originalCut;
  final double actualLength;
  final int actualQuantity;
  final double totalLengthNeeded;
  final double recommendedCutLength;
  
  CordCutResult({
    required this.name,
    required this.originalCut,
    required this.actualLength,
    required this.actualQuantity,
    required this.totalLengthNeeded,
    required this.recommendedCutLength,
  });
}

// Clase de servicio para cargar patrones desde diferentes fuentes
class PatternDataService {
  // Método para cargar patrones prediseñados (ejemplos)
  static List<PatternDesign> getSamplePatterns() {
    return [
      PatternDesign(
        id: '1',
        name: 'Tapiz triangular básico',
        author: '',
        description: 'Perfecto para principiantes. Diseño minimalista con nudos cuadrados y medios nudos.',
        imageUrl: 'https://example.com/images/triangular_basic.jpg',
        youtubeTutorialUrl: 'https://www.youtube.com/watch?v=ejemplo1',
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
        author: '',
        description: 'Portamacetas con diseño de nudos espirales y bayas. Ideal para interiores.',
        imageUrl: 'https://example.com/images/hanging_plant_hanger.jpg',
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
        author: '',
        description: 'Cortina decorativa con patrones complejos de nudos cuadrados y espirales.',
        imageUrl: 'https://example.com/images/macrame_curtain.jpg',
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
        author: '',
        description: 'Marco decorativo para espejos con diseño circular y nudos de baya.',
        imageUrl: 'https://example.com/images/mirror_frame.jpg',
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
        author: '',
        description: 'Pulsera simple con nudos cuadrados. Perfecta para principiantes y regalos.',
        imageUrl: 'https://example.com/images/basic_bracelet.jpg',
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
  
  // Método para cargar desde una API (deberías implementar según tu backend)
  static Future<List<PatternDesign>> loadFromApi(String apiUrl) async {
    // Implementar llamada HTTP a tu API
    // Por ahora devolvemos los ejemplos
    return getSamplePatterns();
  }
  
  // Método para filtrar patrones
  static List<PatternDesign> filterPatterns({
    required List<PatternDesign> patterns,
    PatternDifficulty? difficulty,
    String? searchQuery,
    List<String>? tags,
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
    
    return filtered;
  }
}