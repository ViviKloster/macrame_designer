// lib/core/constants.dart
import 'package:flutter/material.dart';

class AppConstants {
  // API URLs
  static const String apiBaseUrl = 'http://localhost:3001';
  static const String apiDesigns = '$apiBaseUrl/api/designs';
  static const String apiPatterns = '$apiBaseUrl/api/patterns';
  
  // App info
  static const String appName = 'Macrame Designer';
  static const String appVersion = '1.0.0';
  
  // Colors
  static const Color primaryColor = Color(0xFF8B4513);
  static const Color secondaryColor = Color(0xFFA0522D);
  static const Color accentColor = Color(0xFFD2691E);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color textColor = Color(0xFF333333);
  static const Color borderColor = Color(0xFFDDDDDD);
  
  // Storage keys
  static const String storageFirstOpen = 'first_open';
  static const String storageUserPreferences = 'user_preferences';
  
  // Default values
  static const double defaultCellSize = 60.0;
  static const double defaultCordThickness = 3.0;
  static const String defaultProjectName = 'Nuevo Diseño';
  
  // Knot type colors
  static final Map<String, Color> knotColors = {
    'square_knot': const Color(0xFF8B4513),
    'half_hitch': const Color(0xFFA0522D),
    'spiral_knot': const Color(0xFFD2691E),
    'berry_knot': const Color(0xFF8B7355),
  };
  
  // Material prices (por metro) - USAR final en lugar de const
  static final Map<double, double> cordPrices = {
    2.0: 0.30, // 2mm: $0.30/m
    3.0: 0.40, // 3mm: $0.40/m
    4.0: 0.50, // 4mm: $0.50/m
    5.0: 0.60, // 5mm: $0.60/m
    6.0: 0.75, // 6mm: $0.75/m
  };
  
  // Método helper para obtener precio
  static double getPriceForThickness(double thickness) {
    return cordPrices[thickness] ?? 0.50; // Default $0.50/m
  }
  
  // Método para calcular costo total
  static double calculateMaterialCost(double thickness, double length) {
    final pricePerMeter = getPriceForThickness(thickness);
    return pricePerMeter * length;
  }
}

// Clase para textos (sin problemas de const)
class Strings {
  static const String save = 'Guardar';
  static const String cancel = 'Cancelar';
  static const String delete = 'Eliminar';
  static const String edit = 'Editar';
  static const String loading = 'Cargando...';
  
  // Mensajes de error
  static const String errorGeneric = 'Ha ocurrido un error';
  static const String errorNoInternet = 'No hay conexión a internet';
  static const String errorLoadData = 'Error al cargar los datos';
  
  // Mensajes de éxito
  static const String successSave = 'Guardado exitosamente';
  static const String successDelete = 'Eliminado exitosamente';
}
class KnotFormulas {
  // Multiplicadores por tipo de nudo
  static const Map<String, double> lengthMultipliers = {
    'square_knot': 8.0,
    'half_hitch': 4.0,
    'spiral_knot': 12.0,
    'berry_knot': 15.0,
  };

  static double getMultiplier(String knotId) {
    return lengthMultipliers[knotId] ?? 5.0; // Default
  }

  // Tiempo estimado por nudo (en minutos)
  static const Map<String, double> timeMultipliers = {
    'square_knot': 5.0,
    'half_hitch': 3.0,
    'spiral_knot': 8.0,
    'berry_knot': 10.0,
  };

  static double getTimeMinutes(String knotId) {
    return timeMultipliers[knotId] ?? 6.0; // Default
  }
}