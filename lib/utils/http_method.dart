import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:note_app_flutter/models/category.dart';

final _baseUrl = 'noteapp-b28d7-default-rtdb.asia-southeast1.firebasedatabase.app';

class HttpMethod {
  static Future<http.Response> post(data) async {
    final url = Uri.https(_baseUrl, 'noteapp.json');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    return response;
  }

  static Future<http.Response> get() async {
    final url = Uri.https(_baseUrl, 'noteapp.json');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );
    return response;
  }

  static Future<http.Response> patch(String id, Map<String, dynamic> data) async {
    final url = Uri.https(_baseUrl, 'noteapp/$id.json');
    final response = await http.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    return response;
  }

  static Future<http.Response> delete(String id) async {
    final url = Uri.https(_baseUrl, 'noteapp/$id.json');
    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json'},
    );
    return response;
  }
  
  
  static Future<List<Category>> getCategories() async {
    final url = Uri.https(_baseUrl, 'categories.json');
    final response = await http.get(url);
    final List<Category> loadedCategories = [];
    if (response.body != 'null') {
      final Map<String, dynamic> listData = json.decode(response.body);
      listData.forEach((key, value) {
        loadedCategories.add(
          Category(id: key, name: value['name']),
        );
      });
    }
    return loadedCategories;
  }

  static Future<http.Response> createCategory(String name) async {
    final url = Uri.https(_baseUrl, 'categories.json');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': name}),
    );
    return response;
  }

  
}