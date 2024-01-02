import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class NewPostScreen extends StatefulWidget {
  @override
  _NewPostScreenState createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('新增貼文'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '您的帳號: 振閔',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: '標題',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Color.fromARGB(255, 234, 234, 234),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _contentController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                hintText: '內容 (支援 Markdown)',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Color.fromARGB(255, 234, 234, 234),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 在這裡處理新增貼文的操作
                String title = _titleController.text;
                String content = _contentController.text;

                // 在這裡可以將標題和內容提交給後端或進行其他處理
                // 這裡僅是一個簡單的範例
                print('新增貼文：\n標題：$title\n內容：$content');

                // 關閉新增貼文畫面
                Navigator.pop(context);
              },
              child: Text('發布貼文'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Markdown(
                data: _contentController.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
