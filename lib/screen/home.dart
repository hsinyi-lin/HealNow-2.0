import 'package:flutter/material.dart';

import 'news.dart';
import 'rumor.dart';
import 'med.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,  
      child: Scaffold(
        body: const Column(
          children: <Widget>[
            TabBar(
              labelColor: Colors.black, 
              indicatorColor: Colors.black,  
              tabs: [
                Tab(
                  icon: Icon(Icons.medication), 
                  text: '藥品智庫',
                ),
                Tab(
                  icon: Icon(Icons.newspaper), 
                  text: '食藥新聞',
                ),
                Tab(
                  icon: Icon(Icons.access_alarm), 
                  text: '闢謠專區',
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  MedicationPage(),
                  NewsPage(),
                  RumorPage(),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.black,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '首頁',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group),
              label: '社群',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_pharmacy_outlined),
              label: '藥局',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_add_outlined),
              label: '收藏',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_4_rounded),
              label: '個人',
            ),
          ],
        ),
      ),
    );
  }
}
