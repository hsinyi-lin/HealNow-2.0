import 'package:flutter/material.dart';

import '../services/opendata_service.dart';
import '../utils/utils.dart';
import '../utils/token.dart';


class RumorDetailPage extends StatefulWidget {
  final Map<String, dynamic> rumors;

  const RumorDetailPage({Key? key, required this.rumors}) : super(key: key);

  @override
  State<RumorDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<RumorDetailPage> {
  late String token;
  bool? isFavorite;

  @override
  void initState() {
    super.initState();

    loadToken().then((loadedToken) {
      token = loadedToken;

      OpenDataService().fetchSavedClassList(token, 3).then((savedRumors) {
        setState(() {
          isFavorite = savedRumors
              .any((savedRumor) => savedRumor['id'] == widget.rumors['id']);
        });
      }).catchError((error) {
        print('Error fetching saved rumors: $error');
      });
    });
  }

  // 收藏狀態
  Future<void> toggleFavoriteStatus() async {
    try {
      await OpenDataService().toggleFavoriteStatus(
          token, 2, widget.rumors['id'], isFavorite ?? false);
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
          '闢謠內容',
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
            detailItem(Icons.star_half, widget.rumors['title'],
                formatDateString(widget.rumors['publish_date'])),
            Divider(),
            detailItem(Icons.my_library_books, '內文',
                widget.rumors['content'].replaceAll('。 ', '。\n\n')),
            Divider(),
            detailItem(Icons.language, '連結', widget.rumors['url']),
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
                        style: const TextStyle(color: Colors.blue)),
                    onTap: () => launchURL(value),
                  )
                : Text(displayValue),
          ),
        ],
      ),
    );
  }
}
