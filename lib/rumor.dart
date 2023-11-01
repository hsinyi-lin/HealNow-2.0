import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'main.dart';
import 'rumor_info.dart';
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
  bool isLoading = true;

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
    final data = await _databaseHelper.fetchRumorData();
    await _databaseHelper.closeConnection();

    print(data);

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

  IconData getRandomIcon() {
    final random = Random();
    final randomIndex = random.nextInt(randomIcons.length);
    return randomIcons[randomIndex];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 216, 183),
      appBar: AppBar(
        title: const Text(
          '健康闢謠',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFF9410E),
        iconTheme: const IconThemeData(color: Colors.black),
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
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(), // 使用 CircularProgressIndicator 作為 loading icon
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
                              color: const Color.fromARGB(255, 250, 95, 95)),
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
