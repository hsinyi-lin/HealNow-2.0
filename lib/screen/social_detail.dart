import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:test_app/utils/token.dart';

class SocialDetailPage extends StatefulWidget {
  final int postId; // 貼文編號

  const SocialDetailPage({Key? key, required this.postId}) : super(key: key);

  @override
  State<SocialDetailPage> createState() => _SocialDetailPageState();
}

class _SocialDetailPageState extends State<SocialDetailPage> {
  late String token;
  bool? isFavorite;
  late Map<String, dynamic> postDetails = {};

  @override
  void initState() {
    super.initState();
    loadToken().then((loadedToken) {
      token = loadedToken;

      // 取得貼文詳細資訊的 API 請求
    Future<Map<String, dynamic>> fetchPostDetails(int postId, String token) async {
      final response = await http.get(
        Uri.parse('https://healnow.azurewebsites.net/posts/$postId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            json.decode(const Utf8Decoder().convert(response.bodyBytes));
        final Map<String, dynamic> postDetails = data['data'];
        return postDetails;
      } else {
        throw Exception('Failed to load post details');
      }
    }

      // 取得貼文詳細資訊
      fetchPostDetails(widget.postId, token).then((details) {
        setState(() {
          postDetails = details;
        });
      }).catchError((error) {
        print('Error fetching post details: $error');
      });

      // 取得收藏列表進行比對，以顯示收藏 icon 類型
      // 這部分的程式碼和之前的一樣
    });
  }
  


  
  @override
  Widget build(BuildContext context) {
    if (postDetails == null) {
      // 資訊還在載入中，顯示載入中的畫面
      return Scaffold(
        appBar: AppBar(
          title: Text('貼文詳細資訊'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      // 資訊已經載入完成，顯示貼文詳細資訊
      return Scaffold(
        appBar: AppBar(
          title: Text('貼文詳細資訊'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.account_circle, size: 20),
                    SizedBox(width: 8),
                    Text(
                      '發文者: ${postDetails['username']}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.title, size: 20),
                    SizedBox(width: 8),
                    Text(
                      '標題: ${postDetails['title']}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  '內文: ${postDetails['content']}',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.thumb_up),
                        SizedBox(width: 8),
                        Text('點讚數: ${postDetails['like_count']}'),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.remove_red_eye),
                        SizedBox(width: 8),
                        Text('觀看次數: ${postDetails['view_count']}'),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text('留言區:'),
                // 這裡你可以顯示留言區的內容
                // 你可能需要再次發送 API 請求來獲取留言列表
              ],
            ),
          ),
        ),
      );
    }
  }
}
