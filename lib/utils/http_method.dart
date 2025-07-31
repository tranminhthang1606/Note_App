import 'dart:convert';
import 'package:http/http.dart' as http;


final url = Uri.https(
  'noteapp-b28d7-default-rtdb.asia-southeast1.firebasedatabase.app',
  'noteapp.json',
);

class HttpMethod {

  static Future<http.Response> post(data) async {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    return response; 
  }

  static Future<http.Response> get() async {
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );
    return response; 
  }
}
