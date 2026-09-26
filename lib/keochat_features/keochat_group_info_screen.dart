import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'keochat_group_manager.dart';

class KeoGroupInfoScreen extends StatefulWidget {
  final KeoGroup group;

  const KeoGroupInfoScreen({super.key, required this.group});

  @override
  State<KeoGroupInfoScreen> createState() => _KeoGroupInfoScreenState();
}

class _KeoGroupInfoScreenState extends State<KeoGroupInfoScreen> {
  final KeoGroupManager _groupManager = KeoGroupManager();
  final ImagePicker _picker = ImagePicker();

  // Blue-Night & Mint White theme colors
  static const Color _blueNightBg = Color(0xFF0B141B);
  static const Color _blueNightSurface = Color(0xFF111E29);
  static const Color _blueNightCard = Color(0xFF192734);

  static const Color _mintWhiteBg = Color(0xFFF4F9F6);
  static const Color _mintWhiteSurface = Color(0xFFFFFFFF);
  static const Color _mintWhiteCard = Color(0xFFE8F2EC);

  @override
  void initState() {
    super.initState();
    _groupManager.addListener(_onGroupChanged);
  }

  @override
  void dispose() {
    _groupManager.removeListener(_onGroupChanged);
    super.dispose();
  }

  void _onGroupChanged() {
    if (mounted) setState(() {});
  }

  KeoGroup get _currentGroup {
    return _groupManager.getGroup(widget.group.id) ?? widget.group;
  }

