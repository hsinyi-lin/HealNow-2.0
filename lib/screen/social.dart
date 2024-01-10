import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:test_app/screen/new_post.dart';
import 'package:test_app/screen/social_detail.dart';
import 'package:test_app/services/opendata_service.dart';
import 'package:test_app/utils/token.dart';
import 'package:test_app/widgets/social_card.dart';

class SocialPage extends StatefulWidget {
  const SocialPage({Key? key}) : super(key: key);

  @override
  State<SocialPage> createState() => _SocialPage();
}

class _SocialPage extends State<SocialPage> {
  Future<List<Map<String, dynamic>>>? posts;
  late String token;
  Set<int> favoritePosts = Set<int>();

  // 自定義方法：取得收藏列表
  Future<Set<int>> fetchFavoritePosts(String token) async {
    final response = await http.get(
      Uri.parse('https://healnow.azurewebsites.net/saves'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map<int>((post) => post['id']).toSet();
    } else {
      throw Exception('Failed to load saved posts');
    }
  }

  // 切換收藏狀態的方法
  void toggleFavoriteStatus(int postId) async {
    try {
      await OpenDataService().toggleFavoriteStatus(
          token, 1, postId, favoritePosts.contains(postId));
      setState(() {
        if (favoritePosts.contains(postId)) {
          favoritePosts.remove(postId);
        } else {
          favoritePosts.add(postId);
        }
      });
    } catch (error) {
      print('Error updating favorite status: $error');
    }
  }

  // 非同步函數：發送 API 請求取得貼文列表
  Future<List<Map<String, dynamic>>> fetchPosts() async {
    final response = await http.get(Uri.parse(
      'https://healnow.azurewebsites.net/posts',
    ));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          json.decode(const Utf8Decoder().convert(response.bodyBytes));
      final List<dynamic> postList = data['data'];
      return postList.map((json) => json as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }

  // 初始化狀態
  @override
  void initState() {
    super.initState();
    posts = fetchPosts(); // 在初始化時取得貼文列表
    loadToken().then((loadedToken) {
      token = loadedToken; // 在 Future 完成後設置 token

      // 使用自定義方法取得收藏列表進行比對，以顯示收藏 icon 類型
      fetchFavoritePosts(token).then((savedPosts) {
        setState(() {
          favoritePosts = savedPosts;
        });
      }).catchError((error) {
        print('Error fetching saved posts: $error');
      });
    });
  }

  // 刷新貼文的函數
  Future<void> _refreshPosts() async {
    setState(() {
      posts = fetchPosts(); // 重新獲取貼文列表
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
            // 搜尋框
            TextField(
              decoration: InputDecoration(
                hintText: '名稱',
                prefixIcon: const Icon(Icons.search),
                contentPadding: EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(30.0),
                ),
                filled: true,
                fillColor: Color.fromARGB(255, 234, 234, 234),
              ),
            ),
            const SizedBox(height: 20),
            // 貼文列表
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: posts,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return ListView.separated(
                      itemCount: snapshot.data!.length,
                      separatorBuilder: (context, index) => Divider(),
                      itemBuilder: (context, index) {
                        var post = snapshot.data![index];
                        return PostCard(
                          favoritePosts: favoritePosts,
                          toggleFavoriteCallback: toggleFavoriteStatus,
                          title: post['title'],
                          content: post['content'],
                          onTap: () {
                            // 當用戶點擊貼文時，將貼文的 id 傳遞到 SocialDetailPage
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    SocialDetailPage(postId: post['id']),
                              ),
                            );
                          },
                          id: post['id'],
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
      // 新增貼文按鈕
      floatingActionButton: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  NewPostScreen(refreshCallback: _refreshPosts),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          backgroundColor: Colors.black, // 設定按鈕背景顏色
        ),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add,
                color: Colors.white, // 設定圖示顏色
              ),
            ],
          ),
        ),
      ),
    );
  }
}
