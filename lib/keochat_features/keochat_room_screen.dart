import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'chat_theme_manager.dart';
import 'friend_profile_screen.dart';
import 'paper_plane_badge.dart';

class KeoChatRoomScreen extends StatefulWidget {
  final String friendName;
  final String initial;
  final bool isOnline;
  final String? storyReplyText;
  final String? storyReplyAuthor;
  final String? storyImagePath;

  const KeoChatRoomScreen({
    super.key,
    required this.friendName,
    required this.initial,
    this.isOnline = true,
    this.storyReplyText,
    this.storyReplyAuthor,
    this.storyImagePath,
  });

  @override
  State<KeoChatRoomScreen> createState() => _KeoChatRoomScreenState();
}

class _KeoChatRoomScreenState extends State<KeoChatRoomScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  bool _showScrollToBottom = false;
  bool _isTyping = false;
  bool _isVoiceRecording = false;
  int _voiceSeconds = 0;
  Timer? _voiceTimer;
  String? _replyingToMessage;
  String? _replyingToSender;

  // Initial rich message list
  final List<Map<String, dynamic>> _messages = [
    {
      'id': '1',
      'isMe': false,
      'text': 'Hey! Are you free this evening? 😊',
      'time': 'FEB 13, 2026 AT 5:39 PM',
      'status': 'Seen',
      'reaction': '❤️',
    },
    {
      'id': '2',
      'isMe': true,
      'text': 'Yes! Just finished my shift. What are we planning?',
      'time': 'FEB 13, 2026 AT 5:42 PM',
      'status': 'Seen',
      'reaction': null,
    },
    {
      'id': '3',
      'isMe': false,
      'text': 'Check out the photos from yesterday trip!',
      'time': 'Yesterday',
      'status': 'Seen',
      'reaction': null,
    },
    {
      'id': '4',
      'isMe': false,
      'isMissedCall': true,
      'time': '5h ago',
      'status': 'Delivered',
      'reaction': null,
    },
    {
      'id': '5',
      'isMe': true,
      'text': 'Sounds perfect! Sending you the location now.',
      'time': '48m ago',
      'status': 'Delivered',
      'reaction': null,
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.storyReplyText != null && widget.storyReplyText!.isNotEmpty) {
      _messages.insert(0, {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'isMe': true,
        'isStoryReply': true,
        'storyAuthor': widget.storyReplyAuthor ?? widget.friendName,
        'storyImagePath': widget.storyImagePath,
        'text': widget.storyReplyText,
        'time': 'Just now',
        'status': 'Delivered',
        'reaction': null,
      });
    }
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _textController.dispose();
    _voiceTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    // Show scroll button only if scrolled up by at least 300 pixels (about 5 messages)
    if (_scrollController.hasClients) {
      final isUp = _scrollController.offset > 300;
      if (isUp != _showScrollToBottom) {
        setState(() {
          _showScrollToBottom = isUp;
        });
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage({String? text, bool isLike = false}) {
    final msg = text ?? _textController.text.trim();
    if (msg.isEmpty && !isLike) return;

    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    setState(() {
      _messages.insert(0, {
        'id': newId,
        'isMe': true,
        'text': isLike ? '👍' : msg,
        'isLike': isLike,
        'time': 'Just now',
        'status': 'Sending',
        'replyTo': _replyingToMessage,
        'replySender': _replyingToSender,
        'reaction': null,
      });
      _replyingToMessage = null;
      _replyingToSender = null;
    });

    _textController.clear();
    _scrollToBottom();

    // Transition status: Sending -> Sent -> Delivered -> Seen
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _findMsg(newId)?['status'] = 'Sent';
      });
    });

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      setState(() {
        _findMsg(newId)?['status'] = 'Delivered';
        _isTyping = true; // Friend starts typing with animated dots
      });
    });

    Future.delayed(const Duration(milliseconds: 3200), () {
      if (!mounted) return;
      setState(() {
        _findMsg(newId)?['status'] = 'Seen';
        _isTyping = false;
        // Friend reply simulation
        _messages.insert(0, {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'isMe': false,
          'text': 'Got it! Looking forward to it.',
          'time': 'Just now',
          'status': 'Delivered',
          'reaction': null,
        });
      });
      _scrollToBottom();
    });
  }

  Map<String, dynamic>? _findMsg(String id) {
    try {
      return _messages.firstWhere((m) => m['id'] == id);
    } catch (_) {
      return null;
    }
  }

  void _startVoiceRecord() {
    setState(() {
      _isVoiceRecording = true;
      _voiceSeconds = 0;
    });
    _voiceTimer?.cancel();
    _voiceTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _voiceSeconds++);
      }
    });
  }

  void _cancelVoiceRecord() {
    _voiceTimer?.cancel();
    setState(() {
      _isVoiceRecording = false;
      _voiceSeconds = 0;
    });
  }

  void _sendVoiceRecord() {
    _voiceTimer?.cancel();
    final durationStr = '0:${_voiceSeconds.toString().padLeft(2, '0')}';
    setState(() {
      _isVoiceRecording = false;
      _messages.insert(0, {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'isMe': true,
        'isVoice': true,
        'voiceDuration': durationStr,
        'time': 'Just now',
        'status': 'Sending',
        'reaction': null,
      });
    });
    _scrollToBottom();
  }

  void _showMessageActionMenu(Map<String, dynamic> message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = KeoChatThemeManager.isBlueNight.value;
        final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
        final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

        return Container(
          margin: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 16, offset: Offset(0, 4))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Messenger Reactions bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['❤️', '👍', '😆', '😮', '😢', '😠'].map((emoji) {
                    return GestureDetector(
                      onTap: () {
                        setState(() => message['reaction'] = emoji);
                        Navigator.pop(ctx);
                      },
                      child: Text(emoji, style: const TextStyle(fontSize: 28)),
                    );
                  }).toList(),
                ),
              ),
              Divider(height: 1, color: isDark ? Colors.white12 : Colors.black12),
              // 2. Action items: Reply, Copy, Pin, Forward, Delete
              ListTile(
                leading: Icon(Icons.reply_rounded, color: textColor),
                title: Text('Reply', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _replyingToMessage = message['text'] ?? 'Voice note';
                    _replyingToSender = message['isMe'] ? 'You' : widget.friendName;
                  });
                },
              ),
              ListTile(
                leading: Icon(Icons.copy_rounded, color: textColor),
                title: Text('Copy', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                onTap: () => Navigator.pop(ctx),
              ),
              ListTile(
                leading: Icon(Icons.push_pin_outlined, color: textColor),
                title: Text('Pin Message', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                onTap: () => Navigator.pop(ctx),
              ),
              ListTile(
                leading: Icon(Icons.forward_rounded, color: textColor),
                title: Text('Forward', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                onTap: () => Navigator.pop(ctx),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
                title: Text(
                  message['isMe'] ? 'Delete Options' : 'Delete for Me',
                  style: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  if (message['isMe']) {
                    _showDeleteConfirmation(message);
                  } else {
                    setState(() => _messages.removeWhere((m) => m['id'] == message['id']));
                  }
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Delete Message'),
        content: const Text('Who would you like to remove this message for?'),
        actions: [
          TextButton(
            child: const Text('Delete for Me'),
            onPressed: () {
              setState(() => _messages.removeWhere((m) => m['id'] == message['id']));
              Navigator.pop(ctx);
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: const Text('Delete for Everyone', style: TextStyle(color: Colors.white)),
            onPressed: () {
              setState(() => _messages.removeWhere((m) => m['id'] == message['id']));
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  void _showAttachmentSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(10)),
              ),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 4,
                mainAxisSpacing: 16,
                crossAxisSpacing: 12,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildAttachItem(Icons.photo_library_rounded, 'Gallery', const Color(0xFFA855F7)),
                  _buildAttachItem(Icons.camera_alt_rounded, 'Camera', const Color(0xFF0EA5E9)),
                  _buildAttachItem(Icons.videocam_rounded, 'Video', const Color(0xFFEF4444)),
                  _buildAttachItem(Icons.description_rounded, 'File', const Color(0xFFF59E0B)),
                  _buildAttachItem(Icons.mic_rounded, 'Voice', const Color(0xFFF97316)),
                  _buildAttachItem(Icons.location_on_rounded, 'Location', const Color(0xFF14B8A6)),
                  _buildAttachItem(Icons.person_rounded, 'Contact', const Color(0xFF06B6D4)),
                  _buildAttachItem(Icons.poll_rounded, 'Poll', const Color(0xFF6366F1)),
                ],
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttachItem(IconData icon, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 26),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: KeoChatThemeManager.isBlueNight,
      builder: (context, isDark, _) {
        final bgColor = isDark ? const Color(0xFF0B1120) : const Color(0xFFF8FAFC);
        final topBarBg = isDark ? const Color(0xFF0F172A) : Colors.white;
        final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: topBarBg,
            elevation: 0.5,
            leadingWidth: 74,
            leading: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 17,
                      backgroundColor: const Color(0xFF38BDF8),
                      child: Text(
                        widget.initial,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    if (widget.isOnline)
                      const Positioned(
                        right: 0,
                        bottom: 0,
                        child: PaperPlaneActiveBadge(size: 13),
                      ),
                  ],
                ),
              ],
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.friendName,
                  style: TextStyle(color: textColor, fontSize: 16.5, fontWeight: FontWeight.bold),
                ),
                Text(
                  _isTyping ? 'typing...' : (widget.isOnline ? 'Online' : 'Offline'),
                  style: TextStyle(
                    color: _isTyping ? const Color(0xFF38BDF8) : (widget.isOnline ? const Color(0xFF10B981) : Colors.grey),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(icon: Icon(Icons.call_rounded, color: textColor, size: 22), onPressed: () {}),
              IconButton(icon: Icon(Icons.videocam_rounded, color: textColor, size: 24), onPressed: () {}),
              // KeoChat Signature Paper-Plane Profile & Setting button
              IconButton(
                icon: Transform.rotate(
                  angle: -0.5,
                  child: Icon(Icons.send_rounded, color: const Color(0xFF38BDF8), size: 22),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => FriendProfileScreen(
                        friendName: widget.friendName,
                        initial: widget.initial,
                        isOnline: widget.isOnline,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    // Chat messages list
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          return _buildMessageRow(msg, isDark);
                        },
                      ),
                    ),

                    // Live typing indicator
                    if (_isTyping) _buildLiveTypingWave(isDark),

                    // Reply preview bar
                    if (_replyingToMessage != null) _buildReplyBar(isDark),

                    // Input bottom bar
                    _buildInputBottomBar(isDark),
                  ],
                ),

                // Center half-size scroll to bottom button (stays above input bar)
                if (_showScrollToBottom)
                  Positioned(
                    bottom: 80,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: _scrollToBottom,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            shape: BoxShape.circle,
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3)),
                            ],
                          ),
                          child: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 24),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageRow(Map<String, dynamic> msg, bool isDark) {
    final isMe = msg['isMe'] as bool;
    final themeColor = KeoChatThemeManager.customChatColor.value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Date separator if long ago
          if (msg['time'] != null && msg['time'].toString().contains('AT'))
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  msg['time'],
                  style: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black45,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe) ...[
                CircleAvatar(
                  radius: 14,
                  backgroundColor: const Color(0xFF38BDF8),
                  child: Text(widget.initial, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 6),
              ],

              GestureDetector(
                onLongPress: () => _showMessageActionMenu(msg),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isMe
                            ? themeColor
                            : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (msg['isStoryReply'] == true) ...[
                            Text(
                            '↰ You replied to story',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white60 : Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            if (msg['storyImagePath'] != null && File(msg['storyImagePath']).existsSync())
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  File(msg['storyImagePath']),
                                  width: 170,
                                  height: 220,
                                  fit: BoxFit.cover,
                                ),
                              )
                            else
                              Container(
                                width: 170,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade800,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Icon(Icons.auto_awesome, color: Colors.white60, size: 36),
                                ),
                              ),
                            const SizedBox(height: 6),
                          ],
                          if (msg['replyTo'] != null)
                            Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '↩ ${msg['replySender']}: ${msg['replyTo']}',
                                style: const TextStyle(fontSize: 11, color: Colors.white70),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          if (msg['isMissedCall'] == true) ...[
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.phone_missed_rounded, color: Color(0xFFEF4444), size: 18),
                                SizedBox(width: 8),
                                Text('Missed audio call', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                              child: const Text('Call back', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ] else if (msg['isVoice'] == true) ...[
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                                const SizedBox(width: 6),
                                const Icon(Icons.graphic_eq_rounded, color: Colors.white70, size: 28),
                                const SizedBox(width: 8),
                                Text(msg['voiceDuration'] ?? '0:15', style: const TextStyle(color: Colors.white, fontSize: 12)),
                              ],
                            ),
                          ] else ...[
                            Text(
                              msg['text'] ?? '',
                              style: TextStyle(
                                color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black87),
                                fontSize: msg['isLike'] == true ? 32 : 15,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Reaction emoji overlay
                    if (msg['reaction'] != null)
                      Positioned(
                        bottom: -8,
                        right: isMe ? null : -4,
                        left: isMe ? -4 : null,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                          ),
                          child: Text(msg['reaction'], style: const TextStyle(fontSize: 14)),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          // Message delivery status for my messages
          if (isMe) ...[
            const SizedBox(height: 3),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  msg['status'] ?? 'Delivered',
                  style: TextStyle(color: isDark ? Colors.white38 : Colors.black45, fontSize: 10),
                ),
                const SizedBox(width: 4),
                _buildStatusIcon(msg['status']),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusIcon(String? status) {
    if (status == 'Seen') {
      // KeoChat Signature Rolling downwards paper plane indicator
      return Transform.rotate(
        angle: 1.57, // Head pointing downwards
        child: const Icon(Icons.send_rounded, color: Color(0xFF1877F2), size: 12),
      );
    } else if (status == 'Sending') {
      return const SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 1.5));
    } else if (status == 'Sent') {
      return const Icon(Icons.check_rounded, color: Colors.grey, size: 12);
    } else {
      return const Icon(Icons.done_all_rounded, color: Colors.grey, size: 12);
    }
  }

  Widget _buildLiveTypingWave(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: const Color(0xFF38BDF8),
            child: Text(widget.initial, style: const TextStyle(color: Colors.white, fontSize: 10)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: const [
                Icon(Icons.more_horiz_rounded, color: Color(0xFF38BDF8), size: 22),
                SizedBox(width: 4),
                Text('typing...', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
      child: Row(
        children: [
          const Icon(Icons.reply_rounded, color: Color(0xFF1877F2), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Replying to $_replyingToSender: $_replyingToMessage',
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 16),
            onPressed: () => setState(() => _replyingToMessage = null),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBottomBar(bool isDark) {
    final barBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    if (_isVoiceRecording) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        color: barBg,
        child: Row(
          children: [
            // Cancel voice 'X' button
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Color(0xFFEF4444), size: 26),
              onPressed: _cancelVoiceRecord,
            ),
            const SizedBox(width: 8),
            const Icon(Icons.mic_rounded, color: Color(0xFFEF4444), size: 22),
            const SizedBox(width: 8),
            Text(
              'Recording 0:${_voiceSeconds.toString().padLeft(2, '0')}',
              style: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.send_rounded, color: Color(0xFF10B981), size: 26),
              onPressed: _sendVoiceRecord,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: barBg,
        border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.black12, width: 0.5)),
      ),
      child: Row(
        children: [
          // (+) Attachment button
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF1877F2), size: 26),
            onPressed: _showAttachmentSheet,
          ),

          // KeoChat Brand Gradient Like Button
          GestureDetector(
            onTap: () => _sendMessage(isLike: true),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00C6FF), Color(0xFF0072FF), Color(0xFF9B51E0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.thumb_up_rounded, color: Colors.white, size: 18),
            ),
          ),

          // Emoji button
          IconButton(
            icon: const Icon(Icons.sentiment_satisfied_alt_rounded, color: Color(0xFF1877F2), size: 24),
            onPressed: () {
              _textController.text += '😊';
            },
          ),

          // Text Field
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _textController,
                style: TextStyle(color: textColor, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  border: InputBorder.none,
                ),
                onSubmitted: (val) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 4),

          // Send / Voice Record
          IconButton(
            icon: Icon(
              _textController.text.isNotEmpty ? Icons.send_rounded : Icons.mic_rounded,
              color: const Color(0xFF1877F2),
              size: 24,
            ),
            onPressed: () {
              if (_textController.text.trim().isNotEmpty) {
                _sendMessage();
              } else {
                _startVoiceRecord();
              }
            },
          ),
        ],
      ),
    );
  }
}
