// SocialDetailPage.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  bool? isLike;
  late Map<String, dynamic> postDetails = {};
  late List<dynamic> comments = []; // 新增 comments 變數
  late TextEditingController commentController;
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    commentController = TextEditingController();
    loadToken().then((loadedToken) {
      token = loadedToken;

      // 取得貼文詳細資訊的 API 請求
      fetchPostDetails(widget.postId).then((details) {
        setState(() {
          postDetails = details;
          // 初始化按讚狀態和留言數
          isLiked = details['is_liked'] as bool? ?? false;
          postDetails['like_cnt'] = details['like_cnt'] as int? ?? 0;
          // 將留言列表放入 comments 變數中
          comments = details['comment'] ?? [];
        });
      }).catchError((error) {
        print('Error fetching post details: $error');
      });

      fetchSavedPosts(token).then((savedPosts) {
        setState(() {
          isFavorite = savedPosts
              .any((savedPost) => savedPost['post_id'] == widget.postId);
          print(isFavorite);
          print(widget.postId);
        });
      }).catchError((error) {
        print('Error fetching saved medications: $error');
      });

      fetchLikedPosts(token).then((likedPosts) {
        setState(() {
          isLike = likedPosts
              .any((likedPost) => likedPost['post_id'] == widget.postId);
          print(isLike);
          print('---------');
          print(widget.postId);
        });
      }).catchError((error) {
        print('Error fetching saved medications: $error');
      });
    });
  }

  // 收藏狀態
  Future<void> toggleFavoriteStatus_1() async {
    try {
      bool currentFavoriteStatus = isFavorite ?? false;
      await toggleFavoriteStatus_2(token, widget.postId, currentFavoriteStatus);

      setState(() {
        isFavorite = !currentFavoriteStatus;
        // 更新收藏次數
        if (isFavorite!) {
          postDetails['saved_cnt'] = (postDetails['saved_cnt'] ?? 0) + 1;
        } else {
          postDetails['saved_cnt'] = (postDetails['saved_cnt'] ?? 0) - 1;
        }
      });
    } catch (error) {
      print('Error updating favorite status 1: $error');
    }
  }

  // 使用於收藏
  Future<void> toggleFavoriteStatus_2(
      String token, int postId, bool isFavorite) async {
    final url = Uri.parse('https://healnow.azurewebsites.net/saves/$postId');

    http.Response response;
    if (isFavorite) {
      response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
    } else {
      response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
    }

    if (response.statusCode != 200) {
      print(response.statusCode);
      throw Exception('Error updating favorite status 2');
    }
  }

  // 按讚狀態
  Future<void> toggleFavoriteStatus_3() async {
    try {
      bool currentFavoriteStatus = isLike ?? false;
      await toggleFavoriteStatus_4(token, widget.postId, currentFavoriteStatus);

      setState(() {
        isLike = !currentFavoriteStatus;
        // 更新收藏次數
        if (isLike!) {
          postDetails['like_cnt'] = (postDetails['like_cnt'] ?? 0) + 1;
        } else {
          postDetails['like_cnt'] = (postDetails['like_cnt'] ?? 0) - 1;
        }
      });
    } catch (error) {
      print('Error updating favorite status 3: $error');
    }
  }

  // 使用於按讚、取消讚
  Future<void> toggleFavoriteStatus_4(
      String token, int postId, bool isFavorite) async {
    final url =
        Uri.parse('https://healnow.azurewebsites.net/posts/like/$postId');

    http.Response response;
    if (isFavorite) {
      response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
    } else {
      print('post');
      response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
    }

    if (response.statusCode != 200) {
      print(response.statusCode);
      throw Exception('Error updating favorite status 4');
    }
  }

  // 取得收藏貼文列表的 API 請求
  Future<List<Map<String, dynamic>>> fetchSavedPosts(String token) async {
    final response = await http.get(
      Uri.parse('https://healnow.azurewebsites.net/saves'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((json) => json as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load saved list');
    }
  }

  // 取得按讚貼文列表的 API 請求
  Future<List<Map<String, dynamic>>> fetchLikedPosts(String token) async {
    final response = await http.get(
      Uri.parse('https://healnow.azurewebsites.net/posts/like'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      print(data.map((json) => json as Map<String, dynamic>).toList());
      return data.map((json) => json as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load saved list');
    }
  }

// 新增取得按讚數的 API 請求
  Future<int> fetchLikeCount(int postId, String token) async {
    final response = await http.get(
      Uri.parse('https://healnow.azurewebsites.net/posts/like/count/$postId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          json.decode(const Utf8Decoder().convert(response.bodyBytes));
      return data['like_count'];
    } else {
      throw Exception('Failed to load like count');
    }
  }

  // 取得貼文詳細資訊的 API 請求
  Future<Map<String, dynamic>> fetchPostDetails(int postId) async {
    final response = await http
        .get(Uri.parse('https://healnow.azurewebsites.net/posts/$postId'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          json.decode(const Utf8Decoder().convert(response.bodyBytes));
      final Map<String, dynamic> postDetails = data['data'];
      // print(postDetails);
      return postDetails;
    } else {
      throw Exception('Failed to load post details');
    }
  }

// 新增留言的 API 請求
  Future<void> addComment(int postId, String token, String content) async {
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
    if (postDetails.isEmpty) {
      // 資訊還在載入中，顯示載入中的畫面
      return Scaffold(
        appBar: AppBar(
          title: Text('貼文詳細資訊'),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.black, Colors.white], // 自行調整顏色
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes the direction of the shadow
                ),
              ],
            ),
          ),
        ),
        body: Center(
          child: CircularProgressIndicator(
            backgroundColor: Colors.grey.withOpacity(0.5),
            color: Colors.black,
          ),
        ),
      );
    } else {
      // 資訊已經載入完成，顯示貼文詳細資訊
      return Scaffold(
        appBar: AppBar(
          title: Text('貼文詳細資訊'),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.black, Colors.white], // 自行調整顏色
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes the direction of the shadow
                ),
              ],
            ),
          ),
        ),
        body: SingleChildScrollView(
          // 加入 SingleChildScrollView
          child: Padding(
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
                  // 貼文發布者
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      IconButton(
                        icon: Icon(isFavorite == true
                            ? Icons.bookmark
                            : Icons.bookmark_border),
                        onPressed: toggleFavoriteStatus_1,
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // 貼文標題
                  Row(
                    children: [
                      Icon(Icons.title, size: 20),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '標題: ${postDetails['title']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                          softWrap: true, // 允許換行
                          overflow: TextOverflow.visible, // 可見的部分不被裁剪
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
// 貼文內文
                  Text(
                    '內文: ${postDetails['content']}',
                    style: TextStyle(fontSize: 18),
                    softWrap: true, // 允許換行
                    overflow: TextOverflow.visible, // ˊ可見的部分不被裁剪
                  ),
                  SizedBox(height: 20),
                  // 貼文點讚數和觀看次數
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(isLike == true
                                ? Icons.thumb_up
                                : Icons.thumb_up_outlined),
                            onPressed: toggleFavoriteStatus_3,
                          ),
                          SizedBox(width: 8),
                          Text('點讚數: ${postDetails['like_cnt']}'),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.remove_red_eye),
                          SizedBox(width: 8),
                          Text('收藏次數: ${postDetails['saved_cnt']}'),
                        ],
                      ),
                    ],
                  ),
                  // 分隔線
                  Container(
                    color: Colors.black,
                    height: 1,
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
                    //新增留言邏輯
                    onPressed: () async {
                      String content = commentController.text;

                      // 檢查是否輸入了留言內容
                      if (content.isNotEmpty) {
                        // 調用新增留言的 API
                        try {
                          await addComment(widget.postId, token, content);

                          // 重新獲取貼文資訊
                          fetchPostDetails(widget.postId).then((details) {
                            setState(() {
                              postDetails = details;
                              comments = details['comment'] ?? [];
                            });
                          });

                          // 清空留言輸入框
                          commentController.clear();
                        } catch (error) {
                          print('Error adding comment: $error');
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(primary: Colors.black),
                    child: Text('留言'),
                  ),
                  SizedBox(height: 20),
                  // 留言列表
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      // print('-----------------');
                      // print(comment);

                      return CommentCard(
                        id: comment['id'],
                        username: comment['username'],
                        email: comment['email'],
                        content: comment['content'],
                        createdTime: comment['created_time'],
                        updatedTime: comment['updated_time'],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}
