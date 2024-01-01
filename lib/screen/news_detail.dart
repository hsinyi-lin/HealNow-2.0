import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/opendata_service.dart';

String formatDateString(String dateString) {
  DateFormat inputFormat = DateFormat('EEE, dd MMM yyyy HH:mm:ss \'GMT\'');
  DateTime dateTime = inputFormat.parse(dateString, true).toLocal();
  String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
  return formattedDate;
}

class NewsDetailPage extends StatefulWidget {
  final Map<String, dynamic> news;

  const NewsDetailPage({Key? key, required this.news}) : super(key: key);

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  late String token;
  bool? isFavorite;

  @override
  void initState() {
    super.initState();

    loadToken().then((loadedToken) {
      token = loadedToken;

      OpenDataService().fetchSavedClassList(token, 2).then((savedNews) {
        setState(() {
          isFavorite = savedNews
              .any((savedOneNews) => savedOneNews['id'] == widget.news['id']);
        });
      }).catchError((error) {
        print('Error fetching saved news: $error');
      });
    });
  }

  Future<String> loadToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  // 收藏狀態
  Future<void> toggleFavoriteStatus() async {
    try {
      await OpenDataService().toggleFavoriteStatus(
          token, 2, widget.news['id'], isFavorite ?? false);
      setState(() {
        isFavorite = !(isFavorite ?? false);
      });
    } catch (error) {
      print('Error updating favorite status: $error');
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
            const Divider(),
            detailItem(Icons.my_library_books, '內文',
                widget.news['content'].replaceAll('。 ', '。\n\n')),
            const Divider(),
            detailItem(Icons.language, '連結', widget.news['url']),
          ],
        ),
      ),
    );
  }

  Widget detailItem(IconData icon, String title, String? value) {
    bool isUrl = value != null && value.startsWith('http');
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
            child: isUrl
                ? InkWell(
                    child: Text(displayValue,
                        style: TextStyle(color: Colors.blue)),
                    onTap: () => _launchURL(value),
                  )
                : Text(displayValue),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String? urlString) async {
    if (urlString == null) return;

    final Uri url = Uri.parse(urlString);

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'can not open $urlString';
    }
  }
}
