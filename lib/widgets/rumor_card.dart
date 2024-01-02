import 'package:flutter/material.dart';

import '../utils/utils.dart';


class RumorCard extends StatelessWidget {
  final String rumorDate;
  final String rumorTitle;
  final String rumorContent;
  final Function onTap;

  const RumorCard({
    required this.rumorDate,
    required this.rumorTitle,
    required this.rumorContent,
    required this.onTap,
  });

   @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 4,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // date 
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 97, 97, 97), 
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                formatDateString(rumorDate),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(height: 6), 
            // title
            Text(
              rumorTitle,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8), 
            const Divider(),
            // content
            Text(
              rumorContent,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        onTap: () => onTap(),
      ),
    );
  }
}