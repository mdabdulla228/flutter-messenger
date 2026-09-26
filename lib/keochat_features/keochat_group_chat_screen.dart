import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'keochat_group_manager.dart';
import 'keochat_group_info_screen.dart';

class KeoGroupChatScreen extends StatefulWidget {
  final KeoGroup? group;
  final String? groupId;

  const KeoGroupChatScreen({
    super.key,
    this.group,
    this.groupId,
  }) : assert(group != null || groupId != null, 'Either group or groupId must be provided');

  @override
  State<KeoGroupChatScreen> createState() => _KeoGroupChatScreenState();
}

class _KeoGroupChatScreenState extends State<KeoGroupChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final KeoGroupManager _groupManager = KeoGroupManager();
  final ImagePicker _picker = ImagePicker();

  bool _isComposing = false;

  // Blue-Night & Mint White theme colors
  static const Color _blueNightBg = Color(0xFF0B141B);
  static const Color _blueNightSurface = Color(0xFF111E29);
  static const Color _blueNightBubbleMe = Color(0xFF0084FF);
  static const Color _blueNightBubbleOther = Color(0xFF1F2C34);

  static const Color _mintWhiteBg = Color(0xFFF4F9F6);
  static const Color _mintWhiteSurface = Color(0xFFFFFFFF);
  static const Color _mintWhiteBubbleOther = Color(0xFFE8F2EC);

  @override
  void initState() {
    super.initState();
    _groupManager.addListener(_onGroupChanged);
    _msgController.addListener(() {
      final composing = _msgController.text.trim().isNotEmpty;
      if (composing != _isComposing) {
        setState(() => _isComposing = composing);
      }
    });
  }

  @override
  void dispose() {
    _groupManager.removeListener(_onGroupChanged);
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onGroupChanged() {
    if (mounted) setState(() {});
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  KeoGroup get _currentGroup {
    final gid = widget.groupId ?? widget.group?.id ?? '';
    final found = _groupManager.getGroup(gid);
    if (found != null) return found;
    return KeoGroup(
      id: gid,
      name: 'Group',
      createdAt: '',
      creatorName: '',
      members: [],
    );
  }

  void _sendMessage({String? text, KeoGroupMessageType type = KeoGroupMessageType.text, String? mediaPath, String? videoDuration}) {
    final msgText = text ?? _msgController.text.trim();
    if (msgText.isEmpty && mediaPath == null) return;

    final now = DateTime.now();
    final timeStr = "${now.hour % 12 == 0 ? 12 : now.hour % 12}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}";

    final newMsg = KeoGroupMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'me',
      senderName: 'You',
      text: msgText,
      type: type,
      mediaPath: mediaPath,
      videoDuration: videoDuration,
      time: timeStr,
      isMe: true,
    );

    _groupManager.addMessage(_currentGroup.id, newMsg);
    _msgController.clear();
    _scrollToBottom();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 85);
      if (picked != null) {
        _sendMessage(
          type: KeoGroupMessageType.image,
          mediaPath: picked.path,
        );
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _pickVideo(ImageSource source) async {
    try {
      final picked = await _picker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 5),
      );
      if (picked != null) {
        _sendMessage(
          type: KeoGroupMessageType.video,
          mediaPath: picked.path,
          videoDuration: '0:45',
        );
      }
    } catch (e) {
      debugPrint('Error picking video: $e');
    }
  }

  void _openMediaPickerSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? _blueNightSurface : _mintWhiteSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE7F3FF),
                    child: Icon(Icons.photo_library_rounded, color: Color(0xFF0084FF)),
                  ),
                  title: Text(
                    'Photo from Gallery',
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFFECEC),
                    child: Icon(Icons.video_library_rounded, color: Colors.redAccent),
                  ),
                  title: Text(
                    'Video from Gallery',
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickVideo(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE9F8EE),
                    child: Icon(Icons.camera_alt_rounded, color: Colors.green),
                  ),
                  title: Text(
                    'Camera (Photo / Video)',
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSeenByBottomSheet(BuildContext context, KeoGroupMessage message, bool isDark) {
    final group = _currentGroup;
    final seenList = message.seenBy;
    final seenIds = seenList.map((s) => s.memberId).toSet();
    final notSeenList = group.members.where((m) => m.id != 'me' && !seenIds.contains(m.id)).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? _blueNightSurface : _mintWhiteSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black26,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: Color(0xFF5D5FEF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.remove_red_eye_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Seen by',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${seenList.length} of ${group.members.length} members have seen this message',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Divider(height: 1, color: isDark ? Colors.white12 : Colors.black12),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: [
                    ...seenList.map((seen) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: const Color(0xFF0084FF),
                                    child: Text(
                                      seen.memberName.isNotEmpty ? seen.memberName[0].toUpperCase() : 'U',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Positioned(
                                    right: -1,
                                    bottom: -1,
                                    child: Container(
                                      width: 11,
                                      height: 11,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF31A24C),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isDark ? _blueNightSurface : Colors.white,
                                          width: 1.8,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      seen.memberName,
                                      style: TextStyle(
                                        color: isDark ? Colors.white : Colors.black87,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      seen.seenTime,
                                      style: TextStyle(
                                        color: isDark ? Colors.white54 : Colors.black45,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.check_rounded, color: Color(0xFF31A24C), size: 20),
                            ],
                          ),
                        )),
                    if (notSeenList.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Not seen yet (${notSeenList.length})',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 12,
                        runSpacing: 10,
                        children: notSeenList.map((m) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: isDark ? Colors.white24 : Colors.black12,
                                child: Text(
                                  m.name.isNotEmpty ? m.name[0].toUpperCase() : 'U',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? Colors.white70 : Colors.black87,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                m.name,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? Colors.white70 : Colors.black87,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showReactionPicker(BuildContext context, KeoGroupMessage message, bool isDark) {
    final emojis = ['❤️', '😆', '😮', '😢', '😡', '👍'];
    showDialog(
      context: context,
      barrierColor: Colors.black38,
      builder: (ctx) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? _blueNightSurface : Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: emojis.map((emoji) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      _groupManager.toggleReaction(_currentGroup.id, message.id, emoji, 'me');
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(emoji, style: const TextStyle(fontSize: 26)),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final group = _currentGroup;
    final messages = group.messages;

    return Scaffold(
      backgroundColor: isDark ? _blueNightBg : _mintWhiteBg,
      appBar: AppBar(
        backgroundColor: isDark ? _blueNightSurface : _mintWhiteSurface,
        elevation: 0.5,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => KeoGroupInfoScreen(group: group),
              ),
            ).then((_) { if (mounted) setState(() {}); });
          },
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 19,
                    backgroundColor: const Color(0xFF0084FF),
                    backgroundImage: (group.avatarUrl != null && File(group.avatarUrl!).existsSync())
                        ? FileImage(File(group.avatarUrl!)) as ImageProvider
                        : null,
                    child: (group.avatarUrl == null || !File(group.avatarUrl!).existsSync())
                        ? const Icon(Icons.groups_rounded, color: Colors.white, size: 22)
                        : null,
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${group.members.length} members',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.videocam_rounded, color: isDark ? Colors.white : Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.call_rounded, color: isDark ? Colors.white : Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.info_outline_rounded, color: isDark ? Colors.white : Colors.black87),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => KeoGroupInfoScreen(group: group),
                ),
              ).then((_) { if (mounted) setState(() {}); });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                if (message.type == KeoGroupMessageType.system) {
                  return _buildSystemMessage(message, isDark);
                }
                return _buildMessageItem(context, message, isDark);
              },
            ),
          ),
          _buildInputBar(isDark),
        ],
      ),
    );
  }

  Widget _buildSystemMessage(KeoGroupMessage message, bool isDark) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageItem(BuildContext context, KeoGroupMessage message, bool isDark) {
    final isMe = message.isMe;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe) ...[
                CircleAvatar(
                  radius: 14,
                  backgroundColor: const Color(0xFF0084FF),
                  child: Text(
                    message.senderName.isNotEmpty ? message.senderName[0].toUpperCase() : 'U',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              GestureDetector(
                onLongPress: () => _showReactionPicker(context, message, isDark),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _buildMessageBubble(message, isMe, isDark),
                    if (message.reactions.isNotEmpty)
                      Positioned(
                        right: isMe ? 4 : null,
                        left: isMe ? null : 4,
                        bottom: -10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? _blueNightSurface : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                message.reactions.values.take(2).join(' '),
                                style: const TextStyle(fontSize: 12),
                              ),
                              if (message.reactions.length > 1) ...[
                                const SizedBox(width: 3),
                                Text(
                                  '${message.reactions.length}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white70 : Colors.black87,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (isMe && message.seenBy.isNotEmpty) ...[
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => _showSeenByBottomSheet(context, message, isDark),
              child: _buildSeenAvatars(message.seenBy, isDark),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageBubble(KeoGroupMessage message, bool isMe, bool isDark) {
    if (message.type == KeoGroupMessageType.image && message.mediaPath != null) {
      return Container(
        constraints: const BoxConstraints(maxWidth: 240, maxHeight: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isMe ? _blueNightBubbleMe : (isDark ? _blueNightBubbleOther : _mintWhiteBubbleOther),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Image.file(
              File(message.mediaPath!),
              fit: BoxFit.cover,
              width: 240,
              height: 220,
            ),
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  message.time,
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (message.type == KeoGroupMessageType.video && message.mediaPath != null) {
      return Container(
        width: 240,
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDark ? _blueNightBubbleOther : Colors.black87,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              color: Colors.black45,
              child: const Center(
                child: Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 52),
              ),
            ),
            Positioned(
              left: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.videocam_rounded, color: Colors.white, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      message.videoDuration ?? 'Video',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 8,
              bottom: 8,
              child: Text(
                message.time,
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 260),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: isMe
            ? _blueNightBubbleMe
            : (isDark ? _blueNightBubbleOther : _mintWhiteBubbleOther),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isMe ? 18 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            Text(
              message.senderName,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.blue[300] : const Color(0xFF0084FF),
              ),
            ),
            const SizedBox(height: 2),
          ],
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  message.text,
                  style: TextStyle(
                    fontSize: 14.5,
                    color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black87),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                message.time,
                style: TextStyle(
                  fontSize: 10.5,
                  color: isMe ? Colors.white70 : (isDark ? Colors.white54 : Colors.black45),
                ),
              ),
              if (isMe) ...[
                const SizedBox(width: 3),
                const Icon(Icons.done_all_rounded, size: 14, color: Colors.white70),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeenAvatars(List<KeoSeenStatus> seenBy, bool isDark) {
    final display = seenBy.take(4).toList();
    final remaining = seenBy.length - display.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? _blueNightSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black12,
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 20,
            width: (display.length * 15.0) + 6,
            child: Stack(
              children: display.asMap().entries.map((entry) {
                final idx = entry.key;
                final seen = entry.value;
                return Positioned(
                  left: idx * 14.0,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CircleAvatar(
                        radius: 9,
                        backgroundColor: const Color(0xFF0084FF),
                        child: Text(
                          seen.memberName.isNotEmpty ? seen.memberName[0].toUpperCase() : 'U',
                          style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Positioned(
                        right: -1,
                        bottom: -1,
                        child: Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: const Color(0xFF31A24C),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          if (remaining > 0) ...[
            const SizedBox(width: 4),
            Text(
              '+$remaining',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? _blueNightSurface : _mintWhiteSurface,
        border: Border(
          top: BorderSide(color: isDark ? Colors.white10 : Colors.black12, width: 0.5),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add_circle_rounded, color: Color(0xFF0084FF), size: 26),
              onPressed: () => _openMediaPickerSheet(context, isDark),
            ),
            IconButton(
              icon: const Icon(Icons.camera_alt_rounded, color: Color(0xFF0084FF), size: 24),
              onPressed: () => _pickImage(ImageSource.camera),
            ),
            IconButton(
              icon: const Icon(Icons.photo_rounded, color: Color(0xFF0084FF), size: 24),
              onPressed: () => _pickImage(ImageSource.gallery),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isDark ? _blueNightBg : const Color(0xFFE8F0EC),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _msgController,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(
                            color: isDark ? Colors.white38 : Colors.black38,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.sentiment_satisfied_alt_rounded, color: Color(0xFF0084FF), size: 22),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 4),
            if (_isComposing)
              IconButton(
                icon: const Icon(Icons.send_rounded, color: Color(0xFF0084FF), size: 24),
                onPressed: () => _sendMessage(),
              )
            else
              IconButton(
                icon: const Icon(Icons.thumb_up_rounded, color: Color(0xFF0084FF), size: 24),
                onPressed: () => _sendMessage(text: '👍'),
              ),
          ],
        ),
      ),
    );
  }
}
