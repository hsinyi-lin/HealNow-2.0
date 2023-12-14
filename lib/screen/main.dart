import 'package:flutter/material.dart';
import 'home.dart'; // 導入主頁
import 'map.dart'; // 導入地圖頁面
import 'mood.dart'; // 導入心情頁面
import 'news.dart'; // 導入新聞頁面
import 'rumor.dart'; // 導入健康謠言頁面

void main() {
  runApp(
    const MaterialApp(
      home: MyApp(), // 將主頁視圖設置為應用的初始頁面
      debugShowCheckedModeBanner: false, // 隱藏調試標誌
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'HealNow', // 設置應用欄標題
          style: TextStyle(
            color: Colors.black, // 設置字體顏色為黑色
          ),
        ),
        backgroundColor: const Color.fromARGB(204, 12, 248, 228), // 設置應用欄背景顏色
        iconTheme: const IconThemeData(color: Colors.black), // 設置功能表圖示顏色為黑色
      ),
      body: const Myhome(), // 將首頁視圖添加到主頁面
      drawer: const AppDrawer(), // 使用全域抽屜
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void navigateToPage(BuildContext context, Widget page) {
    Navigator.pop(context); // 關閉抽屜
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => page)); // 導航到指定頁面並替換當前頁面
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.home, color: Color(0xFF00FAE5)), // 主頁圖示
            title: const Text('首頁'), // 首頁功能表項目
            onTap: () {
              Navigator.pop(context); // 關閉抽屜
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MyApp()), // 導航到主頁
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.volunteer_activism,
                color: Color(0xFFF9410E)), // 健康謠言圖示
            title: const Text('健康闢謠'), // 健康謠言功能表項目
            onTap: () {
              Navigator.pop(context); // 關閉抽屜
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const RumorPage()), // 導航到健康謠言頁面
              );
            },
          ),
          ListTile(
            leading:
                const Icon(Icons.newspaper, color: Color(0xFF1179FA)), // 新聞圖示
            title: const Text('食藥新聞'), // 新聞功能表項目
            onTap: () {
              Navigator.pop(context); // 關閉抽屜
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const NewsPage()), // 導航到新聞頁面
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.map,
                color: Color.fromARGB(255, 91, 17, 250)), // 地圖圖示
            title: const Text('藥局地圖'), // 地圖功能表項目
            onTap: () {
              Navigator.pop(context); // 關閉抽屜
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const MapPage()), // 導航到地圖頁面
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.mood,
                color: Color.fromARGB(255, 227, 17, 250)), // 心情圖示
            title: const Text('記錄心情'), // 心情功能表項目
            onTap: () {
              Navigator.pop(context); // 關閉抽屜
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const MoodPage()), // 導航到心情頁面
              );
            },
          ),
        ],
      ),
    );
  }
}
