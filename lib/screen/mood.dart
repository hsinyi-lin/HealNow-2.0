// import 'package:flutter/material.dart'; 
// import 'package:http/http.dart' as http;
// import 'package:test_app/screen/main.dart';
// import 'package:test_app/widgets/app_drawer.dart';
// import 'dart:convert'; 

// import '../data/sqliteHelper.dart'; 

// class MoodPage extends StatefulWidget {
//   const MoodPage({super.key}); // MoodPage StatefulWidget，接受一個可選的key

//   @override
//   State<MoodPage> createState() => _MoodPageState();
// }

// class _MoodPageState extends State<MoodPage> {
//   TextEditingController moodTextController = TextEditingController(); 
//   FocusNode moodTextFocus = FocusNode(); // 一個焦點節點
//   String currentDate = ''; 

//   @override
//   void initState() {
//     super.initState(); // 父類的初始化方法
//     moodTextController.text = ''; 

//     // 初始化資料庫
//     final dbHelper = SQLiteDatabaseHelper();
//     dbHelper.initDb(); // 調用SQLiteDatabaseHelper的初始化資料庫方法

//     // 獲取情緒資料
//     getAllMoodData(); // 調用獲取所有情緒資料的方法
//   }

//   @override
//   void dispose() {
//     moodTextController.dispose(); // 釋放文字編輯器控制器
//     moodTextFocus.dispose(); // 釋放焦點節點
//     super.dispose(); // 調用父類的釋放資源方法
//   }

//   // 獲取情緒資料的非同步方法
//   Future<List<Map<String, dynamic>>?> getAllMoodData() async {
//     final dbHelper = SQLiteDatabaseHelper();
//     final data = await dbHelper.getAllData(); 
//     print(data); 
//     return data; // 返回獲取到的資料
//   }

//   Future<void> addMoodData(String content) async {
//     // 調用ChatGPT模型的API
//     const apiUrl = 'https://api.openai.com/v1/chat/completions';
//     final response = await http.post(
//       Uri.parse(apiUrl),
//       headers: {
//         'Content-Type': 'application/json; charset=UTF-8',
//         'Accept-Charset': 'UTF-8',
//         'Authorization': 'Bearer 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', 
//       },
//       body: json.encode({
//         'model': 'gpt-3.5-turbo',
//         'messages': [
//           {'role': 'system', 'content': '你是一位會用一句話給予鼓勵的心理諮商師'},
//           {'role': 'user', 'content': content}
//         ]
//       }),
//     );

//     // 處理API調用後的資料，並進行正式添加
//     if (response.statusCode == 200) {
//       final result = json.decode(utf8.decode(response.bodyBytes));
//       print(result);
//       String aiReply = result['choices'][0]['message']['content'];

//       print(aiReply); 
//       final dbHelper = SQLiteDatabaseHelper();
//       final data = {
//         'content': content,
//         'ai_reply': aiReply, // 使用OpenAI的回應
//       };
//       await dbHelper.insertData(data);

//       setState(() {
//         moodTextController.text = ''; 
//       });
//     } else {
//       print(
//           'Failed to get AI reply. Status code: ${response.statusCode}');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 252, 252, 244),
//       appBar: AppBar(
//         title: const Text(
//           '記錄心情',
//           style: TextStyle(
//             color: Colors.black,
//             fontWeight: FontWeight.bold, 
//           ), 
//         ),
//         backgroundColor: const Color.fromARGB(255, 232, 239, 139),
//         iconTheme: const IconThemeData(color: Colors.black), 
//       ),
//       drawer: const AppDrawer(), // 使用自訂的AppDrawer
//       body: FutureBuilder<List<Map<String, dynamic>>?>(
//         future: getAllMoodData(), // 非同步方法
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator()); // 顯示載入進度條
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}')); // 顯示錯誤消息
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text('沒有資料')); // 顯示沒有資料
//           } else {
//             final data = snapshot.data!; // 獲取資料
//             return ListView.builder(
//               itemCount: data.length, // 設定item數量
//               itemBuilder: (context, index) {
//                 final item = data[index]; // 獲取當前item的資料
//                 return buildCard(item); // 構建Card，使用於item的資料
//               },
//             );
//           }
//         },
//       ),
      
//       // 新增按鈕
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showMoodInput, // 按下按鈕時顯示心情輸入對話方塊
//         backgroundColor: const Color.fromARGB(255, 186, 195, 89), 
//         child: const Icon(Icons.add,
//             color: Color.fromARGB(255, 255, 255, 255)), 
//       ),
//     );
//   }

//   // Card部件
//   Widget buildCard(Map<String, dynamic> item) {
//     print(item); 
//     return Card(
//       margin: const EdgeInsets.all(10), // 設定卡片的外邊距
//       elevation: 3, // 設置卡片的陰影
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(10.0), 
//       ),
//       child: Column(
//         children: <Widget>[
//           ListTile(
//             title: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(height: 5), 
//                 Text(
//                   item['created_at'],
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Color.fromARGB(255, 66, 66, 66),
//                   ),
//                 ),
//                 const SizedBox(height: 5), 
//                 Text(item['content']),
//               ],
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(
//               vertical: 2,
//               horizontal: 20,
//             ),
//             child: const Divider(
//               color: Color.fromARGB(255, 204, 203, 203), // 分割線顏色
//               thickness: 2, // 分割線的粗細
//             ),
//           ),
//           ListTile(
//             title: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'AI心理師',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Color.fromARGB(255, 66, 66, 66), 
//                   ),
//                 ),
//                 const SizedBox(height: 5),
//                 Text(item['ai_reply']), // 顯示AI回覆內容
//                 const SizedBox(height: 5),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showMoodInput() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10.0), 
//           ),
//           child: FractionallySizedBox(
//             widthFactor: 0.9,
//             child: Container(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: <Widget>[
//                   const Text(
//                     '記錄心情',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   TextField(
//                     controller: moodTextController, // 文字編輯器控制器
//                     decoration: InputDecoration(
//                       hintText: '說說怎麼了吧!',
//                       hintStyle: TextStyle(
//                           color: moodTextFocus.hasFocus
//                               ? Colors.black
//                               : Colors.grey), // 根據焦點狀態設定文字顏色
//                     ),
//                   ),
//                   ElevatedButton(
//                     onPressed: () {
//                       addMoodData(moodTextController.text); 
//                       Navigator.of(context).pop(); // 關閉對話方塊
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor:
//                           const Color.fromARGB(255, 186, 195, 89), // 按鈕背景顏色
//                       textStyle: const TextStyle(
//                         color: Color.fromARGB(255, 66, 66, 66),
//                       ), 
//                     ),
//                     child: const Text('確認'), 
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
