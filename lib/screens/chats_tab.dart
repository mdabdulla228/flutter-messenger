import '../config/keochat_config.dart';

import 'keochat_search_screen.dart';
import 'package:flutter/material.dart';
import '../services/language_service.dart';
import 'qr_scanner_screen.dart';
import '../keochat_features/keochat_room_screen.dart';
import '../keochat_features/keochat_active_badge.dart';
import '../keochat_features/keochat_story_manager.dart';
import '../keochat_features/keochat_story_viewer.dart';
import '../keochat_features/keochat_story_creator.dart';
import '../keochat_features/keochat_create_group_screen.dart';
import '../keochat_features/keochat_group_chat_screen.dart';
import '../keochat_features/keochat_group_manager.dart';
import 'package:image_picker/image_picker.dart';

class ChatsTab extends StatefulWidget {
  const ChatsTab({super.key});

  @override
  State<ChatsTab> createState() => _ChatsTabState();
}

class _ChatsTabState extends State<ChatsTab> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  bool _isSearching = false;
  int _unreadNotifications = 3;
  int _selectedFilter = 0;

  @override
  void initState() {
    super.initState();
    KeoStoryManager().loadStories().then((_) {
      if (mounted) setState(() {});
    });
  }

  void _openStoryPicker() {
    final storyManager = KeoStoryManager();
    storyManager.cleanExpiredStories();
    if (storyManager.myStories.length >= KeoStoryManager.maxStoriesPerUser) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Story limit reached (5/5). Stories expire after 24 hours.'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF242526),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blueAccent),
              title: const Text('Add Photo Story', style: TextStyle(color: Colors.white)),
              subtitle: Text(
                '${storyManager.myStories.length}/5 stories used',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                final xfile = await picker.pickImage(source: ImageSource.gallery);
                if (xfile != null && mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => KeoStoryCreatorScreen(mediaFile: xfile, isVideo: false),
                    ),
                  ).then((_) { if (mounted) setState(() {}); });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam, color: Colors.redAccent),
              title: const Text('Add Short Video (Max 20s)', style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(ctx);
                final xfile = await picker.pickVideo(
                  source: ImageSource.gallery,
                  maxDuration: const Duration(seconds: 20),
                );
                if (xfile != null && mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => KeoStoryCreatorScreen(mediaFile: xfile, isVideo: true),
                    ),
                  ).then((_) { if (mounted) setState(() {}); });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleYourStoryTap() async {
    final storyManager = KeoStoryManager();
    storyManager.cleanExpiredStories();

    if (storyManager.myStories.isEmpty) {
      _openStoryPicker();
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF242526),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.remove_red_eye_outlined, color: Colors.blueAccent),
              title: const Text('View your story', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text(
                '${storyManager.myStories.length} active ${storyManager.myStories.length > 1 ? "stories" : "story"}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                final res = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => KeoStoryViewerScreen(
                      isMyStory: true,
                      userName: 'Your Story',
                      userInitial: 'Y',
                      stories: storyManager.myStories,
                    ),
                  ),
                );
                if (mounted) {
                  setState(() {});
                  if (res == 'ADD_STORY') {
                    _openStoryPicker();
                  }
                }
              },
            ),
            ListTile(
              leading: Icon(
                Icons.add_circle_outline,
                color: storyManager.myStories.length >= KeoStoryManager.maxStoriesPerUser
                    ? Colors.grey
                    : Colors.greenAccent,
              ),
              title: Text(
                storyManager.myStories.length >= KeoStoryManager.maxStoriesPerUser
                    ? 'Story limit reached (5/5)'
                    : 'Add to your story',
                style: TextStyle(
                  color: storyManager.myStories.length >= KeoStoryManager.maxStoriesPerUser
                      ? Colors.grey
                      : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                storyManager.myStories.length >= KeoStoryManager.maxStoriesPerUser
                    ? 'Wait 24h for existing stories to expire'
                    : 'You can add ${KeoStoryManager.maxStoriesPerUser - storyManager.myStories.length} more',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _openStoryPicker();
              },
            ),
          ],
        ),
      ),
    );
  }
 // 0: All, 1: Unread, 2: Groups

  final List<Map<String, dynamic>> _stories = KeoChatConfig.enableDemoData ? const [
    {'initial': 'R', 'name': 'Rahim', 'badge': ''},
    {'initial': 'S', 'name': 'Sadia', 'badge': '5m'},
    {'initial': 'T', 'name': 'Tanvir', 'badge': ''},
    {'initial': 'K', 'name': 'KeoC...', 'badge': ''},
  ] : const [];

  final List<Map<String, dynamic>> _chats = KeoChatConfig.enableDemoData ? const [
    {
      'initial': 'R',
      'name': 'Rahim Ahmed',
      'message': 'Hey! How are you?',
      'time': '9:40 PM',
      'unread': 2,
      'isGroup': false,
      'isOnline': true,
      'badge': '',
    },
    {
      'initial': 'S',
      'name': 'Sadia Islam',
      'message': "Let's catch up tomorro...",
      'time': '8:15 PM',
      'unread': 0,
      'isGroup': false,
      'isOnline': false,
      'badge': '5m',
    },
    {
      'initial': 'T',
      'name': 'Tanvir Hasan',
      'message': 'See you soon!',
      'time': '7:45 PM',
      'unread': 1,
      'isGroup': false,
      'isOnline': true,
      'badge': '',
    },
    {
      'initial': '',
      'name': 'KeoChat Developers Group',
      'message': 'Raj: Working on new r...',
      'time': '6:30 PM',
      'unread': 5,
      'isGroup': true,
      'isOnline': false,
      'badge': '',
    },
    {
      'initial': 'N',
      'name': 'Nusrat Jahan',
      'message': 'Wow! Thanks. 😊',
      'time': '5:20 PM',
      'unread': 0,
      'isGroup': false,
      'isOnline': false,
      'badge': '1h',
    },
    {
      'initial': 'K',
      'name': 'Kamrul Hasan',
      'message': 'Can you send the do...',
      'time': 'Yesterday',
      'unread': 0,
      'isGroup': false,
      'isOnline': false,
      'badge': '1d',
    },
  ] : const [];

  List<Map<String, dynamic>> get _allCombinedChats {
    final groupMgr = KeoGroupManager();
    final dynamicGroups = groupMgr.groups.map((g) {
      final lastMsg = g.messages.isNotEmpty ? g.messages.last : null;
      return {
        'initial': g.name.isNotEmpty ? g.name.substring(0, 1).toUpperCase() : 'G',
        'name': g.name,
        'message': lastMsg != null ? (lastMsg.type == KeoGroupMessageType.image ? '📷 Photo' : (lastMsg.type == KeoGroupMessageType.video ? '🎥 Video' : lastMsg.text)) : 'No messages yet',
        'time': lastMsg != null ? lastMsg.time : 'Just now',
        'unread': 0,
        'isGroup': true,
        'isOnline': false,
        'badge': '',
        'groupId': g.id,
        'groupAvatar': g.avatarUrl,
      };
    }).toList();

    return [...dynamicGroups, ..._chats];
  }

  List<Map<String, dynamic>> get _filteredChats {
    final all = _allCombinedChats;
    if (_selectedFilter == 1) {
      return all.where((c) => (c['unread'] as int? ?? 0) > 0).toList();
    } else if (_selectedFilter == 2) {
      return all.where((c) => c['isGroup'] == true).toList();
    }
    return all;
  }

  void _openNotificationsSheet() {
    setState(() {
      _unreadNotifications = 0; // Clears badge and turns bold off on tap
    });
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => const SizedBox(
        height: 350,
        child: Center(child: Text("Notifications")),
      ),
    );
  }

  void _openAiBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => const SizedBox(
        height: 350,
        child: Center(child: Text("AI Assistant")),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      setState(() {});
    }
  }

  void _showNewChatMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 38,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(10)),
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE7F3FF),
                    child: Icon(Icons.group_add_rounded, color: Color(0xFF1877F2)),
                  ),
                  title: Text(LanguageService.tr('new_group'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Text(LanguageService.tr('create_group_desc')),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const KeoCreateGroupScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE7F3FF),
                    child: Icon(Icons.campaign_rounded, color: Color(0xFF1877F2)),
                  ),
                  title: const Text('New Channel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Text(LanguageService.tr('broadcast_desc')),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayList = _filteredChats;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'KeoChat',
                        style: TextStyle(
                          color: Color(0xFF1877F2),
                          fontSize: 23.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                      InkWell(
                        onTap: _showNewChatMenu,
                        borderRadius: BorderRadius.circular(22),
                        child: Container(
  margin: const EdgeInsets.only(right: 8.5),
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE7F3FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Color(0xFF1877F2),
                            size: 26,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _handleRefresh,
                    color: const Color(0xFF1877F2),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                            child: Container(
  margin: const EdgeInsets.only(right: 8.5),
                              height: 46,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F2F5),
                                borderRadius: BorderRadius.circular(23),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.search, color: Colors.black54, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _searchController,
                                      focusNode: _searchFocusNode,
                                      style: const TextStyle(fontSize: 12.6, color: Colors.black87),
                                      decoration: const InputDecoration(
                                        hintText: 'Search (Name, @user, KC id, phone, email)',
                                        hintStyle: TextStyle(
                                          color: Colors.black45,
                                          fontSize: 12.6,
                                          fontWeight: FontWeight.normal,
                                        ),
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          _searchQuery = val.trim();
                                          _isSearching = _searchQuery.isNotEmpty || _searchFocusNode.hasFocus;
                                        });
                                      },
                                      onTap: () {
                                        _searchFocusNode.unfocus();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => KeoChatSearchScreen(
                                              allChats: _allCombinedChats,
                                              activeFriends: _stories,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  if (_isSearching)
                                    IconButton(
                                      icon: const Icon(Icons.close_rounded, size: 18, color: Colors.black54),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () {
                                        _searchController.clear();
                                        _searchFocusNode.unfocus();
                                        setState(() {
                                          _searchQuery = '';
                                          _isSearching = false;
                                        });
                                      },
                                    ),
                                  if (!_isSearching) ...[
                                    Transform.translate(
                                      offset: const Offset(-8.0, 0),
                                      child: InkWell(
                                        onTap: _openNotificationsSheet,
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
  margin: const EdgeInsets.only(right: 8.5),
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFF3CD),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: const Color(0xFFFFEEBA), width: 1),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.notifications_active_rounded, color: Color(0xFF856404), size: 15),
                                            const SizedBox(width: 3),
                                            Text(
                                              'Notification',
                                              style: TextStyle(
                                                color: const Color(0xFF856404),
                                                fontSize: 12,
                                                fontWeight: _unreadNotifications > 0 ? FontWeight.bold : FontWeight.w500,
                                              ),
                                            ),
                                            if (_unreadNotifications > 0) ...[
                                              const SizedBox(width: 2),
                                              Text(
                                                _unreadNotifications > 10 ? '(10+)' : '($_unreadNotifications)',
                                                style: const TextStyle(
                                                  color: Color(0xFFD9534F),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                    ),
                                    const SizedBox(width: 8),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => const QrScannerScreen()),
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(20),
                                      child: const Padding(
                                        padding: EdgeInsets.all(4.0),
                                        child: Icon(Icons.qr_code_scanner_rounded, color: Colors.black54, size: 22),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildTextTab(0, 'All'),
                                _buildTextTab(1, 'Unread'),
                                _buildTextTab(2, 'Groups'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            height: 88,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              children: [
                                // Your Story
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  child: GestureDetector(
                                    onTap: _handleYourStoryTap,
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 56,
                                          height: 56,
                                          padding: const EdgeInsets.all(2.5),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: KeoStoryManager().myStories.isNotEmpty
                                                ? Border.all(color: const Color(0xFF0084FF), width: 2.2)
                                                : null,
                                          ),
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFE7F3FF),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              KeoStoryManager().myStories.isNotEmpty ? Icons.play_arrow_rounded : Icons.add,
                                              color: const Color(0xFF1877F2),
                                              size: 28,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(LanguageService.tr('your_story'), style: const TextStyle(fontSize: 12.0, color: Colors.black87)),
                                      ],
                                    ),
                                  ),
                                ),
                                // Friends Stories & Profiles
                                ..._stories.map((s) {
                                  final bool hasStory = (s['badge'] != null && s['badge'] != '');
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 6),
                                    child: GestureDetector(
                                      onTap: () {
                                        if (hasStory) {
                                          // Tap to open Story Viewer
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => KeoStoryViewerScreen(
                                                isMyStory: false,
                                                userName: s['name'],
                                                userInitial: s['initial'],
                                                stories: [
                                                  KeoStoryItem(
                                                    id: 'friend_story_${s["name"]}',
                                                    musicName: 'Trending Song',
                                                    createdAt: DateTime.now(),
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                        } else {
                                          // Tap directly to Chat Screen if no story
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => KeoChatRoomScreen(
                                                friendName: s['name'],
                                                initial: s['initial'].toString().isNotEmpty ? s['initial'] : 'K',
                                                isOnline: true,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      onLongPress: () {
                                        // Long press always opens Chat Screen!
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => KeoChatRoomScreen(
                                              friendName: s['name'],
                                              initial: s['initial'].toString().isNotEmpty ? s['initial'] : 'K',
                                              isOnline: true,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Column(
                                        children: [
                                          Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              Container(
                                                width: 56,
                                                height: 56,
                                                padding: const EdgeInsets.all(2.5),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: hasStory
                                                      ? Border.all(color: const Color(0xFF0084FF), width: 2.2)
                                                      : null,
                                                ),
                                                child: Container(
                                                  decoration: const BoxDecoration(
                                                    color: Color(0xFFE7F3FF),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      s['initial'],
                                                      style: const TextStyle(
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.bold,
                                                        color: Color(0xFF1877F2),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                right: 1,
                                                bottom: 1,
                                                child: const KeoActiveBadge(size: 16.0, iconSize: 10.0),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          Text(s['name'], style: const TextStyle(fontSize: 12.0, color: Colors.black87)),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                                const Divider(height: 16, thickness: 0.5, color: Color(0xFFE4E6EB)),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: displayList.length,
                            itemBuilder: (context, index) {
                              final chat = displayList[index];
                                                            return InkWell(
                                onTap: () {
                                  if (chat['isGroup'] == true && chat['groupId'] != null) {
                                    final group = KeoGroupManager().getGroup(chat['groupId']);
                                    if (group != null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => KeoGroupChatScreen(group: group),
                                        ),
                                      ).then((_) { if (mounted) setState(() {}); });
                                      return;
                                    }
                                  }
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => KeoChatRoomScreen(
                                        friendName: chat['name'],
                                        initial: chat['initial'].toString().isNotEmpty ? chat['initial'] : 'K',
                                        isOnline: chat['isOnline'] ?? false,
                                      ),
                                    ),
                                  ).then((_) { if (mounted) setState(() {}); });
                                },
                                child: _buildChatTile(chat),
);
                            },
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              right: 18,
              bottom: 20,
              child: GestureDetector(
                onTap: _openAiBottomSheet,
                child: Container(
  margin: const EdgeInsets.only(right: 8.5),
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7F3FF),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1877F2).withValues(alpha: 0.25),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'AI',
                      style: TextStyle(
                        color: Color(0xFF1877F2),
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextTab(int index, String label) {
    final isSelected = _selectedFilter == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF1877F2) : Colors.black54,
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            height: 2.5,
            width: 24,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF1877F2) : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatTile(Map<String, dynamic> chat) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 27,
                backgroundColor: const Color(0xFFE7F3FF),
                child: chat['isGroup']
                    ? const Icon(Icons.group_rounded, color: Color(0xFF1877F2), size: 28)
                    : Text(
                        chat['initial'],
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1877F2)),
                      ),
              ),
              if (chat['isOnline'])
                                    const Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: KeoActiveBadge(size: 16.0, iconSize: 10.0),
                                    ),
              if (chat['badge'] != '')
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
  margin: const EdgeInsets.only(right: 8.5),
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1877F2),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Text(
                      chat['badge'],
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
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
                  chat['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  chat['message'],
                  style: TextStyle(
                    fontSize: 13.5,
                    color: chat['unread'] > 0 ? Colors.black87 : Colors.black54,
                    fontWeight: chat['unread'] > 0 ? FontWeight.w600 : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                chat['time'],
                style: TextStyle(
                  fontSize: 12,
                  color: chat['unread'] > 0 ? const Color(0xFF1877F2) : Colors.black45,
                  fontWeight: chat['unread'] > 0 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (chat['unread'] > 0) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1877F2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${chat['unread']}',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
