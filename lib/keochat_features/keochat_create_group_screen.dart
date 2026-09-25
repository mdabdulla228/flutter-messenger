import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'keochat_group_manager.dart';
import 'keochat_group_chat_screen.dart';

class KeoCreateGroupScreen extends StatefulWidget {
  const KeoCreateGroupScreen({super.key});

  @override
  State<KeoCreateGroupScreen> createState() => _KeoCreateGroupScreenState();
}

class _KeoCreateGroupScreenState extends State<KeoCreateGroupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  
  File? _groupImage;
  bool _isLoading = false;
  String _searchQuery = '';

  // Real users from KeoChat system
  final List<KeoGroupMember> _availableUsers = [
    KeoGroupMember(id: 'u1', name: 'Tanvir Ahmed', avatar: 'T'),
    KeoGroupMember(id: 'u2', name: 'Nafis Iqbal', avatar: 'N'),
    KeoGroupMember(id: 'u3', name: 'Fahim Shahriar', avatar: 'F'),
    KeoGroupMember(id: 'u4', name: 'Zubair Hossain', avatar: 'Z'),
    KeoGroupMember(id: 'u5', name: 'Mahmudul Hasan', avatar: 'M'),
    KeoGroupMember(id: 'u6', name: 'Saadman Sakib', avatar: 'S'),
    KeoGroupMember(id: 'u7', name: 'Rahat Chowdhury', avatar: 'R'),
    KeoGroupMember(id: 'u8', name: 'Kamrul Hasan', avatar: 'K'),
  ];

  final Set<String> _selectedUserIds = {};

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() {
        _groupImage = File(picked.path);
      });
    }
  }

  void _toggleSelect(String id) {
    setState(() {
      if (_selectedUserIds.contains(id)) {
        _selectedUserIds.remove(id);
      } else {
        _selectedUserIds.add(id);
      }
    });
  }

  Future<void> _handleCreate() async {
    final groupName = _nameController.text.trim();
    if (groupName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a group name'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_selectedUserIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least 1 member'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final selectedMembers = _availableUsers
        .where((u) => _selectedUserIds.contains(u.id))
        .toList();

    try {
      final newGroup = await KeoGroupManager().createGroup(
        name: groupName,
        imagePath: _groupImage?.path,
        initialMembers: selectedMembers,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        // Replace current screen with Group Chat Screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => KeoGroupChatScreen(groupId: newGroup.id),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create group: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = _availableUsers.where((u) {
      if (_searchQuery.isEmpty) return true;
      return u.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

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
          'New Group',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _handleCreate,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1877F2)),
                  )
                : const Text(
                    'Create',
                    style: TextStyle(color: Color(0xFF1877F2), fontWeight: FontWeight.bold, fontSize: 16),
                  ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header info: Group image + Group name
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: const Color(0xFFE7F3FF),
                        backgroundImage: _groupImage != null ? FileImage(_groupImage!) : null,
                        child: _groupImage == null
                            ? const Icon(Icons.groups_rounded, size: 36, color: Color(0xFF1877F2))
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 11,
                          backgroundColor: const Color(0xFF1877F2),
                          child: const Icon(Icons.camera_alt, size: 12, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'Group Name',
                      hintStyle: TextStyle(color: Colors.black38, fontSize: 16),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF1877F2), width: 1.5),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF1877F2), width: 2),
                      ),
                    ),
                    maxLength: 35,
                  ),
                ),
              ],
            ),
          ),

          // Selected count indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add Members',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                ),
                Text(
                  '${_selectedUserIds.length} selected',
                  style: const TextStyle(color: Color(0xFF1877F2), fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F2F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search, size: 20, color: Colors.black54),
                  hintText: 'Search friends...',
                  hintStyle: TextStyle(fontSize: 14, color: Colors.black45),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),
          const Divider(height: 1, thickness: 0.5, color: Color(0xFFE4E6EB)),

          // Member selection list
          Expanded(
            child: ListView.builder(
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                final user = filteredUsers[index];
                final isSelected = _selectedUserIds.contains(user.id);

                return ListTile(
                  onTap: () => _toggleSelect(user.id),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFE7F3FF),
                    child: Text(
                      user.avatar.isNotEmpty ? user.avatar : user.name[0],
                      style: const TextStyle(color: Color(0xFF1877F2), fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    user.name,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  trailing: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? const Color(0xFF1877F2) : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? const Color(0xFF1877F2) : Colors.grey.shade400,
                        width: 1.5,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
