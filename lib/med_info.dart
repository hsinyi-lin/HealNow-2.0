import 'package:flutter/material.dart';
import 'data/dbhelper.dart';
import 'package:intl/intl.dart'; // 导入日期格式化的库

class MedPage extends StatefulWidget {
  final String title; // 接收所選列表的標題
  final int id; // 新增一個用於接收 ID 的參數

  const MedPage({required this.title, required this.id, super.key});

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

    // 執行資料庫查詢，根據 widget.title 和 widget.id 進行過濾
    final data =
        await _databaseHelper.fetchMedDataByTitle(widget.title, widget.id);

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
          style: const TextStyle(
            color: Colors.black,
          ),
        ), // 使用所選清單的標題作為頁面標題
        backgroundColor: const Color(0xFF00FAE5),
        iconTheme: const IconThemeData(color: Colors.black),
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
                final medTwName = data[index]['med_tw_name'];
                final medEnName = data[index]['med_en_name'];
                final medType = data[index]['med_type'];
                final composition = data[index]['composition'];
                final indications = data[index]['indications'];
                final howToUse = data[index]['how_to_use'];
                final permitNum = data[index]['permit_num'];
                final permitType = data[index]['permit_type'];
                // 获取从数据库中获取的 DateTime 对象
                final permitDate = data[index]['permit_date'];
                final expirationDate = data[index]['expiration_date'];

                // 将 DateTime 对象格式化为字符串
                final permitDateFormat = DateFormat('yyyy-MM-dd');
                final formatpermitDate = permitDateFormat.format(permitDate);
                final formatExpirationDate =
                    permitDateFormat.format(expirationDate);

                return Card(
                  color: const Color.fromARGB(255, 179, 255, 249), // 添加顏色
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(
                      medTwName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6.0), // 设置垂直内边距
                          child: Text('英文名: $medEnName',
                              style: const TextStyle(color: Colors.black87)),
                        ),

                        const Divider(height: 1, color: Colors.grey), // 添加分隔线

                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6.0), // 设置垂直内边距
                          child: Text('類型: $medType',
                              style: const TextStyle(color: Colors.black87)),
                        ),

                        const Divider(height: 1, color: Colors.grey), // 添加分隔线

                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6.0), // 设置垂直内边距
                          child: Text('成分: $composition',
                              style: const TextStyle(color: Colors.black87)),
                        ),

                        const Divider(height: 1, color: Colors.grey), // 添加分隔线

                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6.0), // 设置垂直内边距
                          child: Text('適應症: $indications',
                              style: const TextStyle(color: Colors.black87)),
                        ),

                        const Divider(height: 1, color: Colors.grey), // 添加分隔线

                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6.0), // 设置垂直内边距
                          child: Text('使用方法: $howToUse',
                              style: const TextStyle(color: Colors.black87)),
                        ),

                        const Divider(height: 1, color: Colors.grey), // 添加分隔线

                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6.0), // 设置垂直内边距
                          child: Text('批准號: $permitNum',
                              style: const TextStyle(color: Colors.black87)),
                        ),

                        const Divider(height: 1, color: Colors.grey), // 添加分隔线

                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6.0), // 设置垂直内边距
                          child: Text('批准類型: $permitType',
                              style: const TextStyle(color: Colors.black87)),
                        ),

                        const Divider(height: 1, color: Colors.grey), // 添加分隔线

                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6.0), // 设置垂直内边距
                          child: Text('批准日期: $formatpermitDate',
                              style: const TextStyle(color: Colors.black87)),
                        ),

                        const Divider(height: 1, color: Colors.grey), // 添加分隔线

                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6.0), // 设置垂直内边距
                          child: Text('過期日期: $formatExpirationDate',
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
