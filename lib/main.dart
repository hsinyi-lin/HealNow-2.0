import 'package:flutter/material.dart';
import 'home.dart';
import 'map.dart';
import 'mood.dart';
import 'news.dart';
import 'rumor.dart';

void main() {
  runApp(
    const MaterialApp(
      home: MyApp(),
      debugShowCheckedModeBanner: false,
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
          'HealNow',
          style: TextStyle(
            color: Colors.black,
          ), // 设置字体颜色为黑色
        ),
        backgroundColor: const Color(0xFF00FAE5),
        iconTheme: const IconThemeData(color: Colors.black), // 设置菜单图标颜色为黑色
      ),
      body: const Myhome(), // 將首頁視圖添加到主頁面
      drawer: const AppDrawer(), // 使用全局抽屜
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void navigateToPage(BuildContext context, Widget page) {
    Navigator.pop(context); // 關閉抽屜
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          // const UserAccountsDrawerHeader(
          //   accountName: Text(''),
          //   accountEmail: Text(''),

          //   margin: EdgeInsets.only(bottom: 1), // 仅调整底部外边距
          //   decoration: BoxDecoration(
          //     color: Colors.white, // 设置背景颜色为0xFF00BEFA
          //   ),
          // ),
          ListTile(
            leading: const Icon(Icons.home, color: Color(0xFF00FAE5)), // 主页图标
            title: const Text('首頁'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MyApp()),
              );
            },
            // onTap: () {
            //   navigateToPage(context, MyApp());
            // },
          ),
          ListTile(
            leading: const Icon(Icons.volunteer_activism,
                color: Color(0xFFF9410E)), // 图标
            title: const Text('健康闢謠'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const RumorPage()),
              );
            },
          ),
          ListTile(
            leading:
                const Icon(Icons.newspaper, color: Color(0xFF1179FA)), // 图标
            title: const Text('食藥新聞'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const NewsPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.map,
                color: Color.fromARGB(255, 91, 17, 250)), // 图标
            title: const Text('藥局地圖'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MapPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.mood,
                color: Color.fromARGB(255, 227, 17, 250)), // 图标
            title: const Text('記錄心情'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MoodPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
