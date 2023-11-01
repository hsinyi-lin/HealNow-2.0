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

  // 用於執行資源釋放，dispose 是 State 的生命周期方法之一
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 載入所有數據
  Future<void> _loadAllData() async {
    await _databaseHelper.openConnection();
    final data = await _databaseHelper.fetchMedData();
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
          item['med_tw_name']
              .toLowerCase()
              .contains(searchTerm.toLowerCase()) ||
          item['med_en_name'].toLowerCase().contains(searchTerm.toLowerCase()));

      setState(() {
        _searchResults = results.toList();
      });
    }
  }

  void _navigateToDetailPage(String itemTitle, int itemId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedPage(title: itemTitle, id: itemId),
      ),
    );
  }

  // 从这个列表中选择随机图标
  final List<IconData> randomIcons = [
    Icons.medical_services,
    Icons.vaccines,
    Icons.bloodtype,
    Icons.healing
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
      backgroundColor:const Color.fromARGB(255, 231, 247, 246),
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
                final medTwName = _searchResults[index]['med_tw_name'];
                final medEnName = _searchResults[index]['med_en_name'];

                return Column(
                  children: [
                    ListTile(
                      leading: Icon(getRandomIcon(),
                          color: const Color(0xFF1179FA)), // 使用随机图标
                      title: Text('$medTwName'),
                      subtitle: Text('$medEnName'),
                      onTap: () {
                        _navigateToDetailPage(medTwName, id);
                      },
                    ),
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.0), // 设置水平内边距
                      child: Divider(height: 1, color: Colors.grey), // 添加分隔线
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
