import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KeoGroupMember {
  final String id;
  final String name;
  final String avatar;
  final String role; // 'owner', 'admin', 'member'

  KeoGroupMember({
    required this.id,
    required this.name,
    this.avatar = '',
    this.role = 'member',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'avatar': avatar,
        'role': role,
      };

  factory KeoGroupMember.fromMap(Map<String, dynamic> map) => KeoGroupMember(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        avatar: map['avatar'] ?? '',
        role: map['role'] ?? 'member',
      );
}

class KeoGroupMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final String? imagePath;
  final String? audioPath;
  final DateTime timestamp;
  final Map<String, int> reactions; // e.g. {'❤️': 2, '👍': 1}

  KeoGroupMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    this.imagePath,
    this.audioPath,
    required this.timestamp,
    Map<String, int>? reactions,
  }) : reactions = reactions ?? {};

  Map<String, dynamic> toMap() => {
        'id': id,
        'senderId': senderId,
        'senderName': senderName,
        'text': text,
        'imagePath': imagePath,
        'audioPath': audioPath,
        'timestamp': timestamp.toIso8601String(),
        'reactions': reactions,
      };

  factory KeoGroupMessage.fromMap(Map<String, dynamic> map) => KeoGroupMessage(
        id: map['id'] ?? '',
        senderId: map['senderId'] ?? '',
        senderName: map['senderName'] ?? '',
        text: map['text'] ?? '',
        imagePath: map['imagePath'],
        audioPath: map['audioPath'],
        timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
        reactions: map['reactions'] != null ? Map<String, int>.from(map['reactions']) : {},
      );
}

class KeoGroup {
  final String id;
  String name;
  String? imagePath;
  String description;
  final String ownerId;
  List<KeoGroupMember> members;
  List<KeoGroupMessage> messages;
  final DateTime createdAt;
  bool isMuted;

  KeoGroup({
    required this.id,
    required this.name,
    this.imagePath,
    this.description = '',
    required this.ownerId,
    required this.members,
    List<KeoGroupMessage>? messages,
    required this.createdAt,
    this.isMuted = false,
  }) : messages = messages ?? [];

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'imagePath': imagePath,
        'description': description,
        'ownerId': ownerId,
        'members': members.map((m) => m.toMap()).toList(),
        'messages': messages.map((m) => m.toMap()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'isMuted': isMuted,
      };

  factory KeoGroup.fromMap(Map<String, dynamic> map) => KeoGroup(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        imagePath: map['imagePath'],
        description: map['description'] ?? '',
        ownerId: map['ownerId'] ?? '',
        members: (map['members'] as List<dynamic>? ?? [])
            .map((m) => KeoGroupMember.fromMap(Map<String, dynamic>.from(m)))
            .toList(),
        messages: (map['messages'] as List<dynamic>? ?? [])
            .map((m) => KeoGroupMessage.fromMap(Map<String, dynamic>.from(m)))
            .toList(),
        createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
        isMuted: map['isMuted'] ?? false,
      );
}

class KeoGroupManager extends ChangeNotifier {
  static final KeoGroupManager _instance = KeoGroupManager._internal();
  factory KeoGroupManager() => _instance;
  KeoGroupManager._internal();

  static const String _storageKey = 'keochat_user_groups_v1';
  final List<KeoGroup> _groups = [];
  bool _isLoaded = false;

  List<KeoGroup> get groups => List.unmodifiable(_groups);

  Future<void> loadGroups() async {
    if (_isLoaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataStr = prefs.getString(_storageKey);
      if (dataStr != null && dataStr.isNotEmpty) {
        final List decoded = jsonDecode(dataStr);
        _groups.clear();
        for (var item in decoded) {
          _groups.add(KeoGroup.fromMap(Map<String, dynamic>.from(item)));
        }
      }
      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading groups: $e');
    }
  }

  Future<void> _saveGroups() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_groups.map((g) => g.toMap()).toList());
      await prefs.setString(_storageKey, encoded);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving groups: $e');
    }
  }

  Future<KeoGroup> createGroup({
    required String name,
    String? imagePath,
    String description = '',
    required List<KeoGroupMember> initialMembers,
  }) async {
    await loadGroups();
    final newId = 'grp_${DateTime.now().millisecondsSinceEpoch}';
    
    // Add current user as owner
    final allMembers = [
      KeoGroupMember(id: 'me', name: 'You', role: 'owner'),
      ...initialMembers.where((m) => m.id != 'me'),
    ];

    final group = KeoGroup(
      id: newId,
      name: name.trim(),
      imagePath: imagePath,
      description: description.trim(),
      ownerId: 'me',
      members: allMembers,
      createdAt: DateTime.now(),
      messages: [
        KeoGroupMessage(
          id: 'sys_${DateTime.now().millisecondsSinceEpoch}',
          senderId: 'system',
          senderName: 'System',
          text: 'Group "$name" was created.',
          timestamp: DateTime.now(),
        ),
      ],
    );

    _groups.insert(0, group);
    await _saveGroups();
    return group;
  }

  KeoGroup? getGroupById(String groupId) {
    try {
      return _groups.firstWhere((g) => g.id == groupId);
    } catch (_) {
      return null;
    }
  }

  Future<void> sendMessage({
    required String groupId,
    required String text,
    String? imagePath,
    String? audioPath,
  }) async {
    final group = getGroupById(groupId);
    if (group == null) return;

    final msg = KeoGroupMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'me',
      senderName: 'You',
      text: text,
      imagePath: imagePath,
      audioPath: audioPath,
      timestamp: DateTime.now(),
    );

    group.messages.add(msg);
    // Bring group to top of recent
    _groups.remove(group);
    _groups.insert(0, group);
    await _saveGroups();
  }

  Future<void> toggleReaction(String groupId, String messageId, String emoji) async {
    final group = getGroupById(groupId);
    if (group == null) return;
    try {
      final msg = group.messages.firstWhere((m) => m.id == messageId);
      final current = msg.reactions[emoji] ?? 0;
      if (current > 0) {
        msg.reactions[emoji] = current - 1;
        if (msg.reactions[emoji] == 0) msg.reactions.remove(emoji);
      } else {
        msg.reactions[emoji] = 1;
      }
      await _saveGroups();
    } catch (_) {}
  }

  Future<void> addMember(String groupId, KeoGroupMember member) async {
    final group = getGroupById(groupId);
    if (group == null) return;
    if (!group.members.any((m) => m.id == member.id)) {
      group.members.add(member);
      group.messages.add(KeoGroupMessage(
        id: 'sys_${DateTime.now().millisecondsSinceEpoch}',
        senderId: 'system',
        senderName: 'System',
        text: '${member.name} was added to the group.',
        timestamp: DateTime.now(),
      ));
      await _saveGroups();
    }
  }

  Future<void> removeMember(String groupId, String memberId) async {
    final group = getGroupById(groupId);
    if (group == null) return;
    final removed = group.members.firstWhere((m) => m.id == memberId, orElse: () => KeoGroupMember(id: '', name: 'Member'));
    group.members.removeWhere((m) => m.id == memberId);
    group.messages.add(KeoGroupMessage(
      id: 'sys_${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'system',
      senderName: 'System',
      text: '${removed.name} left or was removed.',
      timestamp: DateTime.now(),
    ));
    await _saveGroups();
  }

  Future<void> toggleMute(String groupId) async {
    final group = getGroupById(groupId);
    if (group == null) return;
    group.isMuted = !group.isMuted;
    await _saveGroups();
  }

  Future<void> deleteGroup(String groupId) async {
    _groups.removeWhere((g) => g.id == groupId);
    await _saveGroups();
  }
}
