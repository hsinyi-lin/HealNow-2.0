import 'package:flutter/material.dart';

import 'med_detail.dart';
import '../widgets/med_card.dart';
import '../services/opendata_services.dart';

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

  @override
  void initState() {
    super.initState();
    medications = OpenDataService().fetchMedications().then((medList) {
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
