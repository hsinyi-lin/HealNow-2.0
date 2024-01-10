// CommentCard.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CommentCard extends StatelessWidget {
  final int id;
  final String username;
  final String email;
  final String content;
  final String createdTime;
  final String updatedTime;

  const CommentCard({
    required this.id,
    required this.username,
    required this.email,
    required this.content,
    required this.createdTime,
    required this.updatedTime,
  });

  @override
  Widget build(BuildContext context) {
    String formattedUpadteTime = 'N/A';

    final dateTime = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'", 'en_US').parse(updatedTime);
    formattedUpadteTime = DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '用戶名: $username',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  content,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 12),
            child: Text(
              '回覆更新時間: $formattedUpadteTime',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
