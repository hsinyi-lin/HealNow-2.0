import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config.dart';

class OpenDataService {
  // 通用的 HTTP 請求方法
  Future<List<Map<String, dynamic>>> _fetchData(String endpoint) async {
    final response = await http.get(Uri.parse('${AppConfig.baseURL}/$endpoint'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          json.decode(const Utf8Decoder().convert(response.bodyBytes));
      final List<dynamic> dataList = data['data'];
      return dataList.map((json) => json as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load data from $endpoint');
    }
  }

  // 使用通用方法來獲取藥品資料
  Future<List<Map<String, dynamic>>> fetchMedications() async {
    return _fetchData('opendatas/1');
  }

  // 使用通用方法來獲取新聞資料
  Future<List<Map<String, dynamic>>> fetchNews() async {
    return _fetchData('opendatas/2');
  }

  Future<List<Map<String, dynamic>>> fetchRumors() async {
    return _fetchData('opendatas/3');
  }

  Future<List<Map<String, dynamic>>> fetchPharmacies() async {
    return _fetchData('opendatas/4');
  }

  // classId 為 openData 資料類型
  Future<List<Map<String, dynamic>>> fetchSavedClassList(String token, int classId) async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseURL}/opendatas/save_class/$classId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((json) => json as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load saved list');
    }
  }
  
  // classId 為 openData 資料類型, openDataId 為該類型裡面的流水號
  Future<void> toggleFavoriteStatus(String token, int classId, int openDataId, bool isFavorite) async {
    final url = Uri.parse('${AppConfig.baseURL}/opendatas/save_class/$classId/$openDataId');

    http.Response response;
    if (isFavorite) {
      response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
    } else {
      response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
    }

    if (response.statusCode != 200) {
      throw Exception('Error updating favorite status');
    }
  }
}
