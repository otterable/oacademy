// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/presentation.dart';

class ApiService {
  final String baseUrl = "http://localhost:5656"; // Updated to localhost:5656

  // Fetch presentations with optional search query
  Future<List<Presentation>> fetchPresentations(String query) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/presentations?q=$query'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Presentation.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load presentations. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching presentations: $e');
    }
  }

  // Upload a presentation
  Future<bool> uploadPresentation(String title, String category, String filePath) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload_presentation'));
      request.fields['title'] = title;
      request.fields['category'] = category;
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      var response = await request.send();
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to upload presentation. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error uploading presentation: $e');
    }
  }

  // Admin login
  Future<bool> adminLogin(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token}),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Admin login failed. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error during admin login: $e');
    }
  }

  // Fetch categories
  Future<List<String>> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/categories'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.cast<String>();
      } else {
        throw Exception('Failed to load categories. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }

  // Create a new category
  Future<void> createCategory(String categoryName) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/categories'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': categoryName}),
      );
      if (response.statusCode != 201) {
        throw Exception('Failed to create category. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating category: $e');
    }
  }

  // Delete a category
  Future<void> deleteCategory(String categoryName) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/categories/$categoryName'),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to delete category. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting category: $e');
    }
  }

  // Assign a presentation to a category
  Future<void> assignPresentation(String presentationId, String categoryName) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/presentations/$presentationId/assign'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'category': categoryName}),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to assign presentation. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error assigning presentation: $e');
    }
  }

  // Unassign a presentation from its category
  Future<void> unassignPresentation(String presentationId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/presentations/$presentationId/unassign'),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to unassign presentation. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error unassigning presentation: $e');
    }
  }
}
