import 'package:flutter/material.dart';
import 'main.dart';
import 'package:intl/intl.dart';
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
    final dbHelper = DatabaseHelper();
    dbHelper.initDb();

    // 添加下面的代码来获取并显示数据
    getAllMoodData();
  }

  Future<List<Map<String, dynamic>>?> getAllMoodData() async {
    final dbHelper = DatabaseHelper();
    final data = await dbHelper.getAllData();
    print(data);
    return data;
  }

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
            return const Center(child: CircularProgressIndicator()); // 轉圈
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}')); //錯誤訊息
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('没有資料')); 
          } else {
            final data = snapshot.data!;
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                return buildCard(item);
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showMoodInput,
        child: const Icon(Icons.add),
      ),
    );
  }

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
                Text(
                  item['updated_at'],
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 5),
                Text(item['ai_reply']),
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
                const Text('ChatGPT回覆',style:TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(item['ai_reply']),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
                  const Text('今日心情'),
                  TextField(
                    controller: moodTextController,
                    decoration: InputDecoration(
                      hintText: '輸入心情日記',
                      hintStyle: TextStyle(
                          color: moodTextFocus.hasFocus
                              ? Colors.black
                              : Colors.grey),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      print(moodTextController.text);

                      final now = DateTime.now();
                      final formattedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

                      // 新增資料
                      final dbHelper = DatabaseHelper();
                      
                      final data = {
                        'content': moodTextController.text,
                        'mood_id': 0,
                        'ai_reply': '......',
                        'created_at': formattedDateTime,
                        'updated_at': formattedDateTime,
                      };
                      dbHelper.insertData(data);
                      hasMoodEntered = true;
                      moodTextController.text = ''; // 清空TextField
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
