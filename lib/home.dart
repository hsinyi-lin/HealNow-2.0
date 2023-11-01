import 'dart:math'; // 導入Dart標準庫中的數學庫，以便後續使用亂數功能
import 'package:flutter/material.dart'; // 導入Flutter框架的Material庫，以構建使用者介面
import 'med_info.dart'; // 導入自訂的med_info.dart檔，可能包含了有關藥物資訊的相關代碼
import 'data/dbhelper.dart'; // 導入自訂的dbhelper.dart檔，可能包含了與資料庫交互相關的代碼

class Myhome extends StatefulWidget {
  // 創建一個名為Myhome的自訂有狀態元件，該元件繼承自StatefulWidget
  const Myhome({super.key}); // Myhome構造函數，接受一個可選的鍵參數

  @override
  State<Myhome> createState() =>
      _MyhomeState(); // 重寫createState方法，返回一個_MyhomeState物件
}

class _MyhomeState extends State<Myhome> {
  // 創建_MyhomeState類，該類是Myhome元件的狀態管理器
  final TextEditingController _searchController =
      TextEditingController(); // 創建一個文本編輯控制器用於搜索文本輸入
  late DatabaseHelper _databaseHelper; // 創建一個DatabaseHelper物件用於資料庫操作
  List<Map<String, dynamic>> _searchResults = []; // 用於存儲搜索結果的清單
  List<Map<String, dynamic>> _allData = []; // 用於存儲所有資料的清單
  bool isLoading = true; // 用於標識資料載入狀態的布林變數

  @override
  void initState() {
    // 重寫initState方法，用於初始化狀態
    super.initState();
    _databaseHelper = DatabaseHelper(
        createDatabaseConnection()); // 初始化_databaseHelper，並創建資料庫連接
    _loadAllData(); // 調用_loadAllData方法載入所有資料
  }

  @override
  void dispose() {
    // 重寫dispose方法，用於釋放資源
    _searchController.dispose(); // 釋放搜索文本編輯控制器
    super.dispose();
  }

  Future<void> _loadAllData() async {
    // 非同步方法，用於載入所有資料
    await _databaseHelper.openConnection(); // 打開資料庫連接
    final data = await _databaseHelper.fetchMedData(); // 從資料庫中獲取藥物資料
    await _databaseHelper.closeConnection(); // 關閉資料庫連接

    print(data); // 列印獲取的資料

    setState(() {
      // 更新狀態
      _allData = data; // 將獲取的資料賦值給_allData
      _searchResults = data; // 初始時搜索結果包含所有資料
      isLoading = false; // 資料載入完成，isLoading設為false
    });
  }

  Future<void> _searchData(String searchTerm) async {
    // 非同步方法，用於搜索資料
    if (searchTerm.isEmpty) {
      // 如果搜索詞為空
      setState(() {
        _searchResults = _allData; // 將搜索結果設為所有資料
      });
    } else {
      final results = _allData.where((item) =>
          item['med_tw_name']
              .toLowerCase()
              .contains(searchTerm.toLowerCase()) ||
          item['med_en_name'].toLowerCase().contains(searchTerm.toLowerCase()));

      setState(() {
        _searchResults = results.toList(); // 將搜索結果設為滿足條件的資料清單
      });
    }
  }

  void _navigateToDetailPage(String itemTitle, int itemId) {
    // 導航到詳情頁面的方法
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MedPage(title: itemTitle, id: itemId), // 創建MedPage頁面並傳遞標題和ID
      ),
    );
  }

  final List<IconData> randomIcons = [
    // 創建一個包含隨機圖示的IconData清單
    Icons.medical_services,
    Icons.vaccines,
    Icons.bloodtype,
    Icons.healing
  ];

  IconData getRandomIcon() {
    // 獲取隨機圖示的方法
    final random = Random(); // 創建亂數產生器對象
    final randomIndex = random.nextInt(randomIcons.length); // 生成一個隨機索引
    return randomIcons[randomIndex]; // 返回隨機圖示
  }

  @override
  Widget build(BuildContext context) {
    // 重寫build方法，用於構建使用者介面
    return Scaffold(
      // 創建一個基本的Scaffold頁面
      backgroundColor: const Color.fromARGB(255, 231, 247, 246), // 設置背景顏色
      body: Column(
        // 創建一個垂直佈局的Column
        children: <Widget>[
          Padding(
            // 創建一個內邊距以包裝文本輸入框
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController, // 設置文本編輯控制器
              decoration: InputDecoration(
                hintText: '輸入搜尋文字', // 設置輸入框的提示文本
                suffixIcon: IconButton(
                  // 添加搜索圖示按鈕
                  icon: const Icon(Icons.search), // 設置圖示為搜索圖示
                  onPressed: () {
                    _searchData(_searchController.text); // 點擊搜索按鈕時執行搜索資料方法
                  },
                ),
              ),
            ),
          ),
          Expanded(
            // 創建一個可擴展的部分，用於顯示搜索結果清單
            child: isLoading // 如果資料正在載入
                ? const Center(
                    // 顯示載入指示器
                    child: CircularProgressIndicator(),
                  )
                : ListView.builder(
                    // 構建搜索結果列表
                    itemCount: _searchResults.length, // 列表項數量為搜索結果的數量
                    itemBuilder: (context, index) {
                      // 構建列表項的方法
                      final id = _searchResults[index]['id']; // 獲取藥物的ID
                      final medTwName =
                          _searchResults[index]['med_tw_name']; // 獲取中文藥名
                      final medEnName =
                          _searchResults[index]['med_en_name']; // 獲取英文藥名

                      return Column(
                        // 創建一個垂直佈局的Column
                        children: [
                          ListTile(
                            // 創建一個列表項
                            leading: Icon(getRandomIcon(), // 設置清單項前導圖示為隨機圖示
                                color: const Color(0xFF1179FA)), // 設置圖示顏色
                            title: Text('$medTwName'), // 顯示中文藥名
                            subtitle: Text('$medEnName'), // 顯示英文藥名
                            onTap: () {
                              _navigateToDetailPage(
                                  medTwName, id); // 點擊清單項時導航到詳情頁面
                            },
                          ),
                          const Padding(
                            // 創建一個內邊距以分隔列表項
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Divider(height: 1, color: Colors.grey),
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
