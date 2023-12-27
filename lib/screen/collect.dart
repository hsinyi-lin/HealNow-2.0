import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import '../data/dbhelper.dart';

import 'med_info.dart'; // 將 med_info.dart 引入這裡
import 'news_info.dart'; // 替換為你的詳細資訊頁面的引入
import 'package:test_app/widgets/med_card.dart';

class CollectPage extends StatefulWidget {
  @override
  State<CollectPage> createState() => _CollectPageState();
}

class _CollectPageState extends State<CollectPage> {
  //藥品
  final TextEditingController _searchController = TextEditingController();
  late DatabaseHelper _databaseHelper;
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _allData = [];
  bool isLoading = true;
//闢謠

//新聞

  // Define the state for checkboxes
  bool checkbox1 = false;
  bool checkbox2 = false;
  bool checkbox3 = false;

  // 在 _CollectPageState 類中

int _checkedCheckboxCount() {
  int count = 0;
  if (checkbox1) count++;
  if (checkbox2) count++;
  if (checkbox3) count++;
  return count;
}

bool _shouldDisplayMedCard(int index) {
  // 將索引與所選擇的 Checkbox 數量進行比較
  int checkedCount = _checkedCheckboxCount();
  if (checkedCount == 0) {
    // 如果沒有 Checkbox 被選擇，顯示所有 MedCard
    return true;
  } else if (checkedCount == 1) {
    // 根據選擇的 Checkbox 顯示 MedCard
    if (checkbox1 && _searchResults[index]['type'] == '藥品') {
      return true;
    } else if (checkbox2 && _searchResults[index]['type'] == '新聞') {
      return true;
    } else if (checkbox3 && _searchResults[index]['type'] == '謠言') {
      return true;
    }
  } else {
    // 根據選擇的多個 Checkbox 顯示 MedCard
    if (checkbox1 && _searchResults[index]['type'] == '藥品') {
      return true;
    } else if (checkbox2 && _searchResults[index]['type'] == '新聞') {
      return true;
    } else if (checkbox3 && _searchResults[index]['type'] == '謠言') {
      return true;
    }
  }
  return false;
}


  //藥品資料
  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper(createDatabaseConnection());
    _loadAllData();

  }
  

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    await _databaseHelper.openConnection();
    final data = await _databaseHelper.fetchMedData();
    await _databaseHelper.closeConnection();

    setState(() {
      _allData = data;
      _searchResults = data;
      isLoading = false;
    });
  }

  Future<void> _searchData(String searchTerm) async {
    if (searchTerm.isEmpty) {
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

  void _navigateToMedDetailPage(String itemTitle, int itemId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedPage(title: itemTitle, id: itemId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // Left arrow icon button
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                // Handle arrow button press
                // For example, you can navigate to the previous screen
                Navigator.pop(context);
              },
            ),
            // Title text
            const Text(
              "收藏",
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF00FAE5),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        margin: const EdgeInsets.all(15),
        child: Column(
          children: [
            // Row for checkboxes
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Checkbox(
                  value: checkbox1,
                  onChanged: (bool? value) {
                    setState(() {
                      checkbox1 = value!;
                    });
                  },
                ),
                const Text("藥品"),
                Checkbox(
                  value: checkbox2,
                  onChanged: (bool? value) {
                    setState(() {
                      checkbox2 = value!;
                    });
                  },
                ),
                const Text("新聞"),
                Checkbox(
                  value: checkbox3,
                  onChanged: (bool? value) {
                    setState(() {
                      checkbox3 = value!;
                    });
                  },
                ),
                const Text("謠言"),
              ],
            ),
            const SizedBox(height: 10),
                Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final id = _searchResults[index]['id'];
                  // 直接使用MedCard和ListTile小部件显示所有项目
                  return Column(
                    children: [
                      // 药品项目
                      
                      MedCard(
                        medTwName: _searchResults[index]['med_tw_name'],
                        medEnName: _searchResults[index]['med_en_name'],
                        onTap: () {
                          _navigateToMedDetailPage(
                            _searchResults[index]['med_tw_name'],
                            id,
                          );
                        },
                      ),
                      MedCard(
                        medTwName: _searchResults[index]['med_tw_name'],
                        medEnName: _searchResults[index]['med_en_name'],
                        onTap: () {
                          _navigateToMedDetailPage(
                            _searchResults[index]['med_tw_name'],
                            id,
                          );
                        },
                      ),
                      MedCard(
                        medTwName: _searchResults[index]['med_tw_name'],
                        medEnName: _searchResults[index]['med_en_name'],
                        onTap: () {
                          _navigateToMedDetailPage(
                            _searchResults[index]['med_tw_name'],
                            id,
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}