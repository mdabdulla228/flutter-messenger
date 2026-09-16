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
  final double textX;
  final double textY;
  final double textScale;
  final String? sticker;
  final double stickerX;
  final double stickerY;
  final double stickerScale;
  final String? filter;
  final String? taggedFriend;
  final List<List<double>>? doodlePoints;
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
    this.textX = 60.0,
    this.textY = 300.0,
    this.textScale = 1.0,
    this.sticker,
    this.stickerX = 120.0,
    this.stickerY = 200.0,
    this.stickerScale = 1.0,
    this.filter,
    this.taggedFriend,
    this.doodlePoints,
    required this.createdAt,
    List<String>? viewers,
  }) : viewers = viewers ?? [];

  bool get isExpired => DateTime.now().difference(createdAt).inHours >= 24;
}

class KeoStoryManager {
  static final KeoStoryManager _instance = KeoStoryManager._internal();
  factory KeoStoryManager() => _instance;
  KeoStoryManager._internal();

  final List<KeoStoryItem> myStories = [];

  void addStory(KeoStoryItem story) {
    cleanExpiredStories();
    if (myStories.length >= 10) {
      myStories.removeAt(myStories.length - 1);
    }
    myStories.insert(0, story);
  }

  void deleteStory(String id) {
    myStories.removeWhere((s) => s.id == id);
  }

  void cleanExpiredStories() {
    myStories.removeWhere((s) => s.isExpired);
  }
}
