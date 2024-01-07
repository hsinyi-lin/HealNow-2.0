import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:test_app/utils/token.dart';
import 'package:test_app/widgets/comment_card.dart';

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
  late List<Map<String, dynamic>> comments = []; // 修正為 List
  late TextEditingController commentController;

  @override
  void initState() {
    super.initState();
    commentController = TextEditingController();
    loadToken().then((loadedToken) {
      token = loadedToken;

      // 取得留言列表的 API 請求
      Future<Map<String, dynamic>> fetchComments(
          int postId, String token) async {
        final response = await http.get(
          Uri.parse('https://healnow.azurewebsites.net/posts/$postId'),
          // headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> data =
              json.decode(const Utf8Decoder().convert(response.bodyBytes));
          // return List<Map<String, dynamic>>.from(
          //     data.map((comment) => comment['data']));
          //     // final Map<String, dynamic> comment = comment ['data']
            final Map<String, dynamic> comments = data ['data'];
            return comments;
        } else {
          throw Exception('Failed to load comments');
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

      // // 取得留言列表
      // fetchComments(widget.postId, token).then((commentList) {
      //   setState(() {
      //     comments = commentList;
      //   });
      // }).catchError((error) {
      //   print('Error fetching comments: $error');
      // });
    });
  }

      // 取得貼文詳細資訊的 API 請求
    Future<Map<String, dynamic>> fetchPostDetails(
        int postId, String token) async {
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

      // 新增留言的 API 請求
    Future<bool> addComment(int postId, String token, String content) async {
      final response = await http.post(
        Uri.parse('https://healnow.azurewebsites.net/comments/$postId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'content': content}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['status'];
      } else {
        throw Exception('Failed to add comment');
      }
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
                Container(
                  color: Colors.black, // 在這裡設置分隔線的背景顏色
                  height: 1, // 分隔線的高度
                ),
                SizedBox(height: 20),
                // 留言區
                Text('留言區:'),
                // TextField 用於輸入留言內容
                TextField(
                  controller: commentController,
                  decoration: InputDecoration(
                    hintText: '輸入留言...',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                // ElevatedButton 用於提交留言


                ElevatedButton(
                  onPressed: () async {
                    if (commentController.text.isNotEmpty) {
                      bool status = await addComment(
                          widget.postId, token, commentController.text);
                      if (status) {
                        // 如果留言成功，重新載入留言列表
                        Future<void> fetchComments(
                            int postId, String token) async {
                          final response = await http.get(
                            Uri.parse(
                                'https://healnow.azurewebsites.net/posts/$postId'),
                            headers: {'Authorization': 'Bearer $token'},
                          );

                          if (response.statusCode == 200) {
                            final List<dynamic> data = json.decode(
                                const Utf8Decoder()
                                    .convert(response.bodyBytes));
                            setState(() {
                              comments = List<Map<String, dynamic>>.from(
                                  data.map((comment) => comment['data']));
                            });
                          } else {
                            throw Exception('Failed to load comments');
                          }
                        }

                        // 清空輸入框
                        commentController.clear();
                      } else {
                        // 留言失敗的處理
                        print('Failed to add comment');
                      }
                    }
                  },
                  child: Text('留言'),
                ),
                SizedBox(height: 20),
                
                // 顯示留言區的內容
                for (var comment in comments)
                  CommentCard(
                    id: comment['id'],
                    // post_id: comment['post_id'],
                    content: comment['content'],
                    created_time: comment['created_time'],
                    updated_time: comment['updated_time'],
                  ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
