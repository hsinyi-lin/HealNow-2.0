import 'package:flutter/material.dart'; // 導入Flutter的Material庫
import 'package:http/http.dart' as http; // 導入HTTP庫並重命名為http
import 'dart:convert'; // 導入dart的JSON編解碼庫

import 'main.dart'; // 導入main.dart文件
import 'data/sqliteHelper.dart'; // 導入sqliteHelper.dart文件

class MoodPage extends StatefulWidget {
  const MoodPage({super.key}); // 創建MoodPage StatefulWidget，接受一個可選的key

  @override
  State<MoodPage> createState() => _MoodPageState(); // 創建MoodPage的狀態管理類實例
}

class _MoodPageState extends State<MoodPage> {
  TextEditingController moodTextController =
      TextEditingController(); // 創建一個文字編輯器控制器
  FocusNode moodTextFocus = FocusNode(); // 創建一個焦點節點
  String currentDate = ''; // 保存當前日期的字串

  @override
  void initState() {
    super.initState(); // 調用父類的初始化方法
    moodTextController.text = ''; // 將文字編輯器控制器的文本內容初始化為空字串

    // 初始化資料庫
    final dbHelper = SQLiteDatabaseHelper();
    dbHelper.initDb(); // 調用SQLiteDatabaseHelper類的初始化資料庫方法

    // 獲取情緒資料
    getAllMoodData(); // 調用獲取所有情緒資料的方法
  }

  @override
  void dispose() {
    moodTextController.dispose(); // 釋放文字編輯器控制器
    moodTextFocus.dispose(); // 釋放焦點節點
    super.dispose(); // 調用父類的釋放資源方法
  }

  // 獲取情緒資料的非同步方法
  Future<List<Map<String, dynamic>>?> getAllMoodData() async {
    final dbHelper = SQLiteDatabaseHelper();
    final data =
        await dbHelper.getAllData(); // 調用SQLiteDatabaseHelper類的獲取所有資料方法
    print(data); // 列印資料到控制台
    return data; // 返回獲取到的資料
  }

  // 添加情緒資料的非同步方法
  Future<void> addMoodData(String content) async {
    // 調用ChatGPT模型的API
    const apiUrl = 'https://api.openai.com/v1/chat/completions';
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept-Charset': 'UTF-8',
        'Authorization': 'Bearer ', // 傳入授權頭資訊（需要填寫正確的Bearer權杖）
      },
      body: json.encode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'system', 'content': '你是一位會用一句話給予鼓勵的心理諮商師'},
          {'role': 'user', 'content': content}
        ]
      }),
    );

    // 處理API調用後的資料，並進行正式添加
    if (response.statusCode == 200) {
      final result = json.decode(utf8.decode(response.bodyBytes)); // 解碼JSON回應
      print(result); // 列印回應資料到控制台
      String aiReply =
          result['choices'][0]['message']['content']; // 從API回應中提取AI的回復

      print(aiReply); // 列印AI的回復到控制台
      final dbHelper = SQLiteDatabaseHelper();
      final data = {
        'content': content,
        'ai_reply': aiReply, // 使用OpenAI的回應
      };
      await dbHelper.insertData(data); // 調用SQLiteDatabaseHelper類的插入資料方法

      setState(() {
        moodTextController.text = ''; // 清空文字編輯器的文本內容
      });
    } else {
      print(
          'Failed to get AI reply. Status code: ${response.statusCode}'); // 列印API調用失敗的消息
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 252, 252, 244), // 設置背景顏色
      appBar: AppBar(
        title: const Text(
          '記錄心情',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold, // 設置字體加粗
          ), // 設置字體顏色為黑色
        ),
        backgroundColor: const Color.fromARGB(255, 232, 239, 139), // 設置應用欄背景顏色
        iconTheme: const IconThemeData(color: Colors.black), // 設置圖示顏色為黑色
      ),
      drawer: const AppDrawer(), // 使用自訂的AppDrawer抽屜部件
      body: FutureBuilder<List<Map<String, dynamic>>?>(
        future: getAllMoodData(), // 設置未來的資料來源為獲取情緒資料的非同步方法
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // 顯示載入進度條
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}')); // 顯示錯誤消息
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('沒有資料')); // 顯示沒有資料的消息
          } else {
            final data = snapshot.data!; // 獲取資料
            return ListView.builder(
              itemCount: data.length, // 設置列表項數量
              itemBuilder: (context, index) {
                final item = data[index]; // 獲取當前項的資料
                return buildCard(item); // 構建Card來存儲每個項的資料
              },
            );
          }
        },
      ),
      // 用於添加按鈕
      floatingActionButton: FloatingActionButton(
        onPressed: _showMoodInput, // 按下按鈕時顯示心情輸入對話方塊
        backgroundColor: const Color.fromARGB(255, 186, 195, 89), // 設置按鈕的背景顏色
        child: const Icon(Icons.add,
            color: Color.fromARGB(255, 255, 255, 255)), // 設置按鈕上的圖示
      ),
    );
  }

  // Card部件
  Widget buildCard(Map<String, dynamic> item) {
    print(item); // 列印項的資料到控制台
    return Card(
      margin: const EdgeInsets.all(10), // 設置卡片的外邊距
      elevation: 3, // 設置卡片的陰影
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // 設置卡片的邊角圓角
      ),
      child: Column(
        children: <Widget>[
          ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5), // 增加頂部間距
                Text(
                  item['created_at'], // 顯示項的創建日期
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 66, 66, 66), // 設置文本顏色
                  ),
                ),
                const SizedBox(height: 5), // 增加間距
                Text(item['content']), // 顯示項的內容
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 2,
              horizontal: 20,
            ),
            child: const Divider(
              color: Color.fromARGB(255, 204, 203, 203), // 設置分割線顏色
              thickness: 2, // 設置分割線的粗細
            ),
          ),
          ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI心理師',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 66, 66, 66), // 設置文本顏色
                  ),
                ),
                const SizedBox(height: 5), // 增加間距
                Text(item['ai_reply']), // 顯示項的AI回復內容
                const SizedBox(height: 5), // 增加底部間距
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 點擊添加按鈕後顯示的對話方塊
  void _showMoodInput() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0), // 設置對話方塊的邊角圓角
          ),
          child: FractionallySizedBox(
            widthFactor: 0.9,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                    '記錄心情',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextField(
                    controller: moodTextController, // 設置文字編輯器控制器
                    decoration: InputDecoration(
                      hintText: '說說怎麼了吧!', // 設置輸入框的提示文本
                      hintStyle: TextStyle(
                          color: moodTextFocus.hasFocus
                              ? Colors.black
                              : Colors.grey), // 根據焦點狀態設置提示文本顏色
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // 關閉對話方塊
                      addMoodData(moodTextController.text); // 調用添加情緒資料的方法
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color.fromARGB(255, 186, 195, 89), // 設置按鈕背景顏色
                      textStyle: const TextStyle(
                        color: Color.fromARGB(255, 66, 66, 66),
                      ), // 設置按鈕文本顏色
                    ),
                    child: const Text('確認'), // 設置按鈕文本
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
