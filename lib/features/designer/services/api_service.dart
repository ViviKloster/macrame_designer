import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:3001';
  
  // Guardar diseño en MySQL via API
  static Future<Map<String, dynamic>> saveDesign(Map<String, dynamic> designData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/designs'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(designData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al guardar: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener todos los diseños
  static Future<List<Map<String, dynamic>>> getDesigns() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/designs'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error al cargar: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Cargar un diseño específico
  static Future<Map<String, dynamic>> loadDesign(String designId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/designs/$designId'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al cargar diseño: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}