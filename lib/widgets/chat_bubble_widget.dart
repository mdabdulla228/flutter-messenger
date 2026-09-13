import 'package:flutter/material.dart';

class ChatBubbleWidget extends StatelessWidget {
  final String text;
  final String time;
  final bool isMe;
  final String status; // 'sending', 'sent', 'delivered', 'read'
  final double fontSize;
  final VoidCallback? onLongPress;

  const ChatBubbleWidget({
    super.key,
    required this.text,
    required this.time,
    required this.isMe,
    this.status = 'delivered',
    this.fontSize = 15.0,
    this.onLongPress,
  });

  Widget _buildStatusIcon(BuildContext context) {
    if (!isMe) return const SizedBox.shrink();
    
    switch (status) {
      case 'sending':
        return const Icon(Icons.access_time, size: 13, color: Colors.white70);
      case 'sent':
        return const Icon(Icons.check, size: 13, color: Colors.white70);
      case 'read':
        return const Icon(Icons.done_all, size: 14, color: Color(0xFF60A5FA)); // নীল ডাবল টিক
      case 'delivered':
      default:
        return const Icon(Icons.done_all, size: 14, color: Colors.white70); // সাদা ডাবল টিক
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bubbleColor = isMe
        ? (isDark ? const Color(0xFF1D4ED8) : const Color(0xFF00C853))
        : (isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB));

    final textColor = isMe
        ? Colors.white
        : (isDark ? const Color(0xFFF3F4F6) : const Color(0xFF111827));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: GestureDetector(
          onLongPress: onLongPress,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.76,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 9.0),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 3),
                bottomRight: Radius.circular(isMe ? 3 : 16),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x10000000),
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: fontSize,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 10.5,
                        color: isMe
                            ? const Color(0xC0FFFFFF)
                            : (isDark ? Colors.white60 : Colors.black54),
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      _buildStatusIcon(context),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}