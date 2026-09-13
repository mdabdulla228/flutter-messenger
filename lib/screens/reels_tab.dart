import 'package:flutter/material.dart';

class ReelsTab extends StatelessWidget {
  const ReelsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: const Center(
        child: Text(
          'Reels & Videos',
          style: TextStyle(fontSize: 18, color: Colors.white70),
        ),
      ),
    );
  }
}