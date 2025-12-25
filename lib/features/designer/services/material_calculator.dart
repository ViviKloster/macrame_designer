import 'package:macrame_designer/features/designer/models/grid_model.dart';
import 'package:macrame_designer/core/constants.dart'; // ← NUEVO IMPORT

class MaterialCalculator {
  // Calcular material total para un diseño
  static CalculationResult calculateMaterial({
    required List<PlacedKnot> placedKnots,
    required double cordThickness, // en mm
    double safetyMargin = 15.0, // porcentaje extra
  }) {
    double totalLength = 0.0; // en cm
    final Map<int, double> lengthByColor = {};
    final Map<String, int> countByType = {};

    for (final placedKnot in placedKnots) {
      final knot = placedKnot.type;
      
      // Longitud por nudo = multiplicador * grosor
      final knotLength = knot.lengthMultiplier * cordThickness;
      totalLength += knotLength;
      
      // Agrupar por color (usar valor del color como int)
      final colorValue = knot.color.value;
      lengthByColor.update(
        colorValue,
        (value) => value + knotLength,
        ifAbsent: () => knotLength,
      );
      
      // Contar por tipo
      countByType.update(
        knot.id,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }

    // Aplicar margen de seguridad
    totalLength *= (1 + safetyMargin / 100);

    // Convertir a metros y rollos estándar
    final totalMeters = totalLength / 100;
    final standardRolls = (totalMeters / 50).ceil(); // Rollos de 50m

    // Estimar tiempo (minutos por nudo)
    final estimatedMinutes = placedKnots.length * 8;
    final estimatedHours = estimatedMinutes / 60;

    // ✅ USANDO AppConstants PARA EL COSTO
    final estimatedCost = AppConstants.calculateMaterialCost(
      cordThickness, 
      totalMeters
    );

    return CalculationResult(
      totalLengthCm: totalLength,
      totalLengthM: totalMeters,
      byColor: lengthByColor,
      byType: countByType,
      standardRollsNeeded: standardRolls,
      estimatedHours: estimatedHours,
      estimatedCost: estimatedCost,
    );
  }

  // Fórmulas específicas por tipo de nudo
  static double getKnotLength(String knotId, double thickness) {
    return KnotFormulas.getMultiplier(knotId) * thickness;
  }

  static double estimateTime(List<PlacedKnot> placedKnots) {
    double totalMinutes = 0;
    for (final placedKnot in placedKnots) {
      totalMinutes += KnotFormulas.getTimeMinutes(placedKnot.type.id);
    }
    return totalMinutes / 60; // En horas
  }
  

  // ✅ NUEVO: Método para calcular solo costo
  static double calculateCostOnly({
    required List<PlacedKnot> placedKnots,
    required double cordThickness,
  }) {
    double totalLength = 0.0;
    
    for (final placedKnot in placedKnots) {
      final knotLength = placedKnot.type.lengthMultiplier * cordThickness;
      totalLength += knotLength;
    }
    
    final totalMeters = totalLength / 100;
    return AppConstants.calculateMaterialCost(cordThickness, totalMeters);
  }
}

class CalculationResult {
  final double totalLengthCm;
  final double totalLengthM;
  final Map<int, double> byColor;
  final Map<String, int> byType;
  final int standardRollsNeeded;
  final double estimatedHours;
  final double estimatedCost;

  CalculationResult({
    required this.totalLengthCm,
    required this.totalLengthM,
    required this.byColor,
    required this.byType,
    required this.standardRollsNeeded,
    required this.estimatedHours,
    required this.estimatedCost,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalLengthCm': totalLengthCm,
      'totalLengthM': totalLengthM,
      'standardRolls': standardRollsNeeded,
      'estimatedHours': estimatedHours.toStringAsFixed(1),
      'estimatedCost': estimatedCost.toStringAsFixed(2),
      'byColor': byColor,
      'byType': byType,
    };
  }

  // ✅ NUEVO: Método para obtener recomendación
  String get recommendation {
    if (totalLengthM < 5) {
      return 'Proyecto pequeño. Compra ${(totalLengthM * 1.2).toStringAsFixed(1)}m para margen.';
    } else if (totalLengthM < 20) {
      return 'Proyecto mediano. Compra ${(totalLengthM * 1.15).toStringAsFixed(1)}m (${(totalLengthM * 0.15).toStringAsFixed(1)}m extra).';
    } else {
      return 'Proyecto grande. Considera comprar ${standardRollsNeeded} rollos de 50m.';
    }
  }
}