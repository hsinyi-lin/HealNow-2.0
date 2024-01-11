import 'package:flutter/material.dart';
import 'package:test_app/screen/social_detail.dart';
import 'package:test_app/widgets/social_card.dart';
import '../config/config.dart';
import '../utils/token.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:test_app/screen/new_post.dart';

class CollectPostPage extends StatefulWidget {
  const CollectPostPage({Key? key}) : super(key: key);

  @override
  State<CollectPostPage> createState() => _CollectPostPage();
}

class _CollectPostPage extends State<CollectPostPage> {
  Future<List<Map<String, dynamic>>>? posts;
  List<dynamic> allPosts = [];
  List<dynamic> filteredPosts = [];
  String searchQuery = '';
  late String token;
  // 初始化狀態
  @override
  void initState() {
    super.initState();
    loadToken().then((loadedToken) {
      token = loadedToken;

      setState(() {
        posts = fetchSavedPosts(token).then((postList) {
          allPosts = postList;
          filteredPosts = postList;
          print(postList);
          return postList;
          
        });
      });
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: posts,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    // Proceed with your ListView
                    return ListView.separated(
                      itemCount: filteredPosts.length,
                      separatorBuilder: (context, index) => Divider(),
                      itemBuilder: (context, index) {
                        var post = filteredPosts[index];
                        print(post['post_id']);
                        return PostCard(
                          title: post['title'],
                          content: post['content'],
                          onTap: () {
                            print("Post ${post['post_id']} clicked");
                            // 當用戶點擊貼文時，將貼文的 id 傳遞到 SocialDetailPage
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    SocialDetailPage(postId: post['post_id']),
                              ),
                            );
                          },
                          id: post['post_id'],
                          username: post['username'],
                          email: post['email'],
                          created_time: post['created_time'],
                          updated_time: post['updated_time'],
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
