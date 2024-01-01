import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';

import '../widgets/mood_bar.dart';
import '../widgets/mood_diary_entry.dart';

class MoodPage extends StatefulWidget {
  const MoodPage({super.key});

  @override
  State<MoodPage> createState() => _MoodPageState();
}

class _MoodPageState extends State<MoodPage> {
  Future<List<MoodDiaryEntry>>? futureEntries;
  Set<int> selectedMoods = {}; // 用於儲存選中的心情類型

  late String token;

  @override
  void initState() {
    super.initState();
    loadToken().then((loadedToken) {
      token = loadedToken;
      futureEntries = fetchMoods();
    });
  }

  Future<String> loadToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  // 選擇某心情的方法
  void toggleSelectedMood(int moodType) {
    setState(() {
      if (selectedMoods.contains(moodType)) {
        selectedMoods.remove(moodType);
      } else {
        selectedMoods.add(moodType);
      }
    });
  }

  // 用於回傳某心情資料
  List<MoodDiaryEntry> filterEntries(List<MoodDiaryEntry> entries) {
    if (selectedMoods.isEmpty) {
      return entries;
    }
    return entries
        .where((entry) => selectedMoods.contains(entry.sentiment))
        .toList();
  }

  // 取得心情資料API
  Future<List<MoodDiaryEntry>> fetchMoods() async {
    final response = await http.get(
        Uri.parse('https://healnow.azurewebsites.net/moods'),
        headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      final List<dynamic> data =
          json.decode(const Utf8Decoder().convert(response.bodyBytes))['data'];
      return data.map((json) => MoodDiaryEntry.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load moods');
    }
  }

  // 新增心情日記方法
  Future<void> saveContent(
      String content, ScaffoldMessengerState scaffoldMessenger) async {
    final response = await http.post(
      Uri.parse('https://healnow.azurewebsites.net/moods'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: json.encode({'content': content}),
    );

    if (response.statusCode == 200) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text("成功")),
      );

      setState(() {
        futureEntries = fetchMoods();
      });
    } else {
      print("發生錯誤：${response.statusCode}");
    }
  }

  //刪除Mood
  Future<void> deleteMood(int moodId) async {
    await http.delete(
      Uri.parse('https://healnow.azurewebsites.net/moods/$moodId'),
      headers: {
        'Authorization': 'Bearer $token'
      },
    );

    setState(() {
      futureEntries = fetchMoods();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          '心情',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(children: [
          // 心情篩選標籤
          Row(
            mainAxisAlignment: MainAxisAlignment.start, //靠左排列
            children: [
              const SizedBox(width: 16),
              FilterChip(
                label: const Text('正向'),
                selected: selectedMoods.contains(1),
                onSelected: (bool selected) {
                  toggleSelectedMood(1);
                },
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('中立'),
                selected: selectedMoods.contains(2),
                onSelected: (bool selected) {
                  toggleSelectedMood(2);
                },
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('負向'),
                selected: selectedMoods.contains(3),
                onSelected: (bool selected) {
                  toggleSelectedMood(3);
                },
              ),
            ],
          ),
          const SizedBox(width: 10),
          const Divider(),
          // 心情資料
          Expanded(
            child: FutureBuilder<List<MoodDiaryEntry>>(
              future: futureEntries,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  List<MoodDiaryEntry> entries = filterEntries(snapshot.data!);
                  return ListView.builder(
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      var entry = entries[index];
                      return Padding(
                          padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
                          // 滑動刪除
                          child: Slidable(
                            key: ValueKey(index),
                            endActionPane: ActionPane(
                              motion: const DrawerMotion(),
                              dismissible: DismissiblePane(onDismissed: () {
                                deleteMood(entry.id);
                              }),
                              extentRatio: 0.25,
                              children: [
                                SlidableAction(
                                  onPressed: (context) {
                                    deleteMood(entry.id);
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
                            // Card內容
                            child: Card(
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 7, horizontal: 15),
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
                                          contentPadding:
                                              const EdgeInsets.all(12),
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
                                          subtitle: Text(
                                            DateFormat('yyyy-MM-dd')
                                                .format(entry.date),
                                            style: const TextStyle(
                                              color: Color.fromARGB(
                                                  255, 124, 124, 124),
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
          )
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        tooltip: '新增',
        child: Icon(Icons.add),
        backgroundColor: Colors.black87,
      ),
    );
  }

  // 新增心情的dialog
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

  //顯示心情細項
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
}
