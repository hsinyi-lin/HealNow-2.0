// NewPostScreen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/token.dart';

class NewPostScreen extends StatefulWidget {
  final VoidCallback refreshCallback; // 添加 refreshCallback

  NewPostScreen({Key? key, required this.refreshCallback}) : super(key: key);

  @override
  _NewPostScreenState createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();

  String? token; // 使用 nullable 類型，代表 token 可能為 null
  Map<String, dynamic>? userData; // 存儲使用者資料

  @override
  void initState() {
    super.initState();
    loadToken().then((loadedToken) async {
      // 當 token 載入完成時，設定 token 並取得使用者資料
      setState(() {
        token = loadedToken;
      });

      try {
        // 顯示載入指示器
        showLoadingIndicator();
        final data = await fetchUserData(token);
        // 隱藏載入指示器
        hideLoadingIndicator();
        setState(() {
          userData = data;
        });
      } catch (error) {
        print('Error fetching user data: $error');
        // 隱藏載入指示器
        hideLoadingIndicator();
      }
    });
  }

  void showLoadingIndicator() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  void hideLoadingIndicator() {
    Navigator.of(context).pop();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 在這裡處理其他相依性變更
    // 如果需要在此處取得更多資料，可以在這裡執行非同步任務
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('新增貼文'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.black, Colors.white], // 自行調整顏色
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // changes the direction of the shadow
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顯示使用者名稱
            if (userData != null)
              Text(
                '您的帳號: ${userData!['username'] ?? ''}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 16),
            // 輸入標題的 TextField
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: '標題',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0), // 圓角
                  borderSide: BorderSide(color: Colors.grey), // 設定邊框顏色
                ),
                filled: true,
                fillColor: Colors.grey[200], // 使用預定義的灰色調
                prefixIcon: Icon(Icons.title), // 添加標題圖示
                contentPadding: EdgeInsets.all(15.0), // 調整內容框框大小
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.black), // 設定有焦點時的邊框顏色
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),

            SizedBox(height: 10),

            // 輸入內文的 TextField
            TextField(
              controller: _contentController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                hintText: '內容',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.grey[200],
                prefixIcon: Icon(Icons.text_fields),
                contentPadding: EdgeInsets.symmetric(vertical: 100.0, horizontal: 15.0), // 調整內容框框大小
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 20),
            // 發布貼文的按鈕
            ElevatedButton(
              onPressed: () async {
                // 在這裡處理新增貼文的操作
                String title = _titleController.text;
                String content = _contentController.text;

                // 在這裡可以將標題和內容提交給後端或進行其他處理
                // 這裡僅是一個簡單的範例
                addNewPost(title, content);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // 更改按鈕顏色
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Text(
                '發布貼文',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // 新增貼文的 API 請求
  Future<void> addNewPost(String title, String content) async {
    try {
      final response = await http.post(
        Uri.parse('https://healnow.azurewebsites.net/posts'), // 請更改為正確的 API 網址
        headers: {
          'Authorization': 'Bearer $token', // 請將 your_token_here 替換為實際的 token
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'title': title,
          'content': content,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        Navigator.pop(context);
        widget.refreshCallback(); // 刷新 SocialPage 的貼文列表
      } else {
        throw Exception(
            'Failed to add post. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error adding post: $error');
      throw Exception('Failed to add post');
    }
  }

  // 取得使用者資料的 API 請求
  Future<Map<String, dynamic>> fetchUserData(String? token) async {
    try {
      final response = await http.get(
        Uri.parse('https://healnow.azurewebsites.net/user'), // 請更改為正確的 API 網址
        headers: {
          'Authorization': 'Bearer $token', // 請將 your_token_here 替換為實際的 token
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['data'];
      } else {
        throw Exception(
            'Failed to fetch user data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching user data: $error');
      throw Exception('Failed to fetch user data');
    }
  }
}
