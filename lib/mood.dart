import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'main.dart';
import 'data/sqliteHelper.dart';

class MoodPage extends StatefulWidget {
  const MoodPage({super.key});

  @override
  State<MoodPage> createState() => _MoodPageState();
}

class _MoodPageState extends State<MoodPage> {
  TextEditingController moodTextController = TextEditingController();
  FocusNode moodTextFocus = FocusNode();
  String currentDate = '';
  bool hasMoodEntered = false;

  @override
  void initState() {
    super.initState();
    moodTextController.text = '';

    // 初始化資料庫
    final dbHelper = SQLiteDatabaseHelper();
    dbHelper.initDb();

    // 取得情緒資料
    getAllMoodData();
  }

  // 取得情緒資料函式
  Future<List<Map<String, dynamic>>?> getAllMoodData() async {
    final dbHelper = SQLiteDatabaseHelper();
    final data = await dbHelper.getAllData();
    print(data);
    return data;
  }

  // 新增情緒資料函式
  Future<void> addMoodData(String content) async {
    final now = DateTime.now();
    final formattedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    // 呼叫ChatGPT模型
    const apiUrl = 'https://api.openai.com/v1/chat/completions';
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer openai_key',
      },
      body: json.encode({
        "model": "gpt-3.5-turbo",
        "messages": [
          {"role": "system", "content": "你是一位會用一句話給予鼓勵的心理諮商師"},
          {"role": "user", "content": content}
        ]
      }),
    );

    // 處理呼叫後資料，並且正式新增
    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      print(result);
      String aiReply = result['choices'][0]['message']['content'];

      print(aiReply);
      final dbHelper = SQLiteDatabaseHelper();
      final data = {
        'content': content,
        'mood_id': 0,
        'ai_reply': aiReply, // 使用 OpenAI 的回應
        'created_at': formattedDateTime,
        'updated_at': formattedDateTime,
      };
      await dbHelper.insertData(data);

      setState(() {
        hasMoodEntered = true;
        moodTextController.text = '';
      });
    } else {
      print('Failed to get AI reply. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("記錄心情"),
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder<List<Map<String, dynamic>>?>(
        future: getAllMoodData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // 讀取
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}')); //用於錯誤訊息
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('没有資料'));
          } else {
            final data = snapshot.data!;
            return ListView.builder(
              itemCount: data.length, // item筆數
              itemBuilder: (context, index) {
                final item = data[index];
                return buildCard(item); // 建立Card以存放各item
              },
            );
          }
        },
      ),
      // 用於新增按鈕
      floatingActionButton: FloatingActionButton(
        onPressed: _showMoodInput,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Card函式
  Widget buildCard(Map<String, dynamic> item) {
    print(item);
    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 3,
      child: Column(
        children: <Widget>[
          ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['updated_at'],
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(item['content']),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 2,
              horizontal: 20,
            ),
            child: const Divider(
              color: Color.fromARGB(255, 204, 203, 203),
              thickness: 2,
            ),
          ),
          ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('AI心理師',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(item['ai_reply']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 按下新增按鈕顯示的Dialog
  void _showMoodInput() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: FractionallySizedBox(
            widthFactor: 0.9,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text('紀錄心情'),
                  TextField(
                    controller: moodTextController,
                    decoration: InputDecoration(
                      hintText: '說說怎麼了吧!',
                      hintStyle: TextStyle(
                          color: moodTextFocus.hasFocus
                              ? Colors.black
                              : Colors.grey),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      addMoodData(moodTextController.text);
                    },
                    child: const Text('確認'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    moodTextController.dispose();
    moodTextFocus.dispose();
    super.dispose();
  }
}
