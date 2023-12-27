import 'package:flutter/material.dart';
import 'package:test_app/main.dart';
import 'package:test_app/screen/map.dart';
import 'package:test_app/screen/mood.dart';
import 'package:test_app/screen/news.dart';
import 'package:test_app/screen/rumor.dart';
import 'package:test_app/screen/collect.dart';
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void navigateToPage(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.home, color: Color(0xFF00FAE5)),
            title: const Text('首頁'),
            onTap: () {
              navigateToPage(context, const MyApp());
            },
          ),
          ListTile(
            leading: const Icon(Icons.volunteer_activism, color: Color(0xFFF9410E)),
            title: const Text('健康闢謠'),
            onTap: () {
              navigateToPage(context, const RumorPage());
            },
          ),
          ListTile(
            leading: const Icon(Icons.newspaper, color: Color(0xFF1179FA)),
            title: const Text('食藥新聞'),
            onTap: () {
              navigateToPage(context, const NewsPage());
            },
          ),
          ListTile(
            leading: const Icon(Icons.map, color: Color.fromARGB(255, 91, 17, 250)),
            title: const Text('藥局地圖'),
            onTap: () {
              navigateToPage(context, const MapPage());
            },
          ),
          ListTile(
            leading: const Icon(Icons.mood, color: Color.fromARGB(255, 227, 17, 250)),
            title: const Text('記錄心情'),
            onTap: () {
              navigateToPage(context, const MoodPage());
            },
          ),
          ListTile(
            leading: const Icon(Icons.mood, color: Color.fromARGB(255, 227, 17, 250)),
            title: const Text('收藏'),
            onTap: () {
              navigateToPage(context, CollectPage());
            },
          ),
        ],
      ),
    );
  }
}
