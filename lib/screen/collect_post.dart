import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import '../data/dbhelper.dart';

import 'med_detail.dart'; // 將 med_info.dart 引入這裡
import 'news_detail.dart'; // 替換為你的詳細資訊頁面的引入
import 'package:test_app/widgets/med_card.dart';

class CollectPostPage extends StatefulWidget {
  @override
  State<CollectPostPage> createState() => _CollectPostPageState();
}

class _CollectPostPageState extends State<CollectPostPage> {
  //藥品
  final TextEditingController _searchController = TextEditingController();
  late DatabaseHelper _databaseHelper;
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _allData = [];
  bool isLoading = true;



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
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => MedPage(title: itemTitle, id: itemId),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: Container(
        margin: const EdgeInsets.all(15),
        child: Column(
          children: [           
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