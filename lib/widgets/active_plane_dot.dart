import 'package:flutter/material.dart';

class ActivePlaneDot extends StatelessWidget {
  final double size;

  const ActivePlaneDot({
    super.key,
    this.size = 18.0, // ফেসবুক মেসেঞ্জারের অ্যাক্টিভ ব্যাজের পারফেক্ট সাইজ
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFF00C853), // সলিড উজ্জ্বল ভাইব্র্যান্ট গ্রিন
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Transform.rotate(
          angle: -0.2, // পেপার প্লেনটির হালকা প্রাকৃতিক ফ্লাইং অ্যাঙ্গেল
          child: Icon(
            Icons.send_rounded,
            color: Colors.white,
            size: size * 0.58, // ভেতরের পেপার প্লেনটির ভারসাম্যপূর্ণ সাইজ
          ),
        ),
      ),
    );
  }
}