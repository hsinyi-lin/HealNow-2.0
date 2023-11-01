import 'dart:math';

import 'package:flutter/material.dart';
import 'med_info.dart'; // 替換為你的詳細資訊頁面的引入
import 'data/dbhelper.dart';

class Myhome extends StatefulWidget {
  const Myhome({super.key});

  @override
  State<Myhome> createState() => _MyhomeState();
}

class _MyhomeState extends State<Myhome> {
  final TextEditingController _searchController =
      TextEditingController(); // 創建搜索文字方塊的控制器
  late DatabaseHelper _databaseHelper; // 創建資料庫説明類的實例
  List<Map<String, dynamic>> _searchResults = []; // 存儲搜索結果的清單
  List<Map<String, dynamic>> _allData = []; // 存儲所有資料的清單

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper(createDatabaseConnection()); // 初始化資料庫説明類
    _loadAllData(); // 初始化時載入所有資料
  }

  // 用於執行資源釋放，dispose 是 State 的生命週期方法之一
  @override
  void dispose() {
    _searchController.dispose(); // 釋放搜索文字方塊的控制器
    super.dispose();
  }

  // 載入所有資料
  Future<void> _loadAllData() async {
    await _databaseHelper.openConnection(); // 打開資料庫連接
    final data = await _databaseHelper.fetchMedData(); // 從資料庫獲取藥物資料
    await _databaseHelper.closeConnection(); // 關閉資料庫連接

    setState(() {
      _allData = data; // 更新所有資料清單
      _searchResults = data; // 更新搜索結果列表
    });
  }

  Future<void> _searchData(String searchTerm) async {
    if (searchTerm.isEmpty) {
      // 如果搜索文本為空，顯示所有資料
      setState(() {
        _searchResults = _allData;
      });
    } else {
      final results = _allData.where((item) =>
          item['med_tw_name']
              .toLowerCase()
              .contains(searchTerm.toLowerCase()) ||
          item['med_en_name'].toLowerCase().contains(searchTerm.toLowerCase()));

      setState(() {
        _searchResults = results.toList(); // 更新搜索結果列表
      });
    }
  }

  void _navigateToDetailPage(String itemTitle, int itemId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MedPage(title: itemTitle, id: itemId), // 導航到詳細資訊頁面
      ),
    );
  }

  // 從這個清單中選擇隨機圖示
  final List<IconData> randomIcons = [
    Icons.medical_services,
    Icons.vaccines,
    Icons.bloodtype,
    Icons.healing
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
      backgroundColor: const Color.fromARGB(255, 231, 247, 246), // 設置背景顏色
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '輸入搜尋文字', // 設置搜索文字方塊的提示文字
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search), // 設置搜索圖示
                  onPressed: () {
                    _searchData(_searchController.text); // 觸發搜索操作
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
                final medTwName = _searchResults[index]['med_tw_name'];
                final medEnName = _searchResults[index]['med_en_name'];

                return Column(
                  children: [
                    ListTile(
                      leading: Icon(getRandomIcon(),
                          color: const Color(0xFF1179FA)), // 使用隨機圖示
                      title: Text('$medTwName'), // 顯示藥物中文名稱
                      subtitle: Text('$medEnName'), // 顯示藥物英文名稱
                      onTap: () {
                        _navigateToDetailPage(medTwName, id); // 點擊時導航到詳細資訊頁面
                      },
                    ),
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.0), // 設置水準內邊距
                      child: Divider(height: 1, color: Colors.grey), // 添加分隔線
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
