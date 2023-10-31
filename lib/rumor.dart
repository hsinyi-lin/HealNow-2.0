import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 导入日期格式化的库

import 'main.dart';
import 'rumor_info.dart'; // 替換為你的詳細資訊頁面的引入
import 'data/dbhelper.dart';

class RumorPage extends StatefulWidget {
  const RumorPage({super.key});

  @override
  State<RumorPage> createState() => _RumorPageState();
}

class _RumorPageState extends State<RumorPage> {
  final TextEditingController _searchController = TextEditingController();
  late DatabaseHelper _databaseHelper;
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _allData = [];

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper(createDatabaseConnection());
    _loadAllData(); // 初始化時載入所有資料
  }

  // 載入所有數據
  Future<void> _loadAllData() async {
    await _databaseHelper.openConnection();
    final data = await _databaseHelper.fetchRumorData();
    await _databaseHelper.closeConnection();

    setState(() {
      _allData = data;
      _searchResults = data;
    });
  }

  Future<void> _searchData(String searchTerm) async {
    if (searchTerm.isEmpty) {
      // 如果搜索文本为空，显示所有数据
      setState(() {
        _searchResults = _allData;
      });
    } else {
      final results = _allData.where((item) =>
          item['title'].toLowerCase().contains(searchTerm.toLowerCase()));

      setState(() {
        _searchResults = results.toList();
      });
    }
  }

  void _navigateToDetailPage(String itemTitle, int itemId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RumorInfoPage(title: itemTitle, id: itemId),
      ),
    );
  }

  final List<IconData> randomIcons = [
    Icons.health_and_safety,
    Icons.favorite_border,
    Icons.favorite,
    Icons.volunteer_activism
  ];

  // 获取随机图标的方法
  IconData getRandomIcon() {
    final random = Random();
    final randomIndex = random.nextInt(randomIcons.length);
    return randomIcons[randomIndex];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 248, 216, 183),
      appBar: AppBar(
        title: const Text(
          '健康闢謠',
          style: TextStyle(
            color: Colors.black,
          ), // 设置字体颜色为黑色
        ),
        backgroundColor: Color(0xFFF9410E),
        iconTheme: IconThemeData(color: Colors.black), // 设置菜单图标颜色为黑色
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '輸入搜尋文字',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    _searchData(_searchController.text);
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final id = _searchResults[index]['id'];
                final title = _searchResults[index]['title'];
                final publishDate = _searchResults[index]['publish_date'];
                final permitDateFormat = DateFormat('yyyy-MM-dd');
                final formatpublishDate = permitDateFormat.format(publishDate);

                return Column(children: [
                  ListTile(
                    leading: Icon(getRandomIcon(),
                        color: Color.fromARGB(255, 250, 95, 95)), // 使用随机图标
                    title: Text('$title'),
                    subtitle: Text(formatpublishDate),
                    onTap: () {
                      _navigateToDetailPage(title, id);
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0), // 设置水平内边距
                    child: Divider(height: 1, color: Colors.grey), // 添加分隔线
                  ),
                ]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
