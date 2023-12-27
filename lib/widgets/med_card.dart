import 'package:flutter/material.dart';
import 'dart:math';

class MedCard extends StatelessWidget {
  final String medTwName;
  final String medEnName;
  final Function onTap;

  const MedCard({
    required this.medTwName,
    required this.medEnName,
    required this.onTap,
  });

  IconData getRandomIcon() {
    final List<IconData> randomIcons = [
      Icons.medical_services,
      Icons.vaccines,
      Icons.bloodtype,
      Icons.healing
    ];

    final random = Random();
    final randomIndex = random.nextInt(randomIcons.length);

    return randomIcons[randomIndex];
  }

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
          child: Icon(
            getRandomIcon(),
            color: Colors.white, // 設置圖示顏色
          ),
        ),
        title: Text(
          medTwName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(medEnName),
        onTap: () => onTap(),
      ),
    );
  }
}
