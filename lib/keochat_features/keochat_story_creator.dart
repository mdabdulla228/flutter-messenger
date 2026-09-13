import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'keochat_story_manager.dart';

class KeoMusicItem {
  final String title;
  final String artist;
  final String category;
  KeoMusicItem({required this.title, required this.artist, required this.category});
}

class KeoStoryCreatorScreen extends StatefulWidget {
  final XFile mediaFile;
  final bool isVideo;

  const KeoStoryCreatorScreen({
    super.key,
    required this.mediaFile,
    required this.isVideo,
  });

  @override
  State<KeoStoryCreatorScreen> createState() => _KeoStoryCreatorScreenState();
}

class _KeoStoryCreatorScreenState extends State<KeoStoryCreatorScreen> {
  KeoMusicItem? _selectedMusic;
  String? _overlayText;
  String? _selectedFilter;
  String? _selectedSticker;

  final List<KeoMusicItem> _allSongs = [
    KeoMusicItem(title: 'I Love My Life', artist: 'Affirm with Music', category: 'For you'),
    KeoMusicItem(title: 'All My Life', artist: 'Lil Durk', category: 'For you'),
    KeoMusicItem(title: 'My Baby', artist: 'Diamond Platnumz', category: 'Weekend'),
    KeoMusicItem(title: 'MALA SANTA', artist: 'Becky G', category: 'Date Night'),
    KeoMusicItem(title: 'Baba', artist: 'Hotkeed', category: 'Birthday'),
    KeoMusicItem(title: "God's Plan", artist: 'Drake', category: 'For you'),
    KeoMusicItem(title: 'Happiness Is My Choice', artist: 'iQ Watson', category: 'Family'),
    KeoMusicItem(title: 'Mirror (Album Version)', artist: 'Lil Wayne', category: 'For you'),
    KeoMusicItem(title: 'Fine Girl', artist: '2stepvibes', category: 'Weekend'),
    KeoMusicItem(title: 'Love My Life', artist: 'Demarco', category: 'For you'),
    KeoMusicItem(title: 'Tum Hi Ho', artist: 'Arijit Singh', category: 'Date Night'),
    KeoMusicItem(title: 'Bojhena Shey Bojhena', artist: 'Arijit Singh', category: 'Date Night'),
    KeoMusicItem(title: 'Mon Majhi Re', artist: 'Arijit Singh', category: 'For you'),
  ];

