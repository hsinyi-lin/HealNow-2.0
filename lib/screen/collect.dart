import 'package:flutter/material.dart';

import 'news.dart';
import 'rumor.dart';
import 'med.dart';
import 'pharmacy.dart';
import 'collect_other.dart';
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
      body: IndexedStack(
        index: _currentIndex,
        children: <Widget>[
          DefaultTabController(
            length: 2,
            child: Column(
              children: <Widget>[
                const TabBar(
                  labelColor: Colors.black,
                  indicatorColor: Colors.black,
                  tabs: [
                    Tab(icon: Icon(Icons.medication), text: '貼文'),
                    Tab(icon: Icon(Icons.newspaper), text: '其他'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      CollectPostPage(),
                      CollectOtherPage(),
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
