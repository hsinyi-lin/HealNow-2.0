import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config.dart';

class OpenDataService {
  Future<List<Map<String, dynamic>>> fetchMedications() async {
    final response = await http.get(Uri.parse(
      '${AppConfig.baseURL}/opendatas/1',
    ));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          json.decode(const Utf8Decoder().convert(response.bodyBytes));
      final List<dynamic> medList = data['data'];
      return medList.map((json) => json as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load medications');
    }
  }

  Future<List<Map<String, dynamic>>> fetchNews() async {
    final response = await http.get(Uri.parse(
      '${AppConfig.baseURL}/opendatas/2',
    ));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          json.decode(const Utf8Decoder().convert(response.bodyBytes));
      final List<dynamic> newsList = data['data'];
      return newsList.map((json) => json as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load news');
    }
  }
}