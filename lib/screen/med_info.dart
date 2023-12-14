import 'package:flutter/material.dart';
import '../data/dbhelper.dart';
import 'package:intl/intl.dart';

class MedPage extends StatefulWidget {
  final String title;
  final int id;

  const MedPage({required this.title, required this.id, super.key});

  @override
  State<MedPage> createState() => _MedPageState();
}

class _MedPageState extends State<MedPage> {
  late DatabaseHelper _databaseHelper;

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper(createDatabaseConnection());
  }

  Future<List<Map<String, dynamic>>> fetchData() async {
    await _databaseHelper.openConnection();
    final data =
        await _databaseHelper.fetchMedDataByTitle(widget.title, widget.id);
    await _databaseHelper.closeConnection();
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '內容',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: const Color(0xFF00FAE5),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          } else {
            final data = snapshot.data;

            if (data == null || data.isEmpty) {
              return const Center(child: Text('No data available'));
            }

            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final medTwName = data[index]['med_tw_name'];
                final medEnName = data[index]['med_en_name'];
                final medType = data[index]['med_type'];
                final composition = data[index]['composition'];
                final indications = data[index]['indications'];
                final howToUse = data[index]['how_to_use'];
                final permitNum = data[index]['permit_num'];
                final permitType = data[index]['permit_type'];

                final permitDate = data[index]['permit_date'];
                final expirationDate = data[index]['expiration_date'];

                final permitDateFormat = DateFormat('yyyy-MM-dd');
                final formatpermitDate = permitDateFormat.format(permitDate);
                final formatExpirationDate =
                    permitDateFormat.format(expirationDate);

                return Container(
                  margin: const EdgeInsets.all(15),
                  child: ListTile(
                    title: Text(
                      medTwName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10.0),
                          child: Text('英文名: $medEnName',
                              style: const TextStyle(
                                  color: Colors.black87, fontSize: 20)),
                        ),
                        const Divider(height: 1, color: Colors.grey),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10.0),
                          child: Text('類型: $medType',
                              style: const TextStyle(
                                  color: Colors.black87, fontSize: 20)),
                        ),
                        const Divider(height: 1, color: Colors.grey),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10.0),
                          child: Text('成分: $composition',
                              style: const TextStyle(
                                  color: Colors.black87, fontSize: 20)),
                        ),
                        const Divider(height: 1, color: Colors.grey),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10.0),
                          child: Text('適應症: $indications',
                              style: const TextStyle(
                                  color: Colors.black87, fontSize: 20)),
                        ),
                        const Divider(height: 1, color: Colors.grey),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10.0),
                          child: Text('使用方法: $howToUse',
                              style: const TextStyle(
                                  color: Colors.black87, fontSize: 20)),
                        ),
                        const Divider(height: 1, color: Colors.grey),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10.0),
                          child: Text('批准號: $permitNum',
                              style: const TextStyle(
                                  color: Colors.black87, fontSize: 20)),
                        ),
                        const Divider(height: 1, color: Colors.grey),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10.0),
                          child: Text('批准類型: $permitType',
                              style: const TextStyle(
                                  color: Colors.black87, fontSize: 20)),
                        ),
                        const Divider(height: 1, color: Colors.grey),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10.0),
                          child: Text('批准日期: $formatpermitDate',
                              style: const TextStyle(
                                  color: Colors.black87, fontSize: 20)),
                        ),
                        const Divider(height: 1, color: Colors.grey),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10.0),
                          child: Text('過期日期: $formatExpirationDate',
                              style: const TextStyle(
                                  color: Colors.black87, fontSize: 20)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
