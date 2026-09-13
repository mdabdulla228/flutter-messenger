import 'package:flutter/material.dart';

class KeoChatThemeManager {
  static final ValueNotifier<bool> isBlueNight = ValueNotifier<bool>(true);
  static final ValueNotifier<Color> customChatColor = ValueNotifier<Color>(const Color(0xFF1877F2));
  static final ValueNotifier<String?> customGalleryImage = ValueNotifier<String?>(null);

  static const List<Color> builtInThemes = [
    Color(0xFF1877F2), // Keo Royal Blue
    Color(0xFF00A884), // Emerald Mint
    Color(0xFF6C5CE7), // Cyber Violet
    Color(0xFFFF7675), // Coral Blossom
    Color(0xFF00CEC9), // Neo Turquoise
    Color(0xFFFD79A8), // Berry Pink
    Color(0xFFE17055), // Terra Amber
    Color(0xFF0984E3), // Deep Azure
    Color(0xFF2D3436), // Onyx Shadow
    Color(0xFF20BF6B), // Lime Oasis
  ];

  static void toggleGlobalTheme() {
    isBlueNight.value = !isBlueNight.value;
  }
}
