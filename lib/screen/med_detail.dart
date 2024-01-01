import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/opendata_services.dart';

class MedicationDetailPage extends StatefulWidget {
  final Map<String, dynamic> medication;

  const MedicationDetailPage({Key? key, required this.medication})
      : super(key: key);

  @override
  State<MedicationDetailPage> createState() => _MedicationDetailPageState();
}

class _MedicationDetailPageState extends State<MedicationDetailPage> {
  late String token;
  bool? isFavorite;

  @override
  void initState() {
    super.initState();
    loadToken().then((loadedToken) {
      token = loadedToken; // 在 Future 完成後設置 token

      // 取得收藏列表進行比對，以顯示收藏 icon 類型
      OpenDataService().fetchSavedClassList(token, 1).then((savedMedications) {
        setState(() {
          isFavorite = savedMedications
              .any((savedMed) => savedMed['id'] == widget.medication['id']);
        });
      }).catchError((error) {
        print('Error fetching saved medications: $error');
      });
    });
  }

  Future<String> loadToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  // 收藏狀態
  Future<void> toggleFavoriteStatus() async {
    try {
      await OpenDataService().toggleFavoriteStatus(
          token, 1, widget.medication['id'], isFavorite ?? false);
      setState(() {
        isFavorite = !(isFavorite ?? false);
      });
    } catch (error) {
      print('Error updating favorite status: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          widget.medication['med_tw_name'],
          style: const TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: <Widget>[
          IconButton(
            icon: Icon(
                isFavorite == true ? Icons.bookmark : Icons.bookmark_border),
            onPressed: toggleFavoriteStatus,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            detailItem(
                Icons.language, '英文名稱', widget.medication['med_en_name']),
            const Divider(),
            detailItem(Icons.factory, '製造商', widget.medication['manufacturer']),
            const Divider(),
            detailItem(
                Icons.flag, '製造商國家', widget.medication['manufacturer_country']),
            const Divider(),
            detailItem(Icons.category, '藥品類型', widget.medication['med_type']),
            const Divider(),
            detailItem(Icons.account_circle, '申請人',
                widget.medication['applicant_name']),
            const Divider(),
            detailItem(Icons.home_work, '申請人地址',
                widget.medication['applicant_address']),
            const Divider(),
            detailItem(Icons.format_list_bulleted, '成分',
                widget.medication['composition']),
            const Divider(),
            detailItem(Icons.healing, '使用方法', widget.medication['how_to_use']),
            const Divider(),
            detailItem(Icons.check_circle_outline, '適應症',
                widget.medication['indications']),
            const Divider(),
            detailItem(Icons.confirmation_num, '許可證號',
                widget.medication['permit_num']),
            const Divider(),
            detailItem(Icons.card_membership, '許可證類型',
                widget.medication['permit_type']),
            const Divider(),
            detailItem(Icons.calendar_today, '許可日期',
                formatDateString(widget.medication['permit_date'])),
            const Divider(),
            detailItem(Icons.edit, '編輯日期',
                formatDateString(widget.medication['edit_date'])),
            const Divider(),
            detailItem(Icons.date_range, '到期日期',
                formatDateString(widget.medication['expiration_date'])),
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
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 32.0),
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

String formatDateString(String dateString) {
  DateFormat inputFormat = DateFormat('EEE, dd MMM yyyy HH:mm:ss \'GMT\'');
  DateTime dateTime = inputFormat.parse(dateString, true).toLocal();
  String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
  return formattedDate;
}
