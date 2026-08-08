import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.1.64:8000/api/v1';  // для эмулятора

  Future<Map<String, dynamic>> generateWorld({
    required Map<String, dynamic> characterTemplate,
    }) 
    async {
    final response = await http.post(
      Uri.parse('$baseUrl/world/create"'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(characterTemplate),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to generate world: ${response.body}');
    }
  }
   
  Future<Map<String, dynamic>> updateCharacter({
    required Map<String, dynamic> characterTemplate,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/skeleton/update'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(characterTemplate),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to generate world: ${response.body}');
    }
  }
  
}
