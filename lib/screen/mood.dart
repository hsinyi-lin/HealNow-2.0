import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'dart:convert';

import '../widgets/mood_bar.dart';

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

class MoodPage extends StatefulWidget {
  const MoodPage({super.key});

  @override
  State<MoodPage> createState() => _MoodPageState();
}

class _MoodPageState extends State<MoodPage> {
  Future<List<MoodDiaryEntry>>? futureEntries;

  @override
  void initState() {
    super.initState();
    futureEntries = fetchMedications();
  }

  Future<List<MoodDiaryEntry>> fetchMedications() async {
    final response =
        await http.get(Uri.parse('http://127.0.0.1:5000/moods'), headers: {
      'Authorization':
          'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJmcmVzaCI6ZmFsc2UsImlhdCI6MTcwMjMwMTE5MywianRpIjoiYTIzOTkzZjEtNTNmNy00MWE1LTg5NWQtNmY2ZGU5NWNiNmIyIiwidHlwZSI6ImFjY2VzcyIsInN1YiI6IjExMTM2MDA0QG50dWIuZWR1LnR3IiwibmJmIjoxNzAyMzAxMTkzLCJleHAiOjE3MDc0ODUxOTN9.4C9f_WxW5uV2JqnOUrK1AidGiQ5hzzr3AnXxPQ5ak00',
    });

    if (response.statusCode == 200) {
      final List<dynamic> data =
          json.decode(const Utf8Decoder().convert(response.bodyBytes))['data'];
      return data.map((json) => MoodDiaryEntry.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load medications');
    }
  }

  Future<void> saveContent(
      String content, ScaffoldMessengerState scaffoldMessenger) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/moods'),
      headers: {
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJmcmVzaCI6ZmFsc2UsImlhdCI6MTcwMjMwMTE5MywianRpIjoiYTIzOTkzZjEtNTNmNy00MWE1LTg5NWQtNmY2ZGU5NWNiNmIyIiwidHlwZSI6ImFjY2VzcyIsInN1YiI6IjExMTM2MDA0QG50dWIuZWR1LnR3IiwibmJmIjoxNzAyMzAxMTkzLCJleHAiOjE3MDc0ODUxOTN9.4C9f_WxW5uV2JqnOUrK1AidGiQ5hzzr3AnXxPQ5ak00', // 替换为您的实际令牌
        'Content-Type': 'application/json',
      },
      body: json.encode({'content': content}),
    );
    if (response.statusCode == 200) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text("成功")),
      );

      setState(() {
        futureEntries = fetchMedications();
      });
    } else {
      print("發生錯誤：${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<MoodDiaryEntry>>(
        future: futureEntries,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return  Text('');
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            List<MoodDiaryEntry> entries = snapshot.data!;
            return ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                var entry = entries[index];
                return Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                    child: Slidable(
                      key: ValueKey(index),
                      endActionPane: ActionPane(
                        motion: const DrawerMotion(),
                        dismissible: DismissiblePane(
                          onDismissed: () {
                            deleteMoodBySlide(entry.id);
                          }
                        ),
                        extentRatio: 0.25,
                        children: [
                          SlidableAction(
                            onPressed: (context) {
                              ScaffoldMessengerState scaffoldMessenger =
                                  ScaffoldMessenger.of(context);
                              deleteMood(entry.id, scaffoldMessenger).then((_) {
                                setState(() {});
                              });
                            },
                            backgroundColor:
                                const Color.fromARGB(255, 255, 118, 118),
                            foregroundColor:
                                const Color.fromARGB(255, 255, 255, 255),
                            icon: Icons.delete,
                            label: '刪除',
                            borderRadius: BorderRadius.circular(10),
                            spacing: 4,
                          ),
                        ],
                      ),
                      child: Card(
                        elevation: 10,
                        margin: const EdgeInsets.all(5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        child: InkWell(
                          onTap: () => _showDetailsDialog(entry),
                          child: Material(
                            color: Colors.transparent,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: CircleAvatar(
                                      radius: 30,
                                      backgroundColor: Colors.white,
                                      child: Icon(
                                        entry.getMoodIcon().key,
                                        color: entry.getMoodIcon().value,
                                        size: 40,
                                      ),
                                    ),
                                    title: Text(
                                      entry.content,
                                      style: TextStyle(
                                        color: Colors.indigo[600],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12, 
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: MoodBar(
                                      positive: entry.positive,
                                      neutral: entry.neutral,
                                      negative: entry.negative,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ));
              },
            );
          } else {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min, 
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset('assets/images/thinking.png', width: 200), 
                  const SizedBox(height: 20),
                  const Text('還沒有心情相關資料', style: TextStyle(fontSize: 16)),
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        tooltip: '新增',
        child: Icon(Icons.add),
        backgroundColor: Colors.black87,
      ),
    );
  }

  void _showAddDialog() {
    TextEditingController contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                  '新增心情',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    hintText: "輸入内容",
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black87),
                    ),
                  ),
                  maxLines: 5,
                  minLines: 3,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      child: const Text('取消',
                          style: TextStyle(color: Colors.black45)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      child: const Text('確認',
                          style: TextStyle(color: Colors.black87)),
                      onPressed: () {
                        String content = contentController.text;
                        ScaffoldMessengerState scaffoldMessenger =
                            ScaffoldMessenger.of(context);
                        saveContent(content, scaffoldMessenger).then((_) {
                          Navigator.of(context).pop();

                          setState(() {});
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDetailsDialog(MoodDiaryEntry entry) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.chat_bubble_outline,
                      color: Colors.indigo),
                  title:
                      Text(entry.content, style: const TextStyle(fontSize: 16)),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.reply, color: Colors.amber),
                  title: Text(entry.aiResponse,
                      style: const TextStyle(fontSize: 16)),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.calendar_today, color: Colors.blue),
                  title: Text(
                      DateFormat('yyyy-MM-dd – kk:mm').format(entry.date),
                      style: const TextStyle(fontSize: 16)),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.sentiment_satisfied,
                      color: Colors.green),
                  title: Text("正向占比：${entry.positive.toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 16)),
                ),
                const Divider(),
                ListTile(
                  leading:
                      const Icon(Icons.sentiment_neutral, color: Colors.amber),
                  title: Text("中性占比：${entry.neutral.toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 16)),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.sentiment_dissatisfied,
                      color: Colors.red),
                  title: Text("負向占比：${entry.negative.toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("關閉", style: TextStyle(color: Colors.black87)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteMoodBySlide(int moodId) async {
    await http.delete(
      Uri.parse('http://127.0.0.1:5000/moods/$moodId'),
      headers: {
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1...',
      },
    );

    setState(() {
        futureEntries = fetchMedications();
      });
  }

  Future<void> deleteMood(
      int moodId, ScaffoldMessengerState scaffoldMessenger) async {
    print(moodId);
    final response = await http.delete(
      Uri.parse('http://127.0.0.1:5000/moods/$moodId'),
      headers: {
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1...',
      },
    );
    if (response.statusCode == 200) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text("成功")),
      );

      setState(() {
        futureEntries = fetchMedications();
      });
    } else {
      print("發生錯誤：${response.statusCode}");
    }
  }
}
