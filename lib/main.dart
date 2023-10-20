import 'package:flutter/material.dart';
import 'home.dart';
import 'map.dart';
void main() {
  runApp(
    MaterialApp(
      home: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('App Title'),
      ),
      body: Myhome(), // 將首頁視圖添加到主頁面
      drawer: AppDrawer(), // 使用全局抽屜
    );
  }
}

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            title: Text('首頁'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MyApp()),
              );
            },
          ),
          ListTile(
            title: Text('闢謠專區'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('身體安全的新聞'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('藥局地圖'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MapPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
