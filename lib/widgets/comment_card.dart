import 'package:flutter/material.dart';
import 'dart:math';

class CommentCard extends StatelessWidget {
  final int id;
  // final int post_id;
  final String content;
  final String created_time	;
  final String updated_time;

  const CommentCard({
    required this.id,
    // required this.post_id,
    required this.content,
    required this.created_time,
    required this.updated_time,
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
              '回覆更新時間: $updated_time',
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
