// lib/services/api_service.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // for MediaType
import '../models/presentation.dart';

class ApiService {
  final String baseUrl = "http://localhost:5656";

  Future<void> pingBackend() async {
    try {
      await http.get(Uri.parse('$baseUrl/heartbeat'));
    } catch (e) {
      // swallow
    }
  }

  Future<List<Presentation>> fetchPresentations(String query) async {
    final response = await http.get(Uri.parse('$baseUrl/presentations?q=$query'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((item) => Presentation.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load presentations. Status: ${response.statusCode}');
    }
  }

  // Upload from path (mobile/desktop)
  Future<bool> uploadPresentation(String title, String category, String filePath) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload_presentation'));
    request.fields['title'] = title;
    request.fields['category'] = category;
    request.files.add(await http.MultipartFile.fromPath('file', filePath));
    var streamedResponse = await request.send();
    if (streamedResponse.statusCode == 200) {
      await streamedResponse.stream.bytesToString();
      return true;
    } else {
      throw Exception('Upload failed. Status: ${streamedResponse.statusCode}');
    }
  }

  // Upload from bytes (web)
  Future<bool> uploadPresentationWeb({
    required String title,
    required String category,
    required String fileName,
    required Uint8List fileBytes,
  }) async {
    final uri = Uri.parse('$baseUrl/upload_presentation');
    var request = http.MultipartRequest('POST', uri);

    request.fields['title'] = title;
    request.fields['category'] = category;

    // Check extension to pick a contentType
    String ext = fileName.split('.').last.toLowerCase();
    var mimeType = (ext == 'pdf')
        ? MediaType('application', 'pdf')
        : MediaType('application', 'vnd.openxmlformats-officedocument.presentationml.presentation');

    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      fileBytes,
      filename: fileName,
      contentType: mimeType,
    );
    request.files.add(multipartFile);

    var streamedResponse = await request.send();
    if (streamedResponse.statusCode == 200) {
      await streamedResponse.stream.bytesToString();
      return true;
    } else {
      throw Exception('Upload failed (web). Status: ${streamedResponse.statusCode}');
    }
  }

  Future<bool> adminLogin(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': token}),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Admin login failed. Status: ${response.statusCode}');
    }
  }

  Future<List<String>> fetchCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.cast<String>();
    } else {
      throw Exception('Failed to load categories. Status: ${response.statusCode}');
    }
  }

  Future<void> createCategory(String categoryName) async {
    final response = await http.post(
      Uri.parse('$baseUrl/categories'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': categoryName}),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create category. Status: ${response.statusCode}');
    }
  }

  Future<void> deleteCategory(String categoryName) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/categories/$categoryName'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete category. Status: ${response.statusCode}');
    }
  }

  Future<void> assignPresentation(String presentationId, String categoryName) async {
    final response = await http.post(
      Uri.parse('$baseUrl/presentations/$presentationId/assign'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'category': categoryName}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to assign presentation. Status: ${response.statusCode}');
    }
  }

  Future<void> unassignPresentation(String presentationId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/presentations/$presentationId/unassign'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to unassign presentation. Status: ${response.statusCode}');
    }
  }
}
