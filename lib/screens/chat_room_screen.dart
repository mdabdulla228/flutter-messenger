import 'package:flutter/material.dart';
import '../theme/keochat_theme.dart';
import '../widgets/active_plane_dot.dart';
import '../widgets/chat_bubble_widget.dart';
import '../controllers/keochat_controller.dart';

class ChatRoomScreen extends StatefulWidget {
  final String friendName;
  final bool isOnline;

  const ChatRoomScreen({
    super.key,
    required this.friendName,
    this.isOnline = true,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final KeoChatController _controller = KeoChatController.instance;

  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'আসসালামু আলাইকুম ভাই, কেমন আছেন?',
      'time': '10:30 AM',
      'isMe': false,
      'status': 'read',
    },
    {
      'text': 'ওয়ালাইকুমুস সালাম ভাই! আলহামদুলিল্লাহ ভালো। আপনার খবর কী?',
      'time': '10:32 AM',
      'isMe': true,
      'status': 'read',
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onThemeChanged);
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    final now = TimeOfDay.now();
    final minuteStr = now.minute.toString().padLeft(2, '0');
    final periodStr = now.period == DayPeriod.am ? 'AM' : 'PM';
    final timeStr = '${now.hourOfPeriod}:$minuteStr $periodStr';

    setState(() {
      _messages.add({
        'text': text,
        'time': timeStr,
        'isMe': true,
        'status': 'sent',
      });
      _msgController.clear();
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _controller.isDarkMode;
    final bgColor = isDark ? KeoChatTheme.darkBg : KeoChatTheme.lightBg;
    final appBarColor = isDark ? KeoChatTheme.darkCard : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 1,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: isDark ? const Color(0xFF1E3A8A) : Colors.grey.shade300,
                  child: Text(
                    widget.friendName.isNotEmpty ? widget.friendName[0] : '?',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (widget.isOnline)
                  const Positioned(
                    bottom: 0,
                    right: 0,
                    child: ActivePlaneDot(size: 14),
                  ),
              ],
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.friendName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  widget.isOnline ? 'Active now' : 'Offline',
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.isOnline ? const Color(0xFF00C853) : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return ChatBubbleWidget(
                  text: msg['text'],
                  time: msg['time'],
                  isMe: msg['isMe'],
                  status: msg['status'],
                  fontSize: _controller.fontSize,
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            color: isDark ? KeoChatTheme.darkCard : Colors.white,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _msgController,
                        style: TextStyle(color: textColor, fontSize: _controller.fontSize),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(
                            color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                          ),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00C853),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}