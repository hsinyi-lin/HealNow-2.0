// 導入必要的Dart包
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// 導入自訂的文件和類
import 'main.dart';
import 'rumor_info.dart';
import 'data/dbhelper.dart';

// 創建名為RumorPage的StatefulWidget類
class RumorPage extends StatefulWidget {
  const RumorPage({super.key}); // 構造函數

  @override
  State<RumorPage> createState() => _RumorPageState(); // 創建State對象
}

// RumorPage的私有狀態類
class _RumorPageState extends State<RumorPage> {
  final TextEditingController _searchController =
      TextEditingController(); // 創建搜索框控制器
  late DatabaseHelper _databaseHelper; // 創建資料庫説明類物件
  List<Map<String, dynamic>> _searchResults = []; // 存儲搜索結果的清單
  List<Map<String, dynamic>> _allData = []; // 存儲所有資料的清單
  bool isLoading = true; // 用於跟蹤資料載入狀態的布林變數

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper(createDatabaseConnection()); // 初始化資料庫説明類
    _loadAllData(); // 載入所有資料
  }

  @override
  void dispose() {
    _searchController.dispose(); // 釋放搜索框控制器
    super.dispose();
  }

  // 非同步方法，用於載入所有資料
  Future<void> _loadAllData() async {
    await _databaseHelper.openConnection(); // 打開資料庫連接
    final data = await _databaseHelper.fetchRumorData(); // 從資料庫中獲取資料
    await _databaseHelper.closeConnection(); // 關閉資料庫連接

    print(data); // 列印資料

    setState(() {
      _allData = data; // 更新_allData列表
      _searchResults = data; // 初始時搜索結果與所有資料相同
      isLoading = false; // 資料載入完成，isLoading設置為false
    });
  }

  // 非同步方法，用於搜索資料
  Future<void> _searchData(String searchTerm) async {
    if (searchTerm.isEmpty) {
      setState(() {
        _searchResults = _allData; // 如果搜索詞為空，顯示所有資料
      });
    } else {
      final results = _allData.where((item) => item['title']
          .toLowerCase()
          .contains(searchTerm.toLowerCase())); // 根據搜索詞過濾資料

      setState(() {
        _searchResults = results.toList(); // 更新搜索結果
      });
    }
  }

  // 導航到詳細頁面的方法
  void _navigateToDetailPage(String itemTitle, int itemId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RumorInfoPage(
            title: itemTitle, id: itemId), // 創建RumorInfoPage並傳遞標題和ID
      ),
    );
  }

  // 存儲隨機圖示的清單
  final List<IconData> randomIcons = [
    Icons.health_and_safety,
    Icons.favorite_border,
    Icons.favorite,
    Icons.volunteer_activism
  ];

  // 隨機獲取圖示的方法
  IconData getRandomIcon() {
    final random = Random();
    final randomIndex = random.nextInt(randomIcons.length);
    return randomIcons[randomIndex];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 251, 237, 225), // 設置背景顏色
      appBar: AppBar(
        title: const Text(
          '健康闢謠', // 設置標題文本
          style: TextStyle(
            color: Colors.black, // 設置文本顏色
            fontWeight: FontWeight.bold, // 設置文本加粗
          ),
        ),
        backgroundColor: const Color(0xFFF9410E), // 設置AppBar背景顏色
        iconTheme: const IconThemeData(color: Colors.black), // 設置圖示主題顏色
      ),
      drawer: const AppDrawer(), // 設置抽屜菜單
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController, // 將搜索框控制器與TextField關聯
              decoration: InputDecoration(
                hintText: '輸入搜尋文字', // 設置搜索框的提示文本
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search), // 設置搜索圖示
                  onPressed: () {
                    _searchData(_searchController.text); // 點擊搜索圖示時執行搜索方法
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(), // 如果資料載入中，顯示進度條
                  )
                : ListView.builder(
                    itemCount: _searchResults.length, // 列表項數量為搜索結果的長度
                    itemBuilder: (context, index) {
                      final id = _searchResults[index]['id']; // 獲取資料的ID
                      final title = _searchResults[index]['title']; // 獲取資料的標題
                      final publishDate =
                          _searchResults[index]['publish_date']; // 獲取資料的發佈日期
                      final permitDateFormat =
                          DateFormat('yyyy-MM-dd'); // 創建日期格式化對象
                      final formatpublishDate =
                          permitDateFormat.format(publishDate); // 格式化發佈日期

                      return Column(children: [
                        ListTile(
                          leading: Icon(getRandomIcon(),
                              color: const Color.fromARGB(
                                  255, 250, 95, 95)), // 設置清單項的圖示
                          title: Text('$title'), // 設置列表項的標題
                          subtitle: Text(formatpublishDate), // 設置列表項的副標題
                          onTap: () {
                            _navigateToDetailPage(title, id); // 點擊清單項時導航到詳細頁面
                          },
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child:
                              Divider(height: 1, color: Colors.grey), // 添加分割線
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
