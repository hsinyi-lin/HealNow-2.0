import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'med_detail.dart';
import '../widgets/med_card.dart';

class MedicationPage extends StatefulWidget {
  const MedicationPage({Key? key}) : super(key: key);

  @override
  State<MedicationPage> createState() => _MedicationPageState();
}

class _MedicationPageState extends State<MedicationPage> {
  Future<List<dynamic>>? medications;
  List<dynamic> allMedications = []; // 用於儲存所有藥品資料
  List<dynamic> filteredMedications = []; // 用於儲存過濾後的資料
  String searchQuery = '';

  // 呼叫藥品API
  Future<List<Map<String, dynamic>>> fetchMedications() async {
    final response = await http.get(Uri.parse(
      'https://healnow.azurewebsites.net/opendatas/1',
    ));

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
    medications = fetchMedications().then((medList) {
      allMedications = medList; // 將原始資料儲存在 allMedications
      filteredMedications = medList;
      return medList;
    });
  }

  // 用於查詢後更新的藥品清單
  void updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery;
      filteredMedications = allMedications.where((med) {
        return med['med_tw_name'].toString().contains(newQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 20),
            TextField(
              onChanged: updateSearchQuery,
              decoration: InputDecoration(
                hintText: '名稱',
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(30.0),
                ),
                filled: true,
                fillColor: const Color.fromARGB(255, 234, 234, 234),
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
                      itemCount: filteredMedications.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        var medication = filteredMedications[index];
                        return MedCard(
                          medTwName: medication['med_tw_name'],
                          medEnName: medication['permit_num'],
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => MedicationDetailPage(
                                    medication: medication),
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
}
