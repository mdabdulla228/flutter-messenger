import 'package:flutter/material.dart';
import '../keochat_features/keochat_room_screen.dart';

class KeoChatSearchScreen extends StatefulWidget {
  final List<Map<String, dynamic>> allChats;
  final List<Map<String, dynamic>> activeFriends;

  const KeoChatSearchScreen({
    super.key,
    required this.allChats,
    required this.activeFriends,
  });

  @override
  State<KeoChatSearchScreen> createState() => _KeoChatSearchScreenState();
}

class _KeoChatSearchScreenState extends State<KeoChatSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedFilterIndex = 0; // 0: All, 1: Friends, 2: Groups, 3: Messages

  final List<String> _filters = ['All', 'Friends', 'Groups', 'Messages'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openChat(String name, bool isOnline) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KeoChatRoomScreen(
          friendName: name,
          initial: name.isNotEmpty ? name[0].toUpperCase() : 'K',
          isOnline: isOnline,
        ),
      ),
    );
  }

  // Dynamically extract unique friends from user's active contacts & chat history
  List<Map<String, dynamic>> _getUserFriends() {
    final Map<String, Map<String, dynamic>> uniqueFriends = {};

    // 1. From active friends
    for (var f in widget.activeFriends) {
      final name = (f['name'] ?? '').toString();
      if (name.isNotEmpty && !uniqueFriends.containsKey(name)) {
        uniqueFriends[name] = {
          'name': name,
          'online': f['online'] == true,
          'subtitle': f['online'] == true ? 'Active now' : 'Connected',
          'isGroup': false,
        };
      }
    }

    // 2. From chats
    for (var c in widget.allChats) {
      final name = (c['name'] ?? '').toString();
      final bool isGrp = c['isGroup'] == true || name.toLowerCase().contains('group');
      if (name.isNotEmpty && !uniqueFriends.containsKey(name) && !isGrp) {
        uniqueFriends[name] = {
          'name': name,
          'online': false,
          'subtitle': 'Connected',
          'isGroup': false,
        };
      }
    }

    return uniqueFriends.values.toList();
  }

  // Dynamically extract groups from user's chats
  List<Map<String, dynamic>> _getUserGroups() {
    final List<Map<String, dynamic>> groups = [];
    for (var c in widget.allChats) {
      final name = (c['name'] ?? '').toString();
      final bool isGrp = c['isGroup'] == true || name.toLowerCase().contains('group');
      if (isGrp) {
        groups.add({
          'name': name,
          'members': c['members'] ?? 'Group conversation',
          'isGroup': true,
        });
      }
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final bool isSearching = query.isNotEmpty;

    final userFriends = _getUserFriends();
    final userGroups = _getUserGroups();

    // Instant filter by partial or full name
    final matchedFriends = userFriends.where((f) {
      final name = (f['name'] as String).toLowerCase();
      return name.contains(query);
    }).toList();

    final matchedGroups = userGroups.where((g) {
      final name = (g['name'] as String).toLowerCase();
      return name.contains(query);
    }).toList();

    final matchedMessages = widget.allChats.where((c) {
      final msg = ((c['message'] ?? '') as String).toLowerCase();
      final name = ((c['name'] ?? '') as String).toLowerCase();
      return msg.contains(query) || name.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Container(
          height: 42,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F2F5),
            borderRadius: BorderRadius.circular(24),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            onChanged: (val) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search friends, groups...',
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              prefixIcon: const Icon(Icons.search, color: Colors.black54, size: 20),
              suffixIcon: query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Chips: All | Friends | Groups | Messages
          Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected = _selectedFilterIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFilterIndex = index;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFE7F3FF) : const Color(0xFFF0F2F5),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _filters[index],
                      style: TextStyle(
                        color: isSelected ? const Color(0xFF1877F2) : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, thickness: 0.5, color: Color(0xFFE4E6EB)),

          // Result or Suggested list
          Expanded(
            child: !isSearching
                ? _buildSuggestedView(userFriends)
                : _buildSearchResults(matchedFriends, matchedGroups, matchedMessages),
          ),
        ],
      ),
    );
  }

  // Shown before typing search query (User's real friends)
  Widget _buildSuggestedView(List<Map<String, dynamic>> friends) {
    if (friends.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.people_outline, size: 56, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'No friends connected yet',
              style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 4),
            Text(
              'Search for people to start chatting',
              style: TextStyle(fontSize: 13, color: Colors.black45),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Suggested',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        ...friends.map((friend) {
          final isOnline = friend['online'] == true;
          final name = friend['name'] as String;
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            leading: Stack(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFFE4E6EB),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                if (isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFF31A24C),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            title: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
            subtitle: Text(
              friend['subtitle'] ?? 'Connected',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            onTap: () => _openChat(name, isOnline),
          );
        }),
      ],
    );
  }

  // Filtered results
  Widget _buildSearchResults(
    List<Map<String, dynamic>> friends,
    List<Map<String, dynamic>> groups,
    List<Map<String, dynamic>> messages,
  ) {
    if (_selectedFilterIndex == 1) return _buildFriendsList(friends);
    if (_selectedFilterIndex == 2) return _buildGroupsList(groups);
    if (_selectedFilterIndex == 3) return _buildMessagesList(messages);

    if (friends.isEmpty && groups.isEmpty && messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.search_off, size: 54, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              'No results found',
              style: TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        if (friends.isNotEmpty) ...[
          _buildSectionHeader('Friends'),
          ...friends.map((f) => _buildFriendTile(f)),
          const SizedBox(height: 12),
        ],
        if (groups.isNotEmpty) ...[
          _buildSectionHeader('Groups'),
          ...groups.map((g) => _buildGroupTile(g)),
          const SizedBox(height: 12),
        ],
        if (messages.isNotEmpty) ...[
          _buildSectionHeader('Messages'),
          ...messages.map((m) => _buildMessageTile(m)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildFriendTile(Map<String, dynamic> f) {
    final isOnline = f['online'] == true;
    final name = f['name'] as String;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFE4E6EB),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          if (isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFF31A24C),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87),
      ),
      subtitle: Text(
        f['subtitle'] ?? (isOnline ? 'Active now' : 'Connected'),
        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
      ),
      onTap: () => _openChat(name, isOnline),
    );
  }

  Widget _buildGroupTile(Map<String, dynamic> g) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: const Color(0xFF1877F2).withValues(alpha: 0.12),
        child: const Icon(Icons.group, color: Color(0xFF1877F2)),
      ),
      title: Text(
        g['name'],
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87),
      ),
      subtitle: Text(
        g['members'] ?? 'Group',
        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
      ),
      onTap: () => _openChat(g['name'], true),
    );
  }

  Widget _buildMessageTile(Map<String, dynamic> m) {
    final name = (m['name'] ?? 'Friend').toString();
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: Colors.grey.shade300,
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: Text(
        m['message'] ?? '',
        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        m['time'] ?? '',
        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
      ),
      onTap: () => _openChat(name, true),
    );
  }

  Widget _buildFriendsList(List<Map<String, dynamic>> friends) {
    if (friends.isEmpty) {
      return const Center(child: Text('No friends found', style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      itemCount: friends.length,
      itemBuilder: (context, index) => _buildFriendTile(friends[index]),
    );
  }

  Widget _buildGroupsList(List<Map<String, dynamic>> groups) {
    if (groups.isEmpty) {
      return const Center(child: Text('No groups found', style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      itemCount: groups.length,
      itemBuilder: (context, index) => _buildGroupTile(groups[index]),
    );
  }

  Widget _buildMessagesList(List<Map<String, dynamic>> messages) {
    if (messages.isEmpty) {
      return const Center(child: Text('No messages found', style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      itemCount: messages.length,
      itemBuilder: (context, index) => _buildMessageTile(messages[index]),
    );
  }
}
