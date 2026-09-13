import "../widgets/active_plane_dot.dart";
import "package:messenger/screens/chat_room_screen.dart";
import "package:flutter/material.dart";
import "package:messenger/utils/localizations/chat_localizations.dart";

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final String _selectedLanguage = "English (US)";
  bool _hasNotification = true;
  int _notificationCount = 5; // Example notification count
  int _selectedTab = 0;

  final List<String> _filterTabs = ['All', 'Unread', 'Groups'];

  String _getText(String key) {
    final loc = ChatLocalizations(_selectedLanguage);
    return loc.getText(key);
  }

  final List<Map<String, dynamic>> _activeFriends = [
    {'name': 'Alex', 'online': true, 'lastSeen': ''},
    {'name': 'Maria', 'online': true, 'lastSeen': ''},
    {'name': 'John', 'online': false, 'lastSeen': '2h'},
    {'name': 'Sara', 'online': true, 'lastSeen': ''},
    {'name': 'Mike', 'online': false, 'lastSeen': 'Yesterday'},
  ];

  final List<Map<String, dynamic>> _chats = [
    {'name': 'Emma', 'message': 'Hey, how are you?', 'time': '10:30 AM', 'unread': 2},
    {'name': 'James', 'message': 'See you tomorrow!', 'time': '10:15 AM', 'unread': 0},
    {'name': 'Sophia', 'message': '👍', 'time': '09:45 AM', 'unread': 1},
    {'name': 'Oliver', 'message': 'No message yet', 'time': '09:00 AM', 'unread': 0},
    {'name': 'Ava', 'message': 'Thanks!', 'time': '08:30 AM', 'unread': 0},
    {'name': 'Lucas', 'message': 'Where are you?', 'time': '08:00 AM', 'unread': 3},
  ];

  Future<void> _refresh() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          "KeoChat",
          style: TextStyle(
            color: Color(0xFF1877F2),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF1877F2)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF1877F2)),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: const Color(0xFF1877F2),
        child: Column(
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  // Search (Left)
                  Flexible(
                    flex: 1,
                    child: InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.search, size: 18, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              _getText('search'),
                              style: const TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Notification (Center)
                  Flexible(
                    flex: 1,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _hasNotification = false;
                          _notificationCount = 0;
                        });
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              children: [
                                Icon(
                                  Icons.notifications,
                                  size: 18,
                                  color: _hasNotification ? Colors.amber : Colors.grey,
                                ),
                                if (_notificationCount > 0)
                                  Positioned(
                                    right: -6,
                                    top: -6,
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 16,
                                        minHeight: 16,
                                      ),
                                      child: Text(
                                        _notificationCount > 10 ? '10+' : _notificationCount.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getText('notification'),
                              style: TextStyle(
                                color: _hasNotification ? Colors.amber : Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // QR Code (Right)
                  Flexible(
                    flex: 0,
                    child: InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                        child: const Icon(Icons.qr_code, size: 20, color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Filter Tabs
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(_filterTabs.length, (index) {
                  final isSelected = _selectedTab == index;
                  return Flexible(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTab = index;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: isSelected ? const Color(0xFF1877F2) : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          _filterTabs[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected ? const Color(0xFF1877F2) : Colors.grey,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            // My Story + Active Friends
            Container(
              height: 110,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.grey.shade300,
                            child: const Icon(Icons.person, size: 28, color: Colors.white),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                color: Color(0xFF1877F2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "My Story",
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  ..._activeFriends.map((friend) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.grey.shade300,
                                child: Text(
                                  friend['name'][0],
                                  style: const TextStyle(fontSize: 18, color: Colors.white),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: friend["online"] ? const ActivePlaneDot(size: 16) : Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: friend['online'] ? const Color(0xFF00C853) : Colors.grey.shade400,
                                    shape: BoxShape.circle,
                                  ),
                                  child: friend['online']
                                      ? null
                                      : Center(
                                          child: Text(
                                            friend['lastSeen'].toString().substring(0, 1),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            friend['name'],
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black87,
                            ),
                          ),
                          if (!friend['online'])
                            Text(
                              friend['lastSeen'],
                              style: TextStyle(
                                fontSize: 8,
                                color: Colors.grey.shade500,
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            // Chat List
            Flexible(
              child: ListView.builder(
                itemCount: _chats.length,
                itemBuilder: (context, index) {
                  final chat = _chats[index];
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.grey.shade300,
                      child: Text(
                        chat['name'][0],
                        style: const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                    title: Text(
                      chat['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      chat['message'],
                      style: TextStyle(
                        color: chat['unread'] > 0 ? Colors.black : Colors.grey.shade600,
                        fontWeight: chat['unread'] > 0 ? FontWeight.w500 : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          chat['time'],
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                        if (chat['unread'] > 0)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: const BoxDecoration(
                              color: Color(0xFF1877F2),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              chat['unread'].toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) => ChatRoomScreen(friendName: chat["name"], isOnline: true))); },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}