import 'dart:io';
import 'package:flutter/material.dart';
import 'keochat_group_manager.dart';

class KeoGroupInfoScreen extends StatefulWidget {
  final String groupId;

  const KeoGroupInfoScreen({super.key, required this.groupId});

  @override
  State<KeoGroupInfoScreen> createState() => _KeoGroupInfoScreenState();
}

class _KeoGroupInfoScreenState extends State<KeoGroupInfoScreen> {
  final KeoGroupManager _groupManager = KeoGroupManager();

  @override
  void initState() {
    super.initState();
    _groupManager.addListener(_onChanged);
  }

  @override
  void dispose() {
    _groupManager.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  void _showAddMemberDialog(KeoGroup group) {
    // Users pool not in the group yet
    final existingIds = group.members.map((m) => m.id).toSet();
    final potentialMembers = [
      KeoGroupMember(id: 'u1', name: 'Tanvir Ahmed', avatar: 'T'),
      KeoGroupMember(id: 'u2', name: 'Nafis Iqbal', avatar: 'N'),
      KeoGroupMember(id: 'u3', name: 'Fahim Shahriar', avatar: 'F'),
      KeoGroupMember(id: 'u4', name: 'Zubair Hossain', avatar: 'Z'),
      KeoGroupMember(id: 'u5', name: 'Mahmudul Hasan', avatar: 'M'),
      KeoGroupMember(id: 'u6', name: 'Saadman Sakib', avatar: 'S'),
      KeoGroupMember(id: 'u7', name: 'Rahat Chowdhury', avatar: 'R'),
      KeoGroupMember(id: 'u8', name: 'Kamrul Hasan', avatar: 'K'),
    ].where((m) => !existingIds.contains(m.id)).toList();

    if (potentialMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All available friends are already in this group.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Member'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: potentialMembers.length,
            itemBuilder: (_, index) {
              final user = potentialMembers[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFE7F3FF),
                  child: Text(user.avatar, style: const TextStyle(color: Color(0xFF1877F2))),
                ),
                title: Text(user.name),
                trailing: const Icon(Icons.person_add_alt_1, color: Color(0xFF1877F2)),
                onTap: () {
                  Navigator.pop(ctx);
                  _groupManager.addMember(group.id, user);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${user.name} added to group')),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _confirmRemoveMember(KeoGroup group, KeoGroupMember member) {
    if (member.id == 'me') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You are the group owner. Use "Leave Group" instead.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Member'),
        content: Text('Are you sure you want to remove ${member.name} from the group?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              _groupManager.removeMember(group.id, member.id);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmLeaveGroup(KeoGroup group) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave Group'),
        content: const Text('Are you sure you want to leave this group?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await _groupManager.deleteGroup(group.id);
              if (mounted) {
                // Return back to chats tab
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
            child: const Text('Leave', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Report Group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Spam or Scam'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report submitted. Thank you for keeping KeoChat safe.')),
                );
              },
            ),
            ListTile(
              title: const Text('Inappropriate Content'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report submitted. Thank you for keeping KeoChat safe.')),
                );
              },
            ),
            ListTile(
              title: const Text('Harassment'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report submitted. Thank you for keeping KeoChat safe.')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final group = _groupManager.getGroupById(widget.groupId);

    if (group == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Group Info')),
        body: const Center(child: Text('Group does not exist')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Group Info',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1, color: Color(0xFF1877F2)),
            onPressed: () => _showAddMemberDialog(group),
          ),
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          Center(
            child: CircleAvatar(
              radius: 46,
              backgroundColor: const Color(0xFFE7F3FF),
              backgroundImage: group.imagePath != null ? FileImage(File(group.imagePath!)) : null,
              child: group.imagePath == null
                  ? const Icon(Icons.groups_rounded, size: 48, color: Color(0xFF1877F2))
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              group.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          Center(
            child: Text(
              'Group · ${group.members.length} members',
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ),
          const SizedBox(height: 20),
          const Divider(thickness: 6, color: Color(0xFFF0F2F5)),

          // Mute Notifications Toggle
          SwitchListTile(
            secondary: Icon(
              group.isMuted ? Icons.notifications_off_outlined : Icons.notifications_active_outlined,
              color: const Color(0xFF1877F2),
            ),
            title: const Text('Mute Notifications', style: TextStyle(fontWeight: FontWeight.w600)),
            value: group.isMuted,
            activeThumbColor: const Color(0xFF1877F2),
            onChanged: (val) {
              _groupManager.toggleMute(group.id);
            },
          ),

          const Divider(thickness: 6, color: Color(0xFFF0F2F5)),

          // Members list section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${group.members.length} Members',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                  onPressed: () => _showAddMemberDialog(group),
                ),
              ],
            ),
          ),

          ...group.members.map((member) {
            final isOwner = member.id == 'me';
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFFE7F3FF),
                child: Text(
                  member.avatar.isNotEmpty ? member.avatar : member.name[0],
                  style: const TextStyle(color: Color(0xFF1877F2), fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(member.name, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(isOwner ? 'Group Owner' : 'Member', style: const TextStyle(fontSize: 12)),
              trailing: isOwner
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7F3FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('Owner', style: TextStyle(color: Color(0xFF1877F2), fontSize: 11, fontWeight: FontWeight.bold)),
                    )
                  : IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20),
                      onPressed: () => _confirmRemoveMember(group, member),
                    ),
            );
          }),

          const Divider(thickness: 6, color: Color(0xFFF0F2F5)),

          // Actions
          ListTile(
            leading: const Icon(Icons.report_problem_outlined, color: Colors.orange),
            title: const Text('Report Group', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600)),
            onTap: _showReportDialog,
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text('Leave Group', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
            onTap: () => _confirmLeaveGroup(group),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
