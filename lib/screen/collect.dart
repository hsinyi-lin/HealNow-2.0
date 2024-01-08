import 'package:flutter/material.dart';

import 'news.dart';
import 'rumor.dart';
import 'med.dart';
import 'pharmacy.dart';
import 'collect_med.dart';
import 'collect_news.dart';
import 'collect_rumor.dart';
import 'collect_post.dart';

class CollectPage extends StatefulWidget {
  const CollectPage({Key? key}) : super(key: key);

  @override
  State<CollectPage> createState() => _CollectPageState();
}

class _CollectPageState extends State<CollectPage> {
  int _currentIndex = 0;

  // 切換頁面方法
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          '收藏',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: <Widget>[
          DefaultTabController(
            length: 4,
            child: Column(
              children: <Widget>[
                const TabBar(
                  labelColor: Colors.black,
                  indicatorColor: Colors.black,
                  tabs: [
                    Tab(text: '藥品'),
                    Tab(text: '新聞'),
                    Tab(text: '闢謠'),
                    Tab(text: '貼文'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      CollectMedPage(),
                      CollectNewsPage(),
                      CollectRumorPage(),
                      CollectPostPage(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
