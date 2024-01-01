import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../widgets/rumor_card.dart';
import 'rumor_detail.dart';

class RumorPage extends StatefulWidget {
  const RumorPage({Key? key}) : super(key: key);

  @override
  State<RumorPage> createState() => _RumorPageState();
}

class _RumorPageState extends State<RumorPage> {
  Future<List<dynamic>>? rumors;
  List<dynamic> allRumors = []; 
  List<dynamic> filteredRumors = []; 
  String searchQuery = '';

  Future<List<Map<String, dynamic>>> fetchRumors() async {
    final response = await http.get(Uri.parse(
      'https://healnow.azurewebsites.net/opendatas/3',
    ));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          json.decode(const Utf8Decoder().convert(response.bodyBytes));
      final List<dynamic> rumorList = data['data'];
      return rumorList.map((json) => json as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load rumors');
    }
  }

  @override
  void initState() {
    super.initState();
    rumors = fetchRumors().then((rumorList) {
      allRumors = rumorList;
      filteredRumors = rumorList;
      return rumorList;
    });
  }

  void updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery;
      filteredRumors = allRumors.where((rumor) {
        return rumor['title'].toString().contains(newQuery);
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
                future: rumors,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return ListView.separated(
                      itemCount: filteredRumors.length,
                      separatorBuilder: (context, index) => Divider(),
                      itemBuilder: (context, index) {
                        var rumor = filteredRumors[index];
                        return RumorCard(
                          rumorDate: rumor['publish_date'],
                          rumorTitle: rumor['title'],
                          rumorContent: rumor['content'],
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    RumorDetailPage(rumors: rumor),
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
