import 'dart:convert';
import 'package:http/http.dart' as http;

class WathqRemoteDatasource {
  final String _baseUrl = 'https://api.wathq.sa/commercial-registration';
  final String _apiKey =
      'ntkE8OZjkSTpSGjVKnAa68sGA7YNFBFt'; // Inserted user-provided API key

  Future<Map<String, dynamic>> fetchCrInfo(String crn) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/info/$crn'),
      headers: {'accept': 'application/json', 'apiKey': _apiKey},
    );
    print(
      'Wathq API response: \nStatus: ${response.statusCode}\nBody: ${response.body}',
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch CR info: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> fetchCrStatus(String crn) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/status/$crn'),
      headers: {'accept': 'application/json', 'apiKey': _apiKey},
    );
    print(
      'Wathq API response: \nStatus: ${response.statusCode}\nBody: ${response.body}',
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch CR status: ${response.body}');
    }
  }
}