  Future<void> _changeGroupName() async {
    final controller = TextEditingController(text: _currentGroup.name);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? _blueNightSurface : _mintWhiteSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Change group name',
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: const InputDecoration(
            hintText: 'Enter group name',
            border: UnderlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0084FF)),
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (newName != null && newName.trim().isNotEmpty) {
      await _groupManager.updateGroupName(_currentGroup.id, newName.trim());
    }
  }

  Future<void> _changeGroupPhoto() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (picked != null) {
        await _groupManager.updateGroupAvatar(_currentGroup.id, picked.path);
      }
    } catch (e) {
      debugPrint('Error changing group avatar: $e');
    }
  }

  void _openAddMembersSheet(bool isDark) {
    // Available friends list
    final candidates = [
      KeoGroupMember(id: 'usr_alex', name: 'Alex Johnson', avatarUrl: ''),
      KeoGroupMember(id: 'usr_maria', name: 'Maria Garcia', avatarUrl: ''),
      KeoGroupMember(id: 'usr_john', name: 'John Doe', avatarUrl: ''),
      KeoGroupMember(id: 'usr_sara', name: 'Sara Connor', avatarUrl: ''),
      KeoGroupMember(id: 'usr_kamrul', name: 'Kamrul Hasan', avatarUrl: ''),
    ];

    final existingIds = _currentGroup.members.map((m) => m.id).toSet();
    final available = candidates.where((c) => !existingIds.contains(c.id)).toList();
    final selected = <KeoGroupMember>{};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? _blueNightSurface : _mintWhiteSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              height: MediaQuery.of(context).size.height * 0.65,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Add people',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      if (selected.isNotEmpty)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0084FF),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _groupManager.addMembers(_currentGroup.id, selected.toList());
                          },
                          child: Text('Add (${selected.length})', style: const TextStyle(color: Colors.white)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (available.isEmpty)
                    Expanded(
                      child: Center(
                        child: Text(
                          'All friends are already in this group',
                          style: TextStyle(color: isDark ? Colors.white54 : Colors.black45),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: available.length,
                        itemBuilder: (context, index) {
                          final friend = available[index];
                          final isChecked = selected.contains(friend);
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF0084FF),
                              child: Text(friend.name[0], style: const TextStyle(color: Colors.white)),
                            ),
                            title: Text(
                              friend.name,
                              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                            ),
                            trailing: Checkbox(
                              value: isChecked,
                              activeColor: const Color(0xFF0084FF),
                              onChanged: (val) {
                                setSheetState(() {
                                  if (val == true) {
                                    selected.add(friend);
                                  } else {
                                    selected.remove(friend);
                                  }
                                });
                              },
                            ),
                            onTap: () {
                              setSheetState(() {
                                if (isChecked) {
                                  selected.remove(friend);
                                } else {
                                  selected.add(friend);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _leaveGroupDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? _blueNightSurface : _mintWhiteSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Leave group?', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
        content: Text(
          'You will no longer receive messages from this group.',
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(ctx); // Close dialog
              await _groupManager.removeMember(_currentGroup.id, 'me');
              if (mounted) {
                Navigator.pop(context); // Close info
                Navigator.pop(context); // Close chat room
              }
            },
            child: const Text('Leave', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final group = _currentGroup;
    final mediaMessages = group.messages.where((m) => m.mediaPath != null).toList();

    return Scaffold(
      backgroundColor: isDark ? _blueNightBg : _mintWhiteBg,
      appBar: AppBar(
        backgroundColor: isDark ? _blueNightSurface : _mintWhiteSurface,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: isDark ? Colors.white : Colors.black87),
            color: isDark ? _blueNightCard : _mintWhiteSurface,
            onSelected: (val) {
              if (val == 'name') _changeGroupName();
              if (val == 'photo') _changeGroupPhoto();
              if (val == 'leave') _leaveGroupDialog(isDark);
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'name',
                child: Row(
                  children: [
                    Icon(Icons.edit_rounded, color: isDark ? Colors.white70 : Colors.black87, size: 20),
                    const SizedBox(width: 12),
                    Text('Change name', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'photo',
                child: Row(
                  children: [
                    Icon(Icons.photo_camera_rounded, color: isDark ? Colors.white70 : Colors.black87, size: 20),
                    const SizedBox(width: 12),
                    Text('Change photo', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'leave',
                child: const Row(
                  children: [
                    Icon(Icons.exit_to_app_rounded, color: Colors.redAccent, size: 20),
                    SizedBox(width: 12),
                    Text('Leave group', style: TextStyle(color: Colors.redAccent)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          // Top Center Profile Header (Messenger Style)
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _changeGroupPhoto,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: const Color(0xFF0084FF),
                        backgroundImage: (group.avatarUrl != null && File(group.avatarUrl!).existsSync())
                            ? FileImage(File(group.avatarUrl!)) as ImageProvider
                            : null,
                        child: (group.avatarUrl == null || !File(group.avatarUrl!).existsSync())
                            ? const Icon(Icons.groups_rounded, size: 52, color: Colors.white)
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0084FF),
                            shape: BoxShape.circle,
                            border: Border.all(color: isDark ? _blueNightBg : Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        group.name,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: _changeGroupName,
                      child: const Icon(Icons.edit_rounded, size: 18, color: Color(0xFF0084FF)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${group.members.length} members',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Circle Action Buttons Row (Add, Nicknames, Search, Mute)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCircleAction(
                icon: Icons.person_add_alt_1_rounded,
                label: 'Add',
                isDark: isDark,
                onTap: () => _openAddMembersSheet(isDark),
              ),
              _buildCircleAction(
                icon: Icons.badge_outlined,
                label: 'Nicknames',
                isDark: isDark,
                onTap: () {},
              ),
              _buildCircleAction(
                icon: Icons.search_rounded,
                label: 'Search',
                isDark: isDark,
                onTap: () {},
              ),
              _buildCircleAction(
                icon: group.isMuted ? Icons.notifications_off_rounded : Icons.notifications_rounded,
                label: group.isMuted ? 'Unmute' : 'Mute',
                isDark: isDark,
                onTap: () {
                  setState(() {
                    group.isMuted = !group.isMuted;
                  });
                  _groupManager.saveGroups();
                },
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Media & Files Section
          _buildSectionHeader('Shared Media & Files', isDark),
          const SizedBox(height: 10),
          if (mediaMessages.isNotEmpty) ...[
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: mediaMessages.length,
                itemBuilder: (context, index) {
                  final msg = mediaMessages[index];
                  return Container(
                    width: 90,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: isDark ? _blueNightCard : _mintWhiteCard,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (msg.mediaPath != null && File(msg.mediaPath!).existsSync())
                          Image.file(File(msg.mediaPath!), fit: BoxFit.cover)
                        else
                          Icon(Icons.image, color: isDark ? Colors.white38 : Colors.black38),
                        if (msg.type == KeoGroupMessageType.video)
                          const Center(
                            child: Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 28),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? _blueNightCard : _mintWhiteCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.photo_library_outlined, color: isDark ? Colors.white38 : Colors.black38),
                  const SizedBox(width: 12),
                  Text(
                    'No shared media yet',
                    style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),

          // Members Section
          _buildSectionHeader('Group Members (${group.members.length})', isDark),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: isDark ? _blueNightCard : _mintWhiteCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ...group.members.map((member) {
                  final isMe = member.id == 'me';
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF0084FF),
                      child: Text(
                        member.name.isNotEmpty ? member.name[0].toUpperCase() : 'U',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      isMe ? '${member.name} (You)' : member.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    subtitle: member.isOwner
                        ? const Text('Group Admin', style: TextStyle(color: Color(0xFF0084FF), fontSize: 11.5))
                        : null,
                    trailing: (!isMe && group.members.any((m) => m.id == 'me' && m.isAdmin))
                        ? IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20),
                            onPressed: () => _groupManager.removeMember(group.id, member.id),
                          )
                        : null,
                  );
                }),
                Divider(height: 1, color: isDark ? Colors.white10 : Colors.black12),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE7F3FF),
                    child: Icon(Icons.add, color: Color(0xFF0084FF)),
                  ),
                  title: const Text(
                    'Add people',
                    style: TextStyle(color: Color(0xFF0084FF), fontWeight: FontWeight.bold),
                  ),
                  onTap: () => _openAddMembersSheet(isDark),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Actions & Leave
          _buildSectionHeader('Actions', isDark),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: isDark ? _blueNightCard : _mintWhiteCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.push_pin_outlined, color: Color(0xFF0084FF)),
                  title: Text('Pinned messages', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {},
                ),
                Divider(height: 1, color: isDark ? Colors.white10 : Colors.black12),
                ListTile(
                  leading: const Icon(Icons.palette_outlined, color: Color(0xFF0084FF)),
                  title: Text('Theme & colors', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {},
                ),
                Divider(height: 1, color: isDark ? Colors.white10 : Colors.black12),
                ListTile(
                  leading: const Icon(Icons.exit_to_app_rounded, color: Colors.redAccent),
                  title: const Text('Leave group', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                  onTap: () => _leaveGroupDialog(isDark),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white60 : Colors.black54,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildCircleAction({
    required IconData icon,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? _blueNightCard : const Color(0xFFE4E6EB),
            ),
            child: Icon(icon, color: isDark ? Colors.white : Colors.black87, size: 22),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
      ],
    );
  }
}
