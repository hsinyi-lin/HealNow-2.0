import 'package:flutter/material.dart';
import '../services/opendata_service.dart';
import '../widgets/news_card.dart';
import 'news_detail.dart';
import '../utils/token.dart';

class CollectNewsPage extends StatefulWidget {
  @override
  State<CollectNewsPage> createState() => _CollectNewsPageState();
}

class _CollectNewsPageState extends State<CollectNewsPage> {
  Future<List<dynamic>>? news;
  List<dynamic> allNews = []; // 用於儲存所有資料
  List<dynamic> filteredNews = []; // 用於儲存過濾後的資料
  String searchQuery = '';
  late String token;

  @override
  void initState() {
    super.initState();
    loadToken().then((loadedToken) {
      token = loadedToken;

      setState(() {
        news = OpenDataService().fetchSavedClassList(token, 2).then((newsList) {
          allNews = newsList;
          filteredNews = newsList;
          return newsList;
        });
      });
    });
  }

  void updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery;
      filteredNews = allNews.where((news) {
        return news['title'].toString().contains(newQuery);
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
                future: news,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                    } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                    return const Center(child: Text('沒有收藏'));
                  } else {
                    return ListView.separated(
                      itemCount: filteredNews.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        var item = filteredNews[index];
                        return NewsCard(
                          newsDate: item['publish_date'],
                          newsTitle: item['title'],
                          newsContent: item['content'],
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    NewsDetailPage(news: item),
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
