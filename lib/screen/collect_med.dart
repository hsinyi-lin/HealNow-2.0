import 'package:flutter/material.dart';
import '../services/opendata_service.dart';
import 'med_detail.dart'; // 將 med_info.dart 引入這裡
import 'package:test_app/widgets/med_card.dart';
import '../utils/token.dart';

class CollectMedPage extends StatefulWidget {
  @override
  State<CollectMedPage> createState() => _CollectMedPageState();
}

class _CollectMedPageState extends State<CollectMedPage> {
  Future<List<dynamic>>? medications;
  List<dynamic> allMedications = []; // 用於儲存所有藥品資料
  List<dynamic> filteredMedications = []; // 用於儲存過濾後的資料
  String searchQuery = '';
  late String token;

  @override
  void initState() {
    super.initState();
    loadToken().then((loadedToken) {
      token = loadedToken;

      setState(() {
        medications =
            OpenDataService().fetchSavedClassList(token, 1).then((medList) {
          allMedications = medList; // 將原始資料儲存在 allMedications
          filteredMedications = medList;
          return medList;
        });
      });
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
                  } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                    return const Center(child: Text('沒有收藏'));
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
