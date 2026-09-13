import 'package:flutter/material.dart';

class KeoChatTheme {
  // --- BLUE-NIGHT DARK MODE ---
  static const Color darkBg = Color(0xFF0A1128); // ডিপ নেভি ব্লু ব্যাকগ্রাউন্ড
  static const Color darkCard = Color(0xFF131F42); // কার্ড ও ইনপুট ব্যাকগ্রাউন্ড
  static const Color darkSurface = Color(0xFF1C2C5E); // ডায়ালগ ও সারফেস
  static const Color darkAccentBlue = Color(0xFF2563EB); // বাবল প্রাইমারি ব্লু
  static const Color darkSenderBubble = Color(0xFF1D4ED8); // প্রেরকের মেসেজ বাবল
  static const Color darkReceiverBubble = Color(0xFF1F2937); // প্রাপকের মেসেজ বাবল
  static const Color darkTextPrimary = Color(0xFFF3F4F6); // টেক্সট
  static const Color darkTextSecondary = Color(0xFF9CA3AF);

  // --- GREEN-WHITE LIGHT MODE ---
  static const Color lightBg = Color(0xFFF9FAFB); // ক্লিন সফট হোয়াইট
  static const Color lightCard = Color(0xFFFFFFFF); // কার্ড ব্যাকগ্রাউন্ড
  static const Color lightAccentGreen = Color(0xFF00C853); // ফ্রেশ অ্যাক্টিভ গ্রিন
  static const Color lightSenderBubble = Color(0xFF00C853); // প্রেরক গ্রিন বাবল
  static const Color lightReceiverBubble = Color(0xFFE5E7EB); // প্রাপক সফট গ্রে বাবল
  static const Color lightTextPrimary = Color(0xFF111827);
  static const Color lightTextSecondary = Color(0xFF6B7280);

  // --- ১০টি প্রিসেট ওয়ালপেপার ---
  static final List<Map<String, dynamic>> presetWallpapers = [
    {'id': 'none', 'name': 'ডিফল্ট থিম', 'colors': [Colors.transparent, Colors.transparent]},
    {'id': 'midnight', 'name': 'মিডনাইট ব্লু', 'colors': [Color(0xFF0A1128), Color(0xFF1C2C5E)]},
    {'id': 'emerald', 'name': 'এমারেল্ড গ্রিন', 'colors': [Color(0xFF064E3B), Color(0xFF047857)]},
    {'id': 'deep_space', 'name': 'ডিপ স্পেস', 'colors': [Color(0xFF0F172A), Color(0xFF334155)]},
    {'id': 'sunset', 'name': 'সানসেট ভাইব', 'colors': [Color(0xFF4A0E4E), Color(0xFF881337)]},
    {'id': 'ocean', 'name': 'ওশান ডিপ', 'colors': [Color(0xFF082F49), Color(0xFF0369A1)]},
    {'id': 'royal_purple', 'name': 'রয়েল পার্পল', 'colors': [Color(0xFF3B0764), Color(0xFF6B21A8)]},
    {'id': 'forest_dark', 'name': 'ডার্ক ফরেস্ট', 'colors': [Color(0xFF022C22), Color(0xFF065F46)]},
    {'id': 'crimson_night', 'name': 'ক্রিমসন নাইট', 'colors': [Color(0xFF450A0A), Color(0xFF7F1D1D)]},
    {'id': 'charcoal', 'name': 'ক্লাসিক চারকোল', 'colors': [Color(0xFF18181B), Color(0xFF27272A)]},
  ];
}