import 'package:flutter/material.dart';
import 'package:test_app/widgets/med_card.dart';
import 'med_info.dart'; // 將 med_info.dart 引入這裡
import '../data/dbhelper.dart';

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

  void _navigateToDetailPage(String itemTitle, int itemId) {
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
      backgroundColor: const Color.fromARGB(255, 231, 247, 246),
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
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final id = _searchResults[index]['id'];
                      final medTwName = _searchResults[index]['med_tw_name'];
                      final medEnName = _searchResults[index]['med_en_name'];

                      return MedCard(
                        medTwName: medTwName,
                        medEnName: medEnName,
                        onTap: () {
                          _navigateToDetailPage(medTwName, id);
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
