import 'package:flutter/material.dart';
import 'main.dart';
class DetailPage extends StatelessWidget {
  final String title;

  DetailPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title), // 使用所選列表的標題作為頁面標題
      ),
      body: Center(
        child: Text('內容放在這裡'),
      ),
    );
  }
}
