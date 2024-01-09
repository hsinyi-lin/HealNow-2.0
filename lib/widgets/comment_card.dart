// CommentCard.dart

import 'package:flutter/material.dart';

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
            child: Text(
              content,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 12),
            child: Text(
              '回覆更新時間: $updatedTime',
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
