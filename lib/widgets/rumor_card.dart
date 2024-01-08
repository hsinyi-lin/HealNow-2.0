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
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 4,
      shadowColor: Colors.grey.withOpacity(0.5),
      child: InkWell(
        onTap: () => onTap(),
        borderRadius: BorderRadius.circular(15.0),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  // color: Colors.blue.shade300,
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  formatDateString(rumorDate),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Title
              Text(
                rumorTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              const Divider(),
              // Content
              Text(
                rumorContent,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}