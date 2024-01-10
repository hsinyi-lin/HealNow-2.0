// import 'package:flutter/material.dart';
// import 'package:test_app/screen/social_detail.dart';
// import 'package:test_app/widgets/social_card.dart';
// import '../config/config.dart';
// import '../utils/token.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class CollectPostPage extends StatefulWidget {
//   const CollectPostPage({Key? key}) : super(key: key);

//   @override
//   State<CollectPostPage> createState() => _CollectPostPage();
// }

// class _CollectPostPage extends State<CollectPostPage> {
//   Future<List<Map<String, dynamic>>>? posts;
//   late String token;
//   List<dynamic> allPosts = []; // 用於儲存所有資料
//   List<dynamic> filteredPosts = []; // 用於儲存過濾後的資料
//   Set<int> collectFavoritePosts = Set<int>();

//   // 自定義方法：取得收藏列表
//   Future<Set<int>> fetchFavoritePosts(String token) async {
//     final response = await http.get(
//       Uri.parse('https://healnow.azurewebsites.net/saves'),
//       headers: {'Authorization': 'Bearer $token'},
//     );

//     if (response.statusCode == 200) {
//       final List<dynamic> data = json.decode(response.body)['data'];
//       return data.map<int>((post) => post['post_id']).toSet();
//     } else {
//       throw Exception('Failed to load saved posts');
//     }
//   }

//   // 切換收藏狀態的方法
//   Future<void> toggleFavoriteStatus(int postId, bool isFavorite) async {
//     final url = Uri.parse('https://healnow.azurewebsites.net/saves/$postId');

//     http.Response response;
//     if (isFavorite) {
//       response = await http.delete(
//         url,
//         headers: {'Authorization': 'Bearer $token'},
//       );
//     } else {
//       response = await http.post(
//         url,
//         headers: {'Authorization': 'Bearer $token'},
//       );
//     }

//     if (response.statusCode != 200) {
//       throw Exception('Error updating favorite status');
//     }
//   }

//   Future<List<Map<String, dynamic>>> fetchSavedPostsList(String token) async {
//     final response = await http.get(
//       Uri.parse('${AppConfig.baseURL}/saves'),
//       headers: {'Authorization': 'Bearer $token'},
//     );

//     if (response.statusCode == 200) {
//       final List<dynamic> data = json.decode(response.body)['data'];
//       return data.map((json) => json as Map<String, dynamic>).toList();
//     } else {
//       throw Exception('Failed to load saved list');
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     loadToken().then((loadedToken) {
//       token = loadedToken;
//       setState(() {
//         posts = fetchSavedPostsList(token).then((postsList) {
//           allPosts = postsList;
//           allPosts = postsList;
//           filteredPosts = postsList;
//           return postsList;
//         });
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0),
//         child: Column(
//           children: <Widget>[
//             Expanded(
//               child: FutureBuilder<List<dynamic>>(
//                 future: posts,
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(child: CircularProgressIndicator());
//                   } else if (snapshot.hasError) {
//                     return Text('Error: ${snapshot.error}');
//                   } else if (snapshot.data == null || snapshot.data!.isEmpty) {
//                     return const Center(child: Text('沒有收藏'));
//                   } else {
//                     return ListView.separated(
//                       itemCount: snapshot.data!.length,
//                       separatorBuilder: (context, index) => const Divider(),
//                       itemBuilder: (context, index) {
//                         var post = snapshot.data![index];
//                         if (post != null) {
//                           return PostCard(
//                             favoritePosts: collectFavoritePosts, // 添加 favoritePosts
//                             toggleFavoriteCallback:
//                                 (int postId, bool isFavorite) async {
//                               await toggleFavoriteStatus(postId, isFavorite);
//                             },
//                             title: post['title'],
//                             content: post['content'],
//                             onTap: () {
//                               // 當用戶點擊貼文時，將貼文的 id 傳遞到 SocialDetailPage
//                               Navigator.of(context).push(
//                                 MaterialPageRoute(
//                                   builder: (context) =>
//                                       SocialDetailPage(postId: post['id']),
//                                 ),
//                               );
//                             },
//                             id: post['id'] ?? 0,
//                             username: post['username'] ?? '',
//                             email: post['email'] ?? '',
//                             created_time: post['created_time'] ?? '',
//                             updated_time: post['updated_time'] ?? '',
//                           );
//                         } else {
//                           // 如果 post 為 null，你可以返回一個空的 widget 或者其他處理邏輯
//                           return Container();
//                         }
//                       },
//                     );
//                   }
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
