import '../config/keochat_config.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum KeoGroupMessageType { text, image, video, audio, system }

class KeoGroupMember {
  final String id;
  final String name;
  final String avatarUrl;
  final bool isOwner;
  final bool isAdmin;
  final bool isOnline;
  final String? nickname;

  String get avatar => avatarUrl.isNotEmpty ? avatarUrl : (name.isNotEmpty ? name[0] : 'U');

  KeoGroupMember({
    required this.id,
    required this.name,
    String? avatar,
    String? avatarUrl,
    this.isOwner = false,
    this.isAdmin = false,
    this.isOnline = true,
    this.nickname,
  }) : avatarUrl = avatarUrl ?? avatar ?? '';

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatarUrl': avatarUrl,
        'isOwner': isOwner,
        'isAdmin': isAdmin,
        'isOnline': isOnline,
        'nickname': nickname,
      };

  factory KeoGroupMember.fromJson(Map<String, dynamic> json) => KeoGroupMember(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        avatarUrl: json['avatarUrl'] ?? '',
        isOwner: json['isOwner'] ?? false,
        isAdmin: json['isAdmin'] ?? false,
        isOnline: json['isOnline'] ?? false,
        nickname: json['nickname'],
      );
}

class KeoSeenStatus {
  final String memberId;
  final String memberName;
  final String memberAvatar;
  final String seenTime;

  KeoSeenStatus({
    required this.memberId,
    required this.memberName,
    this.memberAvatar = '',
    required this.seenTime,
  });

  Map<String, dynamic> toJson() => {
        'memberId': memberId,
        'memberName': memberName,
        'memberAvatar': memberAvatar,
        'seenTime': seenTime,
      };

  factory KeoSeenStatus.fromJson(Map<String, dynamic> json) => KeoSeenStatus(
        memberId: json['memberId'] ?? '',
        memberName: json['memberName'] ?? '',
        memberAvatar: json['memberAvatar'] ?? '',
        seenTime: json['seenTime'] ?? '',
      );
}

class KeoGroupMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String text;
  final KeoGroupMessageType type;
  final String? mediaPath;
  final String? videoDuration;
  final String time;
  final bool isMe;
  final Map<String, String> reactions; // userId -> emoji
  final List<KeoSeenStatus> seenBy; // list of members who have seen this

  KeoGroupMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.text,
    this.type = KeoGroupMessageType.text,
    this.mediaPath,
    this.videoDuration,
    required this.time,
    required this.isMe,
    Map<String, String>? reactions,
    List<KeoSeenStatus>? seenBy,
  })  : reactions = reactions ?? {},
        seenBy = seenBy ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'senderId': senderId,
        'senderName': senderName,
        'senderAvatar': senderAvatar,
        'text': text,
        'type': type.index,
        'mediaPath': mediaPath,
        'videoDuration': videoDuration,
        'time': time,
        'isMe': isMe,
        'reactions': reactions,
        'seenBy': seenBy.map((s) => s.toJson()).toList(),
      };

  factory KeoGroupMessage.fromJson(Map<String, dynamic> json) => KeoGroupMessage(
        id: json['id'] ?? '',
        senderId: json['senderId'] ?? '',
        senderName: json['senderName'] ?? '',
        senderAvatar: json['senderAvatar'],
        text: json['text'] ?? '',
        type: KeoGroupMessageType.values[json['type'] ?? 0],
        mediaPath: json['mediaPath'],
        videoDuration: json['videoDuration'],
        time: json['time'] ?? '',
        isMe: json['isMe'] ?? false,
        reactions: Map<String, String>.from(json['reactions'] ?? {}),
        seenBy: (json['seenBy'] as List<dynamic>? ?? [])
            .map((s) => KeoSeenStatus.fromJson(Map<String, dynamic>.from(s)))
            .toList(),
      );
}

class KeoGroup {
  final String id;
  String name;
  String? avatarUrl;
  final String createdAt;
  final String creatorName;
  List<KeoGroupMember> members;
  List<KeoGroupMessage> messages;
  bool isMuted;

  KeoGroup({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.createdAt,
    required this.creatorName,
    required this.members,
    List<KeoGroupMessage>? messages,
    this.isMuted = false,
  }) : messages = messages ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatarUrl': avatarUrl,
        'createdAt': createdAt,
        'creatorName': creatorName,
        'members': members.map((m) => m.toJson()).toList(),
        'messages': messages.map((m) => m.toJson()).toList(),
        'isMuted': isMuted,
      };

  factory KeoGroup.fromJson(Map<String, dynamic> json) => KeoGroup(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        avatarUrl: json['avatarUrl'],
        createdAt: json['createdAt'] ?? '',
        creatorName: json['creatorName'] ?? '',
        members: (json['members'] as List<dynamic>? ?? [])
            .map((m) => KeoGroupMember.fromJson(Map<String, dynamic>.from(m)))
            .toList(),
        messages: (json['messages'] as List<dynamic>? ?? [])
            .map((msg) => KeoGroupMessage.fromJson(Map<String, dynamic>.from(msg)))
            .toList(),
        isMuted: json['isMuted'] ?? false,
      );
}

