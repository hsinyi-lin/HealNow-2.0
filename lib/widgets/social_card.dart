// PostCard.dart

import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final int id;
  final String title;
  final String content;
  final String email;
  final String username;
  final String created_time;
  final String updated_time;
  final Function onTap;

  const PostCard({
    required this.id,
    required this.title,
    required this.onTap,
    required this.content,
    required this.email,
    required this.username,
    required this.created_time,
    required this.updated_time,
  });

  @override
  Widget build(BuildContext context) {
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
              '發布時間: $created_time', // 使用格式化後的日期時間字符串
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        onTap: () => onTap(), // 添加 onTap 處理
      ),
    );
  }
}