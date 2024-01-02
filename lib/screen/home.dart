import 'package:flutter/material.dart';
import 'package:test_app/screen/social.dart';

import 'news.dart';
import 'rumor.dart';
import 'med.dart';
import 'pharmacy.dart';
import 'personal.dart';

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
      appBar: AppBar(
        title: Center(
          child: Image.asset(
            'assets/images/healnow.png',
            height: AppBar().preferredSize.height * 0.8,
            fit: BoxFit.contain,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.grey),
        elevation: 0,
      ),
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
          //社群
          SocialPage(),
          // 藥局
          const PharmacyPage(),
          // 個人
          const PersonalPage(),
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
          BottomNavigationBarItem(icon: Icon(Icons.person_4_rounded), label: '個人'),
        ],
      ),
    );
  }
}
