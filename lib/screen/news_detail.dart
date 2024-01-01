import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';


String formatDateString(String dateString) {
  DateFormat inputFormat = DateFormat('EEE, dd MMM yyyy HH:mm:ss \'GMT\'');
  DateTime dateTime = inputFormat.parse(dateString, true).toLocal();
  String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
  return formattedDate;
}

class NewsDetailPage extends StatefulWidget {
  final Map<String, dynamic> news;

  const NewsDetailPage({Key? key, required this.news})
      : super(key: key);

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  bool? isFavorite;

  @override
  void initState() {
    super.initState();

    // 取得收藏列表進行比對，以顯示收藏icon類型
    fetchSavedNews().then((savedNews) {
      setState(() {
        isFavorite = savedNews
            .any((savedOneNews) => savedOneNews['id'] == widget.news['id']);
      });
    }).catchError((error) {
      print('Error fetching saved news: $error');
    });
  }

  // 取得收藏列表
  Future<List<dynamic>> fetchSavedNews() async {
    final url = Uri.parse('http://127.0.0.1:5000/opendatas/save_class/2');
    String token =
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJmcmVzaCI6ZmFsc2UsImlhdCI6MTcwMjMwMTE5MywianRpIjoiYTIzOTkzZjEtNTNmNy00MWE1LTg5NWQtNmY2ZGU5NWNiNmIyIiwidHlwZSI6ImFjY2VzcyIsInN1YiI6IjExMTM2MDA0QG50dWIuZWR1LnR3IiwibmJmIjoxNzAyMzAxMTkzLCJleHAiOjE3MDc0ODUxOTN9.4C9f_WxW5uV2JqnOUrK1AidGiQ5hzzr3AnXxPQ5ak00";

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return data.map((json) => json as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load saved news');
    }
  }

  Future<void> toggleFavoriteStatus() async {
    final url = Uri.parse(
        'http://127.0.0.1:5000/opendatas/save_class/2/${widget.news['id']}');
    String token =
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJmcmVzaCI6ZmFsc2UsImlhdCI6MTcwMjMwMTE5MywianRpIjoiYTIzOTkzZjEtNTNmNy00MWE1LTg5NWQtNmY2ZGU5NWNiNmIyIiwidHlwZSI6ImFjY2VzcyIsInN1YiI6IjExMTM2MDA0QG50dWIuZWR1LnR3IiwibmJmIjoxNzAyMzAxMTkzLCJleHAiOjE3MDc0ODUxOTN9.4C9f_WxW5uV2JqnOUrK1AidGiQ5hzzr3AnXxPQ5ak00";

    http.Response response;

    // 如果 isFavorite 是 true，執行移除收藏
    if (isFavorite == true) {
      response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
    } else {
      // 如果 isFavorite 是 false，執行新增收藏
      response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
    }

    if (response.statusCode == 200) {
      setState(() {
        // 改變收藏icon
        isFavorite = !(isFavorite ?? false);
      });
    } else {
      print('Error updating favorite status');
    }
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          '新聞內容',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: <Widget>[
          IconButton(
            icon: Icon(
                isFavorite == true ? Icons.bookmark : Icons.bookmark_border),
            onPressed: toggleFavoriteStatus,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            detailItem(Icons.star_half, widget.news['title'],
                formatDateString(widget.news['publish_date'])),
            Divider(),
            detailItem(Icons.my_library_books, '內文', widget.news['content'].replaceAll('。 ', '。\n\n')),
            Divider(),
            detailItem(Icons.language, '連結', widget.news['url']),
          ],
        ),
      ),
    );
  }

  Widget detailItem(IconData icon, String title, String? value) {
    String displayValue = (value == null || value.isEmpty) ? '未提供' : value;
    

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              Icon(icon),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 32.0),
            child: Text(displayValue),
          ),
        ],
      ),
    );
  }
}
