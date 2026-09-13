import 'package:flutter/material.dart';

class PaperPlaneActiveBadge extends StatelessWidget {
  final double size;
  const PaperPlaneActiveBadge({super.key, this.size = 15.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF00C853),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Transform.rotate(
          angle: -0.5,
          child: Icon(
            Icons.send_rounded,
            color: Colors.white,
            size: size * 0.6,
          ),
        ),
      ),
    );
  }
}