class KeoGroupManager extends ChangeNotifier {
  static final KeoGroupManager _instance = KeoGroupManager._internal();
  factory KeoGroupManager() => _instance;
  KeoGroupManager._internal() {
    loadGroups();
  }

  static const String _storageKey = 'keochat_persistent_groups_v2';
  List<KeoGroup> _groups = [];

  List<KeoGroup> get groups => _groups;

  KeoGroup? getGroup(String id) {
    try {
      return _groups.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> loadGroups() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_storageKey);
      if (data != null && data.isNotEmpty) {
        final List<dynamic> list = jsonDecode(data);
        _groups = list.map((item) => KeoGroup.fromJson(Map<String, dynamic>.from(item))).toList();
      } else if (KeoChatConfig.enableDemoData) {
        _groups = [_createDemoGroup()];
        saveGroups();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading persistent groups: $e');
    }
  }

  Future<void> saveGroups() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = jsonEncode(_groups.map((g) => g.toJson()).toList());
      await prefs.setString(_storageKey, data);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving persistent groups: $e');
    }
  }

  Future<KeoGroup> createGroup({
    required String name,
    String? avatarPath,
    String? imagePath,
    List<KeoGroupMember>? selectedMembers,
    List<KeoGroupMember>? initialMembers,
    String creatorName = 'You',
  }) async {
    var membersList = selectedMembers ?? initialMembers ?? [];
    if (membersList.isEmpty && KeoChatConfig.enableDemoData) {
      membersList = [
        KeoGroupMember(id: 'u1', name: 'Tanvir Ahmed', avatarUrl: 'T', isOnline: true),
        KeoGroupMember(id: 'u2', name: 'Nafis Iqbal', avatarUrl: 'N', isOnline: true),
        KeoGroupMember(id: 'u3', name: 'Sadia Rahman', avatarUrl: 'S', isOnline: false),
        KeoGroupMember(id: 'u4', name: 'Fahim Shahriar', avatarUrl: 'F', isOnline: true),
      ];
    }
    final now = DateTime.now();
    final timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    final allMembers = [
      KeoGroupMember(
        id: 'me',
        name: 'You',
        isOwner: true,
        isAdmin: true,
        isOnline: true,
      ),
      ...membersList,
    ];

    final newGroup = KeoGroup(
      id: 'group_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      avatarUrl: avatarPath ?? imagePath,
      createdAt: timeStr,
      creatorName: creatorName,
      members: allMembers,
      messages: [
        KeoGroupMessage(
          id: 'msg_sys_created',
          senderId: 'system',
          senderName: 'System',
          text: '$creatorName created the group "$name"',
          type: KeoGroupMessageType.system,
          time: timeStr,
          isMe: false,
        ),
      ],
    );

    _groups.insert(0, newGroup);
    await saveGroups();
    return newGroup;
  }

  Future<void> addMessage(String groupId, KeoGroupMessage message) async {
    final group = getGroup(groupId);
    if (group != null) {
      // Simulate automatic seen by some active members for demonstration of real seen UI
      if (message.isMe && message.seenBy.isEmpty) {
        final activeMembers = group.members.where((m) => m.id != 'me').take(3).toList();
        final now = DateTime.now();
        final timeStr = "${now.hour % 12 == 0 ? 12 : now.hour % 12}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}";
        for (var member in activeMembers) {
          message.seenBy.add(KeoSeenStatus(
            memberId: member.id,
            memberName: member.name,
            memberAvatar: member.avatarUrl,
            seenTime: timeStr,
          ));
        }
      }
      group.messages.add(message);
      await saveGroups();
    }
  }

  Future<void> toggleReaction(String groupId, String messageId, String emoji, String userId) async {
    final group = getGroup(groupId);
    if (group != null) {
      final msg = group.messages.firstWhere((m) => m.id == messageId, orElse: () => group.messages.first);
      if (msg.reactions[userId] == emoji) {
        msg.reactions.remove(userId);
      } else {
        msg.reactions[userId] = emoji;
      }
      await saveGroups();
    }
  }

  Future<void> updateGroupName(String groupId, String newName) async {
    final group = getGroup(groupId);
    if (group != null && newName.trim().isNotEmpty) {
      group.name = newName.trim();
      final now = DateTime.now();
      final timeStr = "${now.hour}:${now.minute.toString().padLeft(2, '0')}";
      group.messages.add(KeoGroupMessage(
        id: 'msg_sys_${DateTime.now().millisecondsSinceEpoch}',
        senderId: 'system',
        senderName: 'System',
        text: 'Group name changed to "${group.name}"',
        type: KeoGroupMessageType.system,
        time: timeStr,
        isMe: false,
      ));
      await saveGroups();
    }
  }

  Future<void> updateGroupAvatar(String groupId, String newAvatar) async {
    final group = getGroup(groupId);
    if (group != null) {
      group.avatarUrl = newAvatar;
      final now = DateTime.now();
      final timeStr = "${now.hour}:${now.minute.toString().padLeft(2, '0')}";
      group.messages.add(KeoGroupMessage(
        id: 'msg_sys_${DateTime.now().millisecondsSinceEpoch}',
        senderId: 'system',
        senderName: 'System',
        text: 'Group photo was changed',
        type: KeoGroupMessageType.system,
        time: timeStr,
        isMe: false,
      ));
      await saveGroups();
    }
  }

  Future<void> addMembers(String groupId, List<KeoGroupMember> newMembers) async {
    final group = getGroup(groupId);
    if (group != null) {
      final existingIds = group.members.map((m) => m.id).toSet();
      final toAdd = newMembers.where((m) => !existingIds.contains(m.id)).toList();
      if (toAdd.isNotEmpty) {
        group.members.addAll(toAdd);
        final names = toAdd.map((m) => m.name).join(', ');
        final now = DateTime.now();
        final timeStr = "${now.hour}:${now.minute.toString().padLeft(2, '0')}";
        group.messages.add(KeoGroupMessage(
          id: 'msg_sys_${DateTime.now().millisecondsSinceEpoch}',
          senderId: 'system',
          senderName: 'System',
          text: '$names joined the group',
          type: KeoGroupMessageType.system,
          time: timeStr,
          isMe: false,
        ));
        await saveGroups();
      }
    }
  }

  Future<void> removeMember(String groupId, String memberId) async {
    final group = getGroup(groupId);
    if (group != null) {
      final removed = group.members.firstWhere((m) => m.id == memberId, orElse: () => group.members.first);
      group.members.removeWhere((m) => m.id == memberId);
      final now = DateTime.now();
      final timeStr = "${now.hour}:${now.minute.toString().padLeft(2, '0')}";
      group.messages.add(KeoGroupMessage(
        id: 'msg_sys_${DateTime.now().millisecondsSinceEpoch}',
        senderId: 'system',
        senderName: 'System',
        text: '${removed.name} left the group',
        type: KeoGroupMessageType.system,
        time: timeStr,
        isMe: false,
      ));
      await saveGroups();
    }
  }

  Future<void> deleteGroup(String groupId) async {
    _groups.removeWhere((g) => g.id == groupId);
    await saveGroups();
  }

  KeoGroup _createDemoGroup() {
    final now = DateTime.now();
    final timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    return KeoGroup(
      id: 'demo_group_devs',
      name: 'Flutter Devs BD 🚀',
      avatarUrl: null,
      createdAt: timeStr,
      creatorName: 'You',
      members: [
        KeoGroupMember(id: 'me', name: 'You', isOwner: true, isAdmin: true, isOnline: true),
        KeoGroupMember(id: 'u1', name: 'Tanvir Ahmed', avatarUrl: 'T', isOnline: true),
        KeoGroupMember(id: 'u2', name: 'Nafis Iqbal', avatarUrl: 'N', isOnline: true),
        KeoGroupMember(id: 'u3', name: 'Sadia Rahman', avatarUrl: 'S', isOnline: false),
        KeoGroupMember(id: 'u4', name: 'Fahim Shahriar', avatarUrl: 'F', isOnline: true),
      ],
      messages: [
        KeoGroupMessage(
          id: 'm1',
          senderId: 'u1',
          senderName: 'Tanvir Ahmed',
          senderAvatar: 'T',
          text: 'Welcome to KeoChat Flutter Team! 🎉',
          time: '10:30 AM',
          isMe: false,
          reactions: {'u2': '❤️', 'me': '👍'},
          seenBy: [
            KeoSeenStatus(memberId: 'u2', memberName: 'Nafis Iqbal', memberAvatar: 'N', seenTime: '10:31 AM'),
            KeoSeenStatus(memberId: 'me', memberName: 'You', memberAvatar: '', seenTime: '10:32 AM'),
          ],
        ),
        KeoGroupMessage(
          id: 'm2',
          senderId: 'u2',
          senderName: 'Nafis Iqbal',
          senderAvatar: 'N',
          text: 'The new UI design and Blue-Night theme look amazing!',
          time: '10:32 AM',
          isMe: false,
          reactions: {'u1': '🔥'},
          seenBy: [
            KeoSeenStatus(memberId: 'u1', memberName: 'Tanvir Ahmed', memberAvatar: 'T', seenTime: '10:33 AM'),
            KeoSeenStatus(memberId: 'me', memberName: 'You', memberAvatar: '', seenTime: '10:34 AM'),
          ],
        ),
        KeoGroupMessage(
          id: 'm3',
          senderId: 'me',
          senderName: 'You',
          text: 'Thanks! Let me know if any updates are needed before release.',
          time: '10:35 AM',
          isMe: true,
          reactions: {'u1': '👏', 'u4': '❤️'},
          seenBy: [
            KeoSeenStatus(memberId: 'u1', memberName: 'Tanvir Ahmed', memberAvatar: 'T', seenTime: '10:36 AM'),
            KeoSeenStatus(memberId: 'u2', memberName: 'Nafis Iqbal', memberAvatar: 'N', seenTime: '10:37 AM'),
            KeoSeenStatus(memberId: 'u4', memberName: 'Fahim Shahriar', memberAvatar: 'F', seenTime: '10:38 AM'),
          ],
        ),
      ],
    );
  }
}
