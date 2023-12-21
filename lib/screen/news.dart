import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:test_app/screen/main.dart';
import 'package:test_app/widgets/app_drawer.dart';

import 'news_info.dart'; // 替換為你的詳細資訊頁面的引入
import '../data/dbhelper.dart'; // 引入用於數據庫操作的自定義助手類

class NewsPage extends StatefulWidget {
  const NewsPage({super.key}); // 定義名為NewsPage的狀態小部件

  @override
  State<NewsPage> createState() =>
      _NewsPageState(); // 覆寫createState方法以建立NewsPage的狀態
}

class _NewsPageState extends State<NewsPage> {
  final TextEditingController _searchController = TextEditingController();
  late DatabaseHelper _databaseHelper;
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _allData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper(createDatabaseConnection()); // 初始化數據庫助手
    _loadAllData(); // 初始化時載入所有資料
  }

  @override
  void dispose() {
    _searchController.dispose(); // 釋放文本編輯控制器
    super.dispose();
  }

  // 載入所有數據
  Future<void> _loadAllData() async {
    await _databaseHelper.openConnection(); // 打開數據庫連接
    final data = await _databaseHelper.fetchNewsData(); // 從數據庫中獲取新聞數據
    await _databaseHelper.closeConnection(); // 關閉數據庫連接

    print(data); // 列印獲取的數據

    setState(() {
      _allData = data;
      _searchResults = data;
      isLoading = false;
    });
  }

  // 搜索數據
  Future<void> _searchData(String searchTerm) async {
    if (searchTerm.isEmpty) {
      // 如果搜索文本為空，顯示所有資料
      setState(() {
        _searchResults = _allData;
      });
    } else {
      final results = _allData.where((item) => item['title']
          .toLowerCase()
          .contains(searchTerm.toLowerCase())); // 根據標題進行搜索

      setState(() {
        _searchResults = results.toList(); // 更新搜索結果列表
      });
    }
  }

  // 導航到詳細頁面
  void _navigateToDetailPage(String itemTitle, int itemId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewsInfoPage(title: itemTitle, id: itemId),
      ),
    );
  }
  // 存儲隨機圖示的清單
  final List<IconData> randomIcons = [
    Icons.newspaper,
    Icons.menu_book,
    Icons.local_library,
    Icons.email
  ];

  // 獲取隨機圖示的方法
  IconData getRandomIcon() {
    final random = Random();
    final randomIndex = random.nextInt(randomIcons.length);
    return randomIcons[randomIndex]; // 返回隨機圖示
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 230, 243, 251), // 設置背景色
      appBar: AppBar(
        title: const Text(
          '食藥新聞',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 94, 190, 250), // 設置應用程式欄背景色
        iconTheme: const IconThemeData(color: Colors.black), // 設置功能表圖示顏色為黑色
      ),
      drawer: const AppDrawer(), // 設置側邊欄
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
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView.builder(
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
                              color: const Color.fromARGB(255, 22, 50, 255)),
                          title: Text('$title'),
                          subtitle: Text(formatpublishDate),
                          onTap: () {
                            _navigateToDetailPage(title, id);
                          },
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Divider(height: 1, color: Colors.grey),
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
