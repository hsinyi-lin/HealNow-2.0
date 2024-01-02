import 'package:flutter/material.dart';
import 'dart:math';

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
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8), // 調整垂直和水平間距
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), // 設置圓角半徑
      ),
      elevation: 4, // 添加陰影效果
      child: ListTile(
        contentPadding: const EdgeInsets.all(12), // 調整內容填充
        leading: CircleAvatar(
          backgroundColor: Colors.black, // 設置圓形頭像的背景色
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(content),
        onTap: () => onTap(),
      ),
    );
  }
}
