import 'package:flutter/material.dart';
import '../services/opendata_service.dart';
import '../widgets/rumor_card.dart';
import 'rumor_detail.dart';
import '../utils/token.dart';

class CollectRumorPage extends StatefulWidget {
  @override
  State<CollectRumorPage> createState() => _CollectRumorPageState();
}

class _CollectRumorPageState extends State<CollectRumorPage> {
  Future<List<dynamic>>? rumors;
  List<dynamic> allRumors = [];
  List<dynamic> filteredRumors = [];
  String searchQuery = '';
  late String token;

  @override
  void initState() {
    super.initState();
    loadToken().then((loadedToken) {
      token = loadedToken;

      setState(() {
        rumors =
            OpenDataService().fetchSavedClassList(token, 3).then((rumorList) {
          allRumors = rumorList;
          filteredRumors = rumorList;
          return rumorList;
        });
      });
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
                      separatorBuilder: (context, index) => const Divider(),
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
