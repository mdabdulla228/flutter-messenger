import 'package:flutter/material.dart';
import 'chat_theme_manager.dart';

class FriendProfileScreen extends StatefulWidget {
  final String friendName;
  final String initial;
  final bool isOnline;

  const FriendProfileScreen({
    super.key,
    required this.friendName,
    required this.initial,
    required this.isOnline,
  });

  @override
  State<FriendProfileScreen> createState() => _FriendProfileScreenState();
}

class _FriendProfileScreenState extends State<FriendProfileScreen> {
  bool autoSaveMedia = false;
  bool stealthMessages = false;
  bool readReceipts = true;
  bool liveTypingIndicator = true;
  bool isNotificationMuted = false;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: KeoChatThemeManager.isBlueNight,
      builder: (context, isDark, _) {
        final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
        final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
        final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
        final subTextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: bgColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.more_vert_rounded, color: textColor),
                onPressed: () {},
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 46,
                        backgroundColor: const Color(0xFF38BDF8),
                        child: Text(
                          widget.initial,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (widget.isOnline)
                        Positioned(
                          right: 2,
                          bottom: 2,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: const Color(0xFF00C853),
                              shape: BoxShape.circle,
                              border: Border.all(color: bgColor, width: 3),
                            ),
                            child: const Center(
                              child: Icon(Icons.send_rounded, color: Colors.white, size: 10),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.friendName,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  'KeoChat ID: @${widget.friendName.toLowerCase().replaceAll(' ', '')}',
                  style: TextStyle(fontSize: 13, color: subTextColor),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(Icons.phone_rounded, 'Voice', cardColor, textColor),
                    _buildActionButton(Icons.videocam_rounded, 'Video', cardColor, textColor),
                    _buildActionButton(Icons.search_rounded, 'Search', cardColor, textColor),
                    _buildActionButton(Icons.palette_rounded, 'Theme', cardColor, textColor, onTap: () {
                      _showThemePicker();
                    }),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSectionHeader('Shared Vault', subTextColor),
                Container(
                  decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.photo_library_outlined, color: Color(0xFF0284C7)),
                        title: Text('Media, Files & Links', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                        subtitle: Text('Photos, documents and voice notes', style: TextStyle(color: subTextColor, fontSize: 12)),
                        trailing: Icon(Icons.chevron_right_rounded, color: subTextColor),
                      ),
                      Divider(height: 1, color: isDark ? Colors.white12 : Colors.black12),
                      ListTile(
                        leading: const Icon(Icons.push_pin_outlined, color: Color(0xFF10B981)),
                        title: Text('Pinned Highlights', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                        subtitle: Text('Important pinned conversations', style: TextStyle(color: subTextColor, fontSize: 12)),
                        trailing: Icon(Icons.chevron_right_rounded, color: subTextColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildSectionHeader('Chat Preferences & Controls', subTextColor),
                Container(
                  decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      SwitchListTile(
                        value: isNotificationMuted,
                        onChanged: (val) => setState(() => isNotificationMuted = val),
                        title: Text('Mute Alerts', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                        secondary: const Icon(Icons.notifications_off_outlined, color: Color(0xFFF59E0B)),
                      ),
                      Divider(height: 1, color: isDark ? Colors.white12 : Colors.black12),
                      SwitchListTile(
                        value: autoSaveMedia,
                        onChanged: (val) => setState(() => autoSaveMedia = val),
                        title: Text('Auto-Download Media', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                        secondary: const Icon(Icons.download_for_offline_outlined, color: Color(0xFF06B6D4)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildSectionHeader('Privacy & Protocol', subTextColor),
                Container(
                  decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.lock_outline_rounded, color: Color(0xFF22C55E)),
                        title: Text('End-to-End Vault', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                        subtitle: Text('Messages are encrypted & secure', style: TextStyle(color: subTextColor, fontSize: 12)),
                      ),
                      Divider(height: 1, color: isDark ? Colors.white12 : Colors.black12),
                      SwitchListTile(
                        value: stealthMessages,
                        onChanged: (val) => setState(() => stealthMessages = val),
                        title: Text('Self-Destruct Messages', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                        secondary: const Icon(Icons.timer_outlined, color: Color(0xFFEAB308)),
                      ),
                      Divider(height: 1, color: isDark ? Colors.white12 : Colors.black12),
                      SwitchListTile(
                        value: readReceipts,
                        onChanged: (val) => setState(() => readReceipts = val),
                        title: Text('Paper-Plane Seen Indicators', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                        secondary: const Icon(Icons.send_rounded, color: Color(0xFF38BDF8)),
                      ),
                      Divider(height: 1, color: isDark ? Colors.white12 : Colors.black12),
                      SwitchListTile(
                        value: liveTypingIndicator,
                        onChanged: (val) => setState(() => liveTypingIndicator = val),
                        title: Text('Active Typing Waves', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                        secondary: const Icon(Icons.more_horiz_rounded, color: Color(0xFFA855F7)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildSectionHeader('Connection Safety', subTextColor),
                Container(
                  decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.block_rounded, color: Color(0xFFF97316)),
                        title: Text('Block ${widget.friendName}', style: const TextStyle(color: Color(0xFFF97316), fontWeight: FontWeight.w600)),
                        onTap: () {},
                      ),
                      Divider(height: 1, color: isDark ? Colors.white12 : Colors.black12),
                      ListTile(
                        leading: const Icon(Icons.flag_outlined, color: Color(0xFFEF4444)),
                        title: const Text('Report Conversation', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w600)),
                        onTap: () {},
                      ),
                      Divider(height: 1, color: isDark ? Colors.white12 : Colors.black12),
                      ListTile(
                        leading: const Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626)),
                        title: const Text('Clear Chat History', style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.w600)),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 6, bottom: 8),
      child: Text(title, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.3)),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color bg, Color fg, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle, boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]),
            child: Icon(icon, color: fg, size: 24),
          ),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showThemePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select KeoChat Custom Theme', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: KeoChatThemeManager.builtInThemes.map((c) {
                  return GestureDetector(
                    onTap: () {
                      KeoChatThemeManager.customChatColor.value = c;
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(color: c, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
