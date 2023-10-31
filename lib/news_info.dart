import 'package:flutter/material.dart';
import 'data/dbhelper.dart';
import 'package:intl/intl.dart'; // 导入日期格式化的库

class NewsInfoPage extends StatefulWidget {
  final String title; // 接收所選列表的標題
  final int id; // 新增一個用於接收 ID 的參數

  const NewsInfoPage({required this.title, required this.id, super.key});

  @override
  State<NewsInfoPage> createState() => _NewsInfoPageState();
}

class _NewsInfoPageState extends State<NewsInfoPage> {
  late DatabaseHelper _databaseHelper; // 聲明資料庫助手實例

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper(createDatabaseConnection()); // 初始化資料庫助手
  }

  Future<List<Map<String, dynamic>>> fetchData() async {
    // 打開資料庫連接
    await _databaseHelper.openConnection();

    // 執行資料庫查詢，根據 widget.title 和 widget.id 進行過濾
    final data =
        await _databaseHelper.fetchNewsDataByTitle(widget.title, widget.id);

    // 關閉資料庫連接
    await _databaseHelper.closeConnection();

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(
            color: Colors.black,
          ),
        ), // 使用所選清單的標題作為頁面標題
        backgroundColor: Color(0xFF1179FA),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          } else {
            final data = snapshot.data;

            // 检查数据是否为空或为 null，并相应处理
            if (data == null || data.isEmpty) {
              return const Center(child: Text('No data available'));
            }

            return ListView.builder(
              itemCount: data!.length,
              itemBuilder: (context, index) {
                final title = data[index]['title'];
                final content = data[index]['content'];
                // 在从数据库获取的内容中插入换行符
                final content_typesetting = content.replaceAll(RegExp(r'\。'), '.\n\n');
                final url = data[index]['url'];
                final publishDate = data[index]['publish_date'];
                final permitDateFormat = DateFormat('yyyy-MM-dd');
                final formatpublishDate = permitDateFormat.format(publishDate);

                return Card(
                  color: Color.fromARGB(255, 183, 222, 248), // 添加顏色
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical:6.0), // 设置垂直内边距
                          child: Text(' $formatpublishDate',
                              style: const TextStyle(color: Colors.black87)),
                        ),

                        const Divider(height: 1, color: Colors.grey), // 添加分隔线

                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6.0), // 设置垂直内边距
                          child: Text(' $content_typesetting',
                              style: const TextStyle(color: Colors.black87),
                              textAlign: TextAlign.justify),
                              ),
                       

                        const Divider(height: 1, color: Colors.grey), // 添加分隔线

                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6.0), // 设置垂直内边距
                          child: Text(
                              url != null && url.isNotEmpty ? '$url' : '沒有連結',
                              style: const TextStyle(color: Colors.black87)),
                        ),
                      ],
                    ),
                    onTap: () {
                      // 點擊列表項的操作
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
