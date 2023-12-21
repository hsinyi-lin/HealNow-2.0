import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatDateString(String dateString) {
  DateFormat inputFormat = DateFormat('EEE, dd MMM yyyy HH:mm:ss \'GMT\'');
  DateTime dateTime = inputFormat.parse(dateString, true).toLocal();
  String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
  return formattedDate;
}

class MedicationDetailPage extends StatelessWidget {
  final Map<String, dynamic> medication;

  MedicationDetailPage({Key? key, required this.medication}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          medication['med_tw_name'],
          style: TextStyle(color: Colors.black), 
        ),
        iconTheme: IconThemeData(color: Colors.black), 
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.bookmark_add), // 收藏图标
            onPressed: () {
              // 这里添加点击收藏图标后的行为
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            detailItem(Icons.language, '英文名稱', medication['med_en_name']),
            Divider(),
            detailItem(Icons.factory, '製造商', medication['manufacturer']),
            Divider(),
            detailItem(Icons.flag, '製造商國家', medication['manufacturer_country']),
            Divider(),
            detailItem(Icons.category, '藥品類型', medication['med_type']),
            Divider(),
            detailItem(Icons.account_circle, '申請人', medication['applicant_name']),
            Divider(),
            detailItem(Icons.home_work, '申請人地址', medication['applicant_address']),
            Divider(),
            detailItem(Icons.format_list_bulleted, '成分', medication['composition']),
            Divider(),
            detailItem(Icons.healing, '使用方法', medication['how_to_use']),
            Divider(),
            detailItem(Icons.check_circle_outline, '適應症', medication['indications']),
            Divider(),
            detailItem(Icons.confirmation_num, '許可證號', medication['permit_num']),
            Divider(),
            detailItem(Icons.card_membership, '許可證類型', medication['permit_type']),
            Divider(),
            detailItem(Icons.calendar_today, '許可日期', formatDateString(medication['permit_date'])),
            Divider(),
            detailItem(Icons.edit, '編輯日期', formatDateString(medication['edit_date'])),
            Divider(),
            detailItem(Icons.date_range, '到期日期', formatDateString(medication['expiration_date'])),
          ],
        ),
      ),
    );
  }

  Widget detailItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          SizedBox(height: 4), 
          Padding(
            padding: const EdgeInsets.only(left: 32.0), 
            child: Text(value),
          ),
        ],
      ),
    );
  }
}