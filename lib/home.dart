import 'package:flutter/material.dart';
import 'med_info.dart';  // 替換為你的詳細資訊頁面的引入
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
        item['med_en_name']
            .toLowerCase()
            .contains(searchTerm.toLowerCase()));

    setState(() {
      _searchResults = results.toList();
    });
  }
}

  void _navigateToDetailPage(String itemTitle) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedPage(title: itemTitle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '輸入搜尋文字',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
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
                final med_tw_name = _searchResults[index]['med_tw_name'];
                final med_en_name = _searchResults[index]['med_en_name'];
                return ListTile(
                  title: Text('$med_tw_name'),
                  subtitle: Text('$med_en_name'),
                  onTap: () {
                    _navigateToDetailPage(med_tw_name);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
