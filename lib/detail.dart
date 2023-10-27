import 'package:flutter/material.dart';
import 'main.dart';


class DetailPage extends StatelessWidget {
  final String title;

  const DetailPage({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title), // 使用所選列表的標題作為頁面標題
      ),
      body: const Center(
        child: Text('內容放在這裡'),
      ),
    );
  }
}
