import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test_app/screen/new_post.dart';
import 'dart:convert';

import 'package:test_app/widgets/social_card.dart';

class SocialPage extends StatefulWidget {
  const SocialPage({Key? key}) : super(key: key);

  @override
  State<SocialPage> createState() => _SocialPage();
}

class _SocialPage extends State<SocialPage> {
  Future<List<dynamic>>? posts;

  Future<List<Map<String, dynamic>>> fetchPosts() async {
    final response = await http.get(Uri.parse(
      'https://healnow.azurewebsites.net/posts',
    ));

  if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          json.decode(const Utf8Decoder().convert(response.bodyBytes));
      final List<dynamic> recipeList = data['data'];
      return recipeList.map((json) => json as Map<String, dynamic>).toList();
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
              child: FutureBuilder<List<dynamic>>(
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
                        var medication = snapshot.data![index];
                        return PostCard(
                          title: medication['title'],
                          content: medication['content'],
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => Container(),
                              )
                            );
                          }, 
                          id: 1, username: '振閔', email: '111360252ntub', created_time: '0000', updated_time: '1212',
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
        // 在這裡處理點擊發布貼文按鈕的操作
        // 可以彈出對話框或導航到發布貼文的頁面
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
