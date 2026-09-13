import 'package:flutter/material.dart';

class KeoActiveBadge extends StatelessWidget {
  final double size;
  final double iconSize;

  const KeoActiveBadge({
    super.key,
    this.size = 15.0,
    this.iconSize = 9.5,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFF31A24C),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.near_me,
          color: Colors.white,
          size: iconSize,
        ),
      ),
    );
  }
}
