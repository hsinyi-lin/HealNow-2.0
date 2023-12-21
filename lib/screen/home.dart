import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'med_detail.dart';
import 'news.dart';
import '../widgets/med_card.dart';

class MedicationLookupPage extends StatefulWidget {
  const MedicationLookupPage({Key? key}) : super(key: key);

  @override
  _MedicationLookupPageState createState() => _MedicationLookupPageState();
}

class _MedicationLookupPageState extends State<MedicationLookupPage> {
  int _currentIndex = 0;
  Future<List<dynamic>>? medications;

  Future<List<Map<String, dynamic>>> fetchMedications() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:5000/opendatas/1',)
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          json.decode(const Utf8Decoder().convert(response.bodyBytes));
      final List<dynamic> recipeList = data['data'];
      return recipeList.map((json) => json as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load medications');
    }
  }

  @override
  void initState() {
    super.initState();
    medications = fetchMedications();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,  
      child: Scaffold(
        body: Column(
          children: <Widget>[
            const TabBar(
              labelColor: Colors.black, 
              indicatorColor: Colors.black,  
              tabs: [
                Tab(
                  icon: Icon(Icons.medication), 
                  text: '藥品智庫',
                ),
                Tab(
                  icon: Icon(Icons.newspaper), 
                  text: '食藥新聞',
                ),
                Tab(
                  icon: Icon(Icons.access_alarm), 
                  text: '闢謠專區',
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  firstTabContent(),
                  const NewsPage(),
                  thirdTabContent(),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.black,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '首頁',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group),
              label: '社群',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_pharmacy_outlined),
              label: '藥局',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_add_outlined),
              label: '收藏',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_4_rounded),
              label: '個人',
            ),
          ],
        ),
      ),
    );
  }


  Widget firstTabContent() {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                hintText: '名稱',
                prefixIcon: const Icon(Icons.search),
                contentPadding: EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(30.0),
                ),
                filled: true,
                fillColor: Color.fromARGB(255, 234, 234, 234),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: medications,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return ListView.separated(
                    itemCount: snapshot.data!.length,
                    separatorBuilder: (context, index) => Divider(),
                    itemBuilder: (context, index) {
                      var medication = snapshot.data![index];
                      return MedCard(
                        medTwName: medication['med_tw_name'],
                        medEnName: medication['permit_num'],
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MedicationDetailPage(medication: medication),
                            ),
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    ),
  );
}

   Widget thirdTabContent() {
    return Center(child: Text('...'));
  }
}
