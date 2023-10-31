import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 导入日期格式化的库

import 'main.dart';
import 'news_info.dart'; // 替換為你的詳細資訊頁面的引入
import 'data/dbhelper.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
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
    final data = await _databaseHelper.fetchNewsData();
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
        builder: (context) => NewsInfoPage(title: itemTitle, id: itemId),
      ),
    );
  }

  final List<IconData> randomIcons = [
    Icons.newspaper,
    Icons.menu_book,
    Icons.local_library,
    Icons.email
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
      backgroundColor: Color.fromARGB(255, 230, 243, 251), 
      appBar: AppBar(
        title: const Text(
          '食藥新聞',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold, // 设置字体加粗
          ), // 设置字体颜色为黑色
        ),
        backgroundColor: Color.fromARGB(255, 94, 190, 250), // 10% 的透明度
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
                        color: const Color.fromARGB(255, 22, 50, 255)), // 使用随机图标
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
