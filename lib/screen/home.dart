import 'package:flutter/material.dart';

import 'news.dart';
import 'rumor.dart';
import 'med.dart';
import 'pharmacy.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
          const DefaultTabController(
            length: 3,  
            child: Column(
              children: <Widget>[
                TabBar(
                  labelColor: Colors.black, 
                  indicatorColor: Colors.black,  
                  tabs: [
                    Tab(icon: Icon(Icons.medication), text: '藥品智庫'),
                    Tab(icon: Icon(Icons.newspaper), text: '食藥新聞'),
                    Tab(icon: Icon(Icons.access_alarm), text: '闢謠專區'),
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
          ),
          Container(),
          // 藥局
          PharmacyPage(),
          // 收藏(未來需移動至個人)
          Container(),
          // 個人
          Container(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '首頁'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: '社群'),
          BottomNavigationBarItem(icon: Icon(Icons.local_pharmacy_outlined), label: '藥局'),
          BottomNavigationBarItem(icon: Icon(Icons.local_pharmacy_outlined), label: '收藏'),  // 未來需移動至個人
          BottomNavigationBarItem(icon: Icon(Icons.person_4_rounded), label: '個人'),
        ],
      ),
    );
  }
}
