import 'package:flutter/material.dart';
import 'grid_model.dart'; // Importa GridCell, KnotType, PlacedKnot

class DesignData {
  final String name;
  final String? description;
  final double cellSize;
  final double cordThickness;
  final int cordColor;
  final List<Map<String, dynamic>> knots;
  final DateTime createdAt;

  DesignData({
    required this.name,
    this.description,
    required this.cellSize,
    required this.cordThickness,
    required this.cordColor,
    required this.knots,
    required this.createdAt,
  });

  // Convertir a Map para JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'cellSize': cellSize,
      'cordThickness': cordThickness,
      'cordColor': cordColor,
      'knots': knots,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Crear DesignData desde la UI
  factory DesignData.fromDesign({
    required String name,
    String? description,
    required double cellSize,
    required double cordThickness,
    required Color cordColor,
    required List<PlacedKnot> placedKnots,
  }) {
    return DesignData(
      name: name,
      description: description,
      cellSize: cellSize,
      cordThickness: cordThickness,
      cordColor: cordColor.value,
      knots: placedKnots.map((knot) {
        return {
          'typeId': knot.type.id,
          'row': knot.cell.row,
          'col': knot.cell.col,
          'isOffsetRow': knot.cell.isOffsetRow,
          'color': knot.type.color.value,
          'placedAt': knot.placedAt.toIso8601String(),
        };
      }).toList(),
      createdAt: DateTime.now(),
    );
  }

  // Convertir de JSON a DesignData (opcional)
  factory DesignData.fromJson(Map<String, dynamic> json) {
    return DesignData(
      name: json['name'],
      description: json['description'],
      cellSize: (json['cellSize'] as num).toDouble(),
      cordThickness: (json['cordThickness'] as num).toDouble(),
      cordColor: json['cordColor'],
      knots: List<Map<String, dynamic>>.from(json['knots']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}