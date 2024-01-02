import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:test_app/screen/new_post.dart';
import 'package:test_app/screen/social_detail.dart';
import 'package:test_app/widgets/social_card.dart';

class SocialPage extends StatefulWidget {
  const SocialPage({Key? key}) : super(key: key);

  @override
  State<SocialPage> createState() => _SocialPage();
}

class _SocialPage extends State<SocialPage> {
  Future<List<Map<String, dynamic>>>? posts;

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

  @override
  void initState() {
    super.initState();
    posts = fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 20),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewPostScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
