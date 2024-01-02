import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config.dart';
import '../widgets/mood_diary_entry.dart';

class MoodService {
  Future<List<MoodDiaryEntry>> fetchMoods(String token) async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseURL}/moods'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((json) => MoodDiaryEntry.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load moods');
    }
  }
  
  Future<void> saveMood(String token, String content) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseURL}/moods'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: json.encode({'content': content}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save mood');
    }
  }

  // 刪除心情
  Future<void> deleteMood(String token, int moodId) async {
    final response = await http.delete(
      Uri.parse('${AppConfig.baseURL}/moods/$moodId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete mood');
    }
  }
}
