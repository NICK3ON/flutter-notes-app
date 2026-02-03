import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // 🔹 Send note to server
  static Future<bool> sendNote(Map<String, dynamic> note) async {
    final response = await http.post(
      Uri.parse('$baseUrl/notes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': note['title'],
        'content': note['content'],
      }),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  // 🔹 Fetch notes from server
  static Future<List<dynamic>> fetchNotes() async {
    final response = await http.get(Uri.parse('$baseUrl/notes'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch notes");
    }
  }
}
