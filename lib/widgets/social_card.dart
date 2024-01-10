// PostCard.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../screen/social.dart';
import 'package:intl/intl.dart';

class PostCard extends StatelessWidget {
  final int id;
  final String title;
  final String content;
  final String email;
  final String username;
  final String created_time;
  final String updated_time;
  final Function onTap;
  final Function(int, bool) toggleFavoriteCallback;
  final Set<int> favoritePosts;

  const PostCard({
    required this.id,
    required this.title,
    required this.onTap,
    required this.content,
    required this.email,
    required this.username,
    required this.created_time,
    required this.updated_time,
    required this.toggleFavoriteCallback,
    required this.favoritePosts,
  });

  @override
  Widget build(BuildContext context) {
    String formattedCreatedTime = 'N/A';

    try {
      // final dateTime = DateTime.parse(created_time); 資料庫回傳是RFC 1123日期時間格式 無法直接套用intl套件
      final dateTime = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'", 'en_US').parse(created_time);
      formattedCreatedTime = DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
    } catch (e) {
      print('Error formatting created_time: $e');
    }
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 4,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: Colors.black,
          child: Text(
            username.isNotEmpty ? username[0].toUpperCase() : '?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '發文者: $username',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(content),
            const SizedBox(height: 4),
            Text(
              '發布時間: $formattedCreatedTime', // 使用格式化後的日期時間字符串
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            favoritePosts.contains(id) ? Icons.favorite : Icons.favorite_border,
            color: Colors.grey,
          ),
          onPressed: () async {
            // 在這裡處理點擊收藏按鈕的邏輯
            toggleFavoriteCallback(id, !favoritePosts.contains(id));
          },
        ),
        onTap: () => onTap(),
      ),
    );
  }
}
