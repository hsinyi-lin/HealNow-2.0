import 'package:flutter/material.dart';
import '../services/opendata_service.dart';
import 'med_detail.dart'; // 將 med_info.dart 引入這裡
import 'package:test_app/widgets/med_card.dart';

class CollectRumorPage extends StatefulWidget {
  @override
  State<CollectRumorPage> createState() => _CollectRumorPageState();
}

class _CollectRumorPageState extends State<CollectRumorPage> {
 Future<List<dynamic>>? medications;
  List<dynamic> allMedications = []; // 用於儲存所有藥品資料
  List<dynamic> filteredMedications = []; // 用於儲存過濾後的資料
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    medications = OpenDataService().fetchCollectMed().then((medList) {
      allMedications = medList; // 將原始資料儲存在 allMedications
      filteredMedications = medList;
      return medList;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: <Widget>[
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
