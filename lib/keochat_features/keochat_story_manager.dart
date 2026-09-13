
class KeoStoryItem {
  final String id;
  final String? imagePath;
  final String? videoPath;
  final String? musicName;
  final DateTime createdAt;
  final List<String> viewers;

  KeoStoryItem({
    required this.id,
    this.imagePath,
    this.videoPath,
    this.musicName,
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
    if (myStories.length >= 5) {
      myStories.removeAt(myStories.length - 1); // Maintain max 5 stories
    }
    myStories.insert(0, story); // Newest shows first
  }

  void deleteStory(String id) {
    myStories.removeWhere((s) => s.id == id);
  }

  void cleanExpiredStories() {
    myStories.removeWhere((s) => s.isExpired);
  }
}
