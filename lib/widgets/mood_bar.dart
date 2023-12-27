import 'package:flutter/material.dart';


class MoodBar extends StatelessWidget {
  final double positive;
  final double neutral;
  final double negative;

  const MoodBar({
    Key? key,
    required this.positive,
    required this.neutral,
    required this.negative,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 6,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          _buildMoodSegment(positive, const Color.fromARGB(255, 141, 214, 144),
              isLeft: true),
          _buildMoodSegment(neutral, const Color.fromARGB(255, 255, 233, 166)),
          _buildMoodSegment(negative, const Color.fromARGB(255, 249, 148, 139),
              isRight: true),
        ],
      ),
    );
  }

  Widget _buildMoodSegment(double percentage, Color color,
      {bool isLeft = false, bool isRight = false}) {
    return Expanded(
      flex: (percentage * 100).toInt(),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.only(
            topLeft: isLeft ? const Radius.circular(5) : Radius.zero,
            bottomLeft: isLeft ? const Radius.circular(5) : Radius.zero,
            topRight: isRight ? const Radius.circular(5) : Radius.zero,
            bottomRight: isRight ? const Radius.circular(5) : Radius.zero,
          ),
        ),
      ),
    );
  }
}
