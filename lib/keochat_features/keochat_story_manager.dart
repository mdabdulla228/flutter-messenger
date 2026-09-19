import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class KeoStoryItem {
  final String id;
  final String? imagePath;
  final String? videoPath;
  final String? musicName;
  final String? musicArtist;
  final String? musicUrl;
  final double musicX;
  final double musicY;
  final double musicScale;
  final String? text;
  final int textColor;
  final int textStyleIndex;
  final bool textHasBackground;
  final double textX;
  final double textY;
  final double textScale;
  final double textRotation;
  final double stickerRotation;
  final String? sticker;
  final double stickerX;
  final double stickerY;
  final double stickerScale;
  final String? filter;
  final String? taggedFriend;
  final double tagX;
  final double tagY;
  final double tagScale;
  final List<List<double>>? doodlePoints;
  final int durationSeconds;
  final DateTime createdAt;
  final List<String> viewers;

  KeoStoryItem({
    required this.id,
    this.imagePath,
    this.videoPath,
    this.musicName,
    this.musicArtist,
    this.musicUrl,
    this.musicX = 40.0,
    this.musicY = 480.0,
    this.musicScale = 1.0,
    this.text,
    this.textColor = 0xFFFFFFFF,
    this.textStyleIndex = 0,
    this.textHasBackground = true,
    this.textX = 60.0,
    this.textY = 300.0,
    this.textScale = 1.0,
    this.textRotation = 0.0,
    this.stickerRotation = 0.0,
    this.sticker,
    this.stickerX = 120.0,
    this.stickerY = 200.0,
    this.stickerScale = 1.0,
    this.filter,
    this.taggedFriend,
    this.tagX = 50.0,
    this.tagY = 160.0,
    this.tagScale = 1.0,
    this.doodlePoints,
    this.durationSeconds = 10,
    required this.createdAt,
    List<String>? viewers,
  }) : viewers = viewers ?? [];

  bool get isExpired => DateTime.now().difference(createdAt).inHours >= 24;

  Map<String, dynamic> toJson() => {
    'id': id,
    'imagePath': imagePath,
    'videoPath': videoPath,
    'musicName': musicName,
    'musicArtist': musicArtist,
    'musicUrl': musicUrl,
    'musicX': musicX,
    'musicY': musicY,
    'musicScale': musicScale,
    'text': text,
    'textColor': textColor,
    'textStyleIndex': textStyleIndex,
    'textHasBackground': textHasBackground,
    'textX': textX,
    'textY': textY,
    'textScale': textScale,
    'textRotation': textRotation,
    'sticker': sticker,
    'stickerX': stickerX,
    'stickerY': stickerY,
    'stickerScale': stickerScale,
    'stickerRotation': stickerRotation,
    'filter': filter,
    'taggedFriend': taggedFriend,
    'tagX': tagX,
    'tagY': tagY,
    'tagScale': tagScale,
    'durationSeconds': durationSeconds,
    'createdAt': createdAt.toIso8601String(),
    'viewers': viewers,
      
  };

  factory KeoStoryItem.fromJson(Map<String, dynamic> json) {
    return KeoStoryItem(
      id: json['id'] ?? '',
      imagePath: json['imagePath'],
      videoPath: json['videoPath'],
      musicName: json['musicName'],
      musicArtist: json['musicArtist'],
      musicUrl: json['musicUrl'],
      musicX: (json['musicX'] as num?)?.toDouble() ?? 40.0,
      musicY: (json['musicY'] as num?)?.toDouble() ?? 480.0,
      musicScale: (json['musicScale'] as num?)?.toDouble() ?? 1.0,
      text: json['text'],
      textColor: (json['textColor'] as num?)?.toInt() ?? 0xFFFFFFFF,
      textStyleIndex: (json['textStyleIndex'] as num?)?.toInt() ?? 0,
      textHasBackground: json['textHasBackground'] ?? true,
      textX: (json['textX'] as num?)?.toDouble() ?? 60.0,
      textY: (json['textY'] as num?)?.toDouble() ?? 280.0,
      textScale: (json['textScale'] as num?)?.toDouble() ?? 1.0,
      textRotation: (json['textRotation'] as num?)?.toDouble() ?? 0.0,
      sticker: json['sticker'],
      stickerX: (json['stickerX'] as num?)?.toDouble() ?? 140.0,
      stickerY: (json['stickerY'] as num?)?.toDouble() ?? 260.0,
      stickerScale: (json['stickerScale'] as num?)?.toDouble() ?? 1.0,
      stickerRotation: (json['stickerRotation'] as num?)?.toDouble() ?? 0.0,
      filter: json['filter'],
      taggedFriend: json['taggedFriend'],
      tagX: (json['tagX'] as num?)?.toDouble() ?? 50.0,
      tagY: (json['tagY'] as num?)?.toDouble() ?? 160.0,
      tagScale: (json['tagScale'] as num?)?.toDouble() ?? 1.0,
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 10,
      createdAt: json['createdAt'] != null ? (DateTime.tryParse(json['createdAt']) ?? DateTime.now()) : DateTime.now(),
      viewers: (json['viewers'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

}

class KeoStoryManager {
  static final KeoStoryManager _instance = KeoStoryManager._internal();
  factory KeoStoryManager() => _instance;
  KeoStoryManager._internal() {
    loadStories();
  }

  static const String _storageKey = 'keochat_persistent_stories_v1';
  final List<KeoStoryItem> myStories = [];

  Future<void> loadStories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> list = jsonDecode(raw);
        myStories.clear();
        for (var item in list) {
          final s = KeoStoryItem.fromJson(item as Map<String, dynamic>);
            myStories.add(s);
          }
      }
    } catch (_) {}
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      cleanExpiredStories();
      await prefs.setString(_storageKey, jsonEncode(myStories.map((s) => s.toJson()).toList()));
    } catch (_) {}
  }

  static const int maxStoriesPerUser = 5;

  bool canAddStory() {
    cleanExpiredStories();
    return myStories.length < maxStoriesPerUser;
  }

  bool addStory(KeoStoryItem story) {
    cleanExpiredStories();
    if (myStories.length >= maxStoriesPerUser) {
      return false;
    }
    myStories.add(story);
    _save();
    return true;
  }

  void deleteStory(String id) {
    myStories.removeWhere((s) => s.id == id);
    _save();
  }

  void cleanExpiredStories() {
    myStories.removeWhere((s) => s.isExpired);
  }
}
