import 'package:flutter/material.dart';
import 'data/dbhelper.dart';
import 'package:intl/intl.dart'; // 導入日期格式化的庫

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
        title: const Text(
          "內容",
          style: TextStyle(
            color: Colors.black,
          ),
        ), 
        backgroundColor: const Color(0xFF1179FA),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {//檢查非同步作業是否仍在等待中，如果是，則顯示載入進度條。
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {//檢查是否有錯誤發生，如果是，則顯示錯誤消息。
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {//檢查是否有資料可用，如果沒有，則顯示"無可用資料"的消息。
            return const Center(child: Text('No data available'));
          } else {
            final data = snapshot.data;//如果非同步作業成功並且有資料可用，那麼可以通過 snapshot.data 訪問返回的資料。
            // 檢查資料是否為空或為 null，並相應處理
            if (data == null || data.isEmpty) {
              return const Center(child: Text('No data available'));
            }

            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final title = data[index]['title'];////從data中提取並儲存特定名稱
                final content = data[index]['content'];
                // 在從資料庫獲取的內容中插入分行符號
                final contentTypesetting =
                    content.replaceAll(RegExp(r'\。'), '.\n\n');
                final url = data[index]['url'];
                final publishDate = data[index]['publish_date'];
                final permitDateFormat = DateFormat('yyyy-MM-dd');
                final formatpublishDate = permitDateFormat.format(publishDate);

                return Container(
                  margin: const EdgeInsets.all(15),
                  child: ListTile(
                    title: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6.0), // 設置垂直內邊距
                          child: Text(' $formatpublishDate',
                              style: const TextStyle(
                                  color: Colors.black87, fontSize: 20)),
                        ),

                        const Divider(height: 1, color: Colors.grey), // 添加分隔線

                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6.0), // 設置垂直內邊距
                          child: Text(' $contentTypesetting',
                              style: const TextStyle(
                                  color: Colors.black87, fontSize: 20),
                              textAlign: TextAlign.justify),
                        ),

                        const Divider(height: 1, color: Colors.grey), // 添加分隔線

                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6.0), // 設置垂直內邊距
                          child: Text(
                              url != null && url.isNotEmpty ? '$url' : '沒有連結',
                              style: const TextStyle(
                                  color: Colors.black87, fontSize: 20)),
                        ),
                      ],
                    ),
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
