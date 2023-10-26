import 'package:flutter/material.dart';
import 'data/dbhelper.dart';
import 'package:intl/intl.dart'; // 导入日期格式化的库

class MedPage extends StatefulWidget {
  final String title; // 接收所選列表的標題

  MedPage({required this.title, Key? key}) : super(key: key);

  @override
  State<MedPage> createState() => _MedPageState();
}

class _MedPageState extends State<MedPage> {
  late DatabaseHelper _databaseHelper; // 聲明資料庫助手實例

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper(createDatabaseConnection()); // 初始化資料庫助手
  }

  Future<List<Map<String, dynamic>>> fetchData() async {
    // 打開資料庫連接
    await _databaseHelper.openConnection();

    // 執行資料庫查詢，根據 widget.title 進行過濾
    final data = await _databaseHelper.fetchMedDataByTitle(widget.title);

    // 關閉資料庫連接
    await _databaseHelper.closeConnection();

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title), // 使用所選清單的標題作為頁面標題
      ),
      body: FutureBuilder(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available'));
          } else {
            final data = snapshot.data;

            return ListView.builder(
              itemCount: data!.length,
              itemBuilder: (context, index) {
                final med_tw_name = data[index]['med_tw_name'];
                final med_en_name = data[index]['med_en_name'];
                final med_type = data[index]['med_type'];
                final composition = data[index]['composition'];
                final indications = data[index]['indications'];
                final how_to_use = data[index]['how_to_use'];
                final permit_num = data[index]['permit_num'];
                final permit_type = data[index]['permit_type'];
                // 获取从数据库中获取的 DateTime 对象
                final permit_date = data[index]['permit_date'];
                final expiration_date = data[index]['expiration_date'];

                // 将 DateTime 对象格式化为字符串
                final permitDateFormat = DateFormat('yyyy-MM-dd');
                final formatpermit_date = permitDateFormat.format(permit_date);
                final formatexpiration_date =
                    permitDateFormat.format(expiration_date);

                return Card(
                  color: Colors.blue[50], // 添加顏色
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(
                      med_tw_name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0), // 设置垂直内边距
                          child: Text('英文名: $med_en_name',
                              style: TextStyle(color: Colors.black87)),
                        ),

                        Divider(height: 1, color: Colors.grey), // 添加分隔线

                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0), // 设置垂直内边距
                          child: Text('類型: $med_type',
                              style: TextStyle(color: Colors.black87)),
                        ),

                        Divider(height: 1, color: Colors.grey), // 添加分隔线

                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0), // 设置垂直内边距
                          child: Text('成分: $composition',
                              style: TextStyle(color: Colors.black87)),
                        ),

                        Divider(height: 1, color: Colors.grey), // 添加分隔线

                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0), // 设置垂直内边距
                          child: Text('適應症: $indications',
                              style: TextStyle(color: Colors.black87)),
                        ),

                        Divider(height: 1, color: Colors.grey), // 添加分隔线

                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0), // 设置垂直内边距
                          child: Text('使用方法: $how_to_use',
                              style: TextStyle(color: Colors.black87)),
                        ),

                        Divider(height: 1, color: Colors.grey), // 添加分隔线

                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0), // 设置垂直内边距
                          child: Text('批准號: $permit_num',
                              style: TextStyle(color: Colors.black87)),
                        ),

                        Divider(height: 1, color: Colors.grey), // 添加分隔线

                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0), // 设置垂直内边距
                          child: Text('批准類型: $permit_type',
                              style: TextStyle(color: Colors.black87)),
                        ),

                        Divider(height: 1, color: Colors.grey), // 添加分隔线

                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0), // 设置垂直内边距
                          child: Text('批准日期: $formatpermit_date',
                              style: TextStyle(color: Colors.black87)),
                        ),

                        Divider(height: 1, color: Colors.grey), // 添加分隔线
                        
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0), // 设置垂直内边距
                          child: Text('過期日期: $formatexpiration_date',
                              style: TextStyle(color: Colors.black87)),
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
