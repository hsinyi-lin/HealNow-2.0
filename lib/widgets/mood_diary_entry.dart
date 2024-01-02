import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class MoodDiaryEntry {
  String content;
  DateTime date;
  String aiResponse;
  double positive;
  double neutral;
  double negative;
  String email;
  int id;
  int sentiment;

  MoodDiaryEntry({
    required this.content,
    required this.date,
    required this.aiResponse,
    required this.positive,
    required this.neutral,
    required this.negative,
    required this.email,
    required this.id,
    required this.sentiment,
  });

  factory MoodDiaryEntry.fromJson(Map<String, dynamic> json) {
    final dateFormat = DateFormat('EEE, dd MMM yyyy HH:mm:ss z');
    return MoodDiaryEntry(
      content: json['content'],
      date: dateFormat.parse(json['created_time']),
      aiResponse: json['ai_reply'],
      positive: double.parse(json['positive']),
      neutral: double.parse(json['neutral']),
      negative: double.parse(json['negative']),
      email: json['email'],
      id: json['id'],
      sentiment: json['sentiment'],
    );
  }

  MapEntry<IconData, Color> getMoodIcon() {
    switch (sentiment) {
      case 1:
        return const MapEntry(Icons.sentiment_very_satisfied, Colors.green);
      case 2:
        return const MapEntry(Icons.sentiment_neutral, Colors.amber);
      case 3:
        return const MapEntry(Icons.sentiment_very_dissatisfied, Colors.red);
      default:
        return const MapEntry(Icons.sentiment_neutral, Colors.grey);
    }
  }
}