  void _openMusicSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF18191A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        String searchQuery = '';
        String activeCategory = 'For you';
        final categories = ['For you', 'Weekend', 'Birthday', 'Date Night', 'Family'];

        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredSongs = _allSongs.where((s) {
              final matchesCategory = activeCategory == 'For you' || s.category == activeCategory;
              final matchesSearch = s.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
                  s.artist.toLowerCase().contains(searchQuery.toLowerCase());
              return matchesCategory && matchesSearch;
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.88,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Add a song to your story',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Search Bar
                  Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFF242526),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.white70, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            decoration: const InputDecoration(
                              hintText: 'Search music',
                              hintStyle: TextStyle(color: Colors.white54, fontSize: 14),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            onChanged: (val) {
                              setModalState(() {
                                searchQuery = val;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Categories chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: categories.map((cat) {
                        final isSel = activeCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(cat),
                            selected: isSel,
                            selectedColor: const Color(0xFF3A3B3C),
                            backgroundColor: const Color(0xFF242526),
                            labelStyle: TextStyle(
                              color: isSel ? Colors.white : Colors.white70,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            onSelected: (_) {
                              setModalState(() {
                                activeCategory = cat;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    activeCategory,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  // Song list
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredSongs.length,
                      itemBuilder: (context, i) {
                        final song = filteredSongs[i];
                        final isChosen = _selectedMusic?.title == song.title;

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 4),
                          leading: Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE41E3F),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Center(
                              child: Icon(Icons.music_note, color: Colors.white, size: 26),
                            ),
                          ),
                          title: Text(
                            song.title,
                            style: TextStyle(
                              color: isChosen ? const Color(0xFF1877F2) : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Text(
                            song.artist,
                            style: const TextStyle(color: Colors.white60, fontSize: 13),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              isChosen ? Icons.check_circle : Icons.play_arrow,
                              color: isChosen ? const Color(0xFF1877F2) : Colors.white,
                              size: 28,
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedMusic = song;
                              });
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Selected & Playing: ${song.title} - ${song.artist} 🎵'),
                                  backgroundColor: const Color(0xFF1877F2),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                          onTap: () {
                            setState(() {
                              _selectedMusic = song;
                            });
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Selected & Playing: ${song.title} - ${song.artist} 🎵'),
                                backgroundColor: const Color(0xFF1877F2),
                                duration: const Duration(seconds: 2),
                              ),
                            );
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

  void _addTextDialog() {
    final controller = TextEditingController(text: _overlayText ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF242526),
        title: const Text('Add Text', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 18),
          decoration: const InputDecoration(
            hintText: 'Type your text...',
            hintStyle: TextStyle(color: Colors.white54),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1877F2)),
            onPressed: () {
              setState(() {
                _overlayText = controller.text.trim().isEmpty ? null : controller.text.trim();
              });
              Navigator.pop(ctx);
            },
            child: const Text('Done', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openStickers() {
    final stickers = ['❤️', '🔥', '🎉', '🌟', '✨', '💐', '🌹', '😍', '👑', '💯', '🌸', '🎈'];
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF242526),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        height: 240,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose Sticker', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.count(
                crossAxisCount: 6,
                children: stickers.map((st) => InkWell(
                  onTap: () {
                    setState(() {
                      _selectedSticker = st;
                    });
                    Navigator.pop(ctx);
                  },
                  child: Center(child: Text(st, style: const TextStyle(fontSize: 32))),
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openEffects() {
    final filters = ['Original', 'Warm', 'Cool', 'Vintage', 'B&W'];
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF242526),
      builder: (ctx) => Container(
        height: 150,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Effects & Filters', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: filters.map((f) => Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ActionChip(
                    backgroundColor: _selectedFilter == f ? const Color(0xFF1877F2) : const Color(0xFF3A3B3C),
                    label: Text(f, style: const TextStyle(color: Colors.white)),
                    onPressed: () {
                      setState(() {
                        _selectedFilter = f == 'Original' ? null : f;
                      });
                      Navigator.pop(ctx);
                    },
                  ),
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _publishStory() {
    final manager = KeoStoryManager();
    final newStory = KeoStoryItem(
      id: 'story_${DateTime.now().millisecondsSinceEpoch}',
      imagePath: widget.isVideo ? null : widget.mediaFile.path,
      videoPath: widget.isVideo ? widget.mediaFile.path : null,
      musicName: _selectedMusic != null ? '${_selectedMusic!.title} • ${_selectedMusic!.artist}' : 'KeoBeat Original',
      createdAt: DateTime.now(),
    );

    manager.addStory(newStory);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('স্টোরি সফলভাবে আপলোড হয়েছে!'),
        backgroundColor: Color(0xFF31A24C),
      ),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    ColorFilter? colorFilter;
    if (_selectedFilter == 'Warm') {
      colorFilter = const ColorFilter.mode(Colors.orangeAccent, BlendMode.color);
    } else if (_selectedFilter == 'Cool') {
      colorFilter = const ColorFilter.mode(Colors.blueAccent, BlendMode.color);
    } else if (_selectedFilter == 'Vintage') {
      colorFilter = const ColorFilter.mode(Colors.amber, BlendMode.modulate);
    } else if (_selectedFilter == 'B&W') {
      colorFilter = const ColorFilter.mode(Colors.grey, BlendMode.saturation);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Media
          Positioned.fill(
            child: ColorFiltered(
              colorFilter: colorFilter ?? const ColorFilter.mode(Colors.transparent, BlendMode.dst),
              child: Image.file(
                File(widget.mediaFile.path),
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Text overlay if any
          if (_overlayText != null)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.black54,
                child: Text(
                  _overlayText!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),

          // Sticker overlay if any
          if (_selectedSticker != null)
            Positioned(
              top: 150,
              left: 40,
              child: Text(_selectedSticker!, style: const TextStyle(fontSize: 60)),
            ),

          // Music playing badge indicator
          if (_selectedMusic != null)
            Positioned(
              top: 50,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.music_note, color: Color(0xFF1877F2), size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${_selectedMusic!.title} (Playing)',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _selectedMusic = null;
                        });
                      },
                      child: const Icon(Icons.close, color: Colors.white70, size: 14),
                    ),
                  ],
                ),
              ),
            ),

          // Close Top Button
          Positioned(
            top: 44,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Facebook Style Right Action Bar (Stickers, Text, Music, Tag, Effects, Doodle)
          Positioned(
            top: 40,
            right: 12,
            child: Column(
              children: [
                _buildRightAction(Icons.emoji_emotions_outlined, 'Stickers', _openStickers),
                _buildRightAction(Icons.title, 'Text', _addTextDialog),
                _buildRightAction(Icons.music_note, 'Music', _openMusicSelector),
                _buildRightAction(Icons.person_add_alt_1_outlined, 'Tag', () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tag friend selected')),
                  );
                }),
                _buildRightAction(Icons.auto_fix_high, 'Effects', _openEffects),
                _buildRightAction(Icons.draw, 'Doodle', () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Doodle brush mode enabled')),
                  );
                }),
              ],
            ),
          ),

          // Bottom Bar: Settings & Share Now Button
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.black54,
                  radius: 22,
                  child: IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1877F2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: _publishStory,
                  icon: const Icon(Icons.send, color: Colors.white, size: 18),
                  label: const Text(
                    'Share now',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightAction(IconData icon, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0),
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.black45,
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500, shadows: [
                Shadow(color: Colors.black87, blurRadius: 4),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
