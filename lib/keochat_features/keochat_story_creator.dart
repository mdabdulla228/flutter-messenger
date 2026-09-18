import 'dart:ui';
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
  double _stickerX = 140.0;
  double _stickerY = 180.0;
  double _stickerScale = 1.0;

  double _textX = 60.0;
  double _textY = 280.0;
  double _textScale = 1.0;
  Color _selectedTextColor = Colors.white;
  String _selectedFontFamily = 'Classic';
  bool _textBackground = true;

  String? _taggedFriend;
  double _tagX = 40.0;
  double _tagY = 140.0;
  double _tagScale = 1.0;

  bool _isDoodleMode = false;
  Color _selectedDoodleColor = Colors.white;
  final List<DoodlePoint?> _doodlePoints = [];

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
    Color tempColor = _selectedTextColor;
    String tempFont = _selectedFontFamily;
    bool tempBg = _textBackground;

    final fonts = ['Classic', 'Modern', 'Neon', 'Handwriting', 'Typewriter', 'Strong'];
    final colors = [
      Colors.white,
      Colors.black,
      const Color(0xFF1877F2),
      Colors.amber,
      Colors.redAccent,
      Colors.pinkAccent,
      Colors.greenAccent,
      Colors.purpleAccent,
      Colors.orangeAccent,
      Colors.cyanAccent,
    ];

    TextStyle getStyle(String fontName, Color color, {double fontSize = 22}) {
      switch (fontName) {
        case 'Modern':
          return TextStyle(color: color, fontSize: fontSize, fontWeight: FontWeight.w900, letterSpacing: 1.2);
        case 'Neon':
          return TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(color: color.withValues(alpha: 0.9), blurRadius: 16),
              Shadow(color: Colors.white.withValues(alpha: 0.8), blurRadius: 8),
            ],
          );
        case 'Handwriting':
          return TextStyle(color: color, fontSize: fontSize, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600);
        case 'Typewriter':
          return TextStyle(color: color, fontSize: fontSize, fontFamily: 'monospace', fontWeight: FontWeight.w600);
        case 'Strong':
          return TextStyle(color: color, fontSize: fontSize, fontWeight: FontWeight.bold, letterSpacing: -0.5);
        case 'Classic':
        default:
          return TextStyle(color: color, fontSize: fontSize, fontWeight: FontWeight.w700);
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black.withValues(alpha: 0.88),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Top Bar: Cancel, Background Toggle, Done
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel', style: TextStyle(color: Colors.white70, fontSize: 16)),
                          ),
                          IconButton(
                            icon: Icon(
                              tempBg ? Icons.font_download : Icons.font_download_outlined,
                              color: tempBg ? const Color(0xFF1877F2) : Colors.white,
                            ),
                            tooltip: 'Toggle Background',
                            onPressed: () {
                            },
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1877F2),
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                            ),
                            onPressed: () {
                              setState(() {
                                _overlayText = controller.text.trim().isEmpty ? null : controller.text.trim();
                                _selectedTextColor = tempColor;
                                _selectedFontFamily = tempFont;
                                _textBackground = tempBg;
                              });
                              Navigator.pop(ctx);
                            },
                            child: const Text('Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Live Preview Box
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 90),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: tempBg ? Colors.black.withValues(alpha: 0.55) : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          controller: controller,
                          autofocus: true,
                          textAlign: TextAlign.center,
                          maxLines: null,
                          cursorColor: const Color(0xFF1877F2),
                          style: getStyle(tempFont, tempColor, fontSize: 24),
                          decoration: const InputDecoration(
                            hintText: 'Type something...',
                            hintStyle: TextStyle(color: Colors.white38, fontSize: 22),
                            border: InputBorder.none,
                          ),
                          onChanged: (_) => setModalState(() {}),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Font Selector Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: fonts.map((f) {
                            final isSel = tempFont == f;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: ChoiceChip(
                                label: Text(f),
                                selected: isSel,
                                selectedColor: const Color(0xFF1877F2),
                                backgroundColor: const Color(0xFF242526),
                                labelStyle: TextStyle(
                                  color: isSel ? Colors.white : Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                onSelected: (sel) {
                                  if (sel) setModalState(() => tempFont = f);
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Color Palette Bubbles
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: colors.map((c) {
                            final isSel = tempColor == c;
                            return GestureDetector(
                              onTap: () => setModalState(() => tempColor = c),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: c,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSel ? Colors.white : Colors.white38,
                                    width: isSel ? 3 : 1.5,
                                  ),
                                  boxShadow: [
                                    if (isSel) BoxShadow(color: c.withValues(alpha: 0.8), blurRadius: 8),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openStickers() {
    final stickers = [
      '💕', '😍', '🔥', '💋', '😘', '✨',
      '🥰', '❤️', '😎', '😂', '😜', '😋',
      '🌹', '👌', '💙', '💔', '🌺', '😭',
      '🌸', '😁', '🌼', '😈', '✌️', '👑',
      '😝', '👻', '😅', '😇', '😊', '💪',
      '👉', '😢', '😏', '☺️', '😉', '😔',
      '😛', '😻', '🎂', '💀', '👍', '😱',
      '👽', '🐷', '😥', '😬', '🙂', '😪',
      '😀', '😃', '😞', '😒', '😌', '😡',
      '🎉', '🎈', '⭐', '💯', '💐', '🦋'
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.55,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 12),
            const Text('Stickers & Emojis', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: stickers.length,
                itemBuilder: (context, idx) {
                  final st = stickers[idx];
                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      setState(() {
                        _selectedSticker = st;
                        _stickerX = 140.0;
                        _stickerY = 220.0;
                        _stickerScale = 1.0;
                      });
                      Navigator.pop(ctx);
                    },
                    child: Center(child: Text(st, style: const TextStyle(fontSize: 34))),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _getStoryTextStyle(String fontName, Color color, {double fontSize = 24}) {
    switch (fontName) {
      case 'Modern':
        return TextStyle(color: color, fontSize: fontSize, fontWeight: FontWeight.w900, letterSpacing: 1.2);
      case 'Neon':
        return TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(color: color.withValues(alpha: 0.9), blurRadius: 16),
            Shadow(color: Colors.white.withValues(alpha: 0.8), blurRadius: 8),
          ],
        );
      case 'Handwriting':
        return TextStyle(color: color, fontSize: fontSize, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600);
      case 'Typewriter':
        return TextStyle(color: color, fontSize: fontSize, fontFamily: 'monospace', fontWeight: FontWeight.w600);
      case 'Strong':
        return TextStyle(color: color, fontSize: fontSize, fontWeight: FontWeight.bold, letterSpacing: -0.5);
      case 'Classic':
      default:
        return TextStyle(color: color, fontSize: fontSize, fontWeight: FontWeight.w700);
    }
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

  void _openTagFriends() {
    final friends = [
      {'name': 'Tanvir Hasan', 'badge': 'Best Friend', 'initial': 'T'},
      {'name': 'Ayesha Siddika', 'badge': 'Close Friend', 'initial': 'A'},
      {'name': 'Rahim Ahmed', 'badge': 'Family', 'initial': 'R'},
      {'name': 'Karim Ullah', 'badge': 'Colleague', 'initial': 'K'},
      {'name': 'Nabila Islam', 'badge': 'School Friend', 'initial': 'N'},
      {'name': 'Sakib Al Hasan', 'badge': 'Celebrity', 'initial': 'S'},
      {'name': 'Mehedi Miraz', 'badge': 'Sports', 'initial': 'M'},
    ];
    String query = '';

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF242526),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = friends.where((f) => f['name']!.toLowerCase().contains(query.toLowerCase())).toList();
            return Container(
              height: MediaQuery.of(context).size.height * 0.65,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white30,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tag People',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      if (_taggedFriend != null)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _taggedFriend = null;
                            });
                            setModalState(() {});
                          },
                          child: const Text('Remove Tag', style: TextStyle(color: Colors.redAccent)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search friends...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      prefixIcon: const Icon(Icons.search, color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF3A3B3C),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (val) {
                      setModalState(() {
                        query = val;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, i) {
                        final f = filtered[i];
                        final isTagged = _taggedFriend == f['name'];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF1877F2),
                          ),
                          trailing: Icon(isTagged ? Icons.check_circle : Icons.add_circle_outline, color: isTagged ? const Color(0xFF1877F2) : Colors.white70),
                          onTap: () {
                            setState(() {
                              _taggedFriend = f['name'];
                              _tagX = 40.0;
                              _tagY = 140.0;
                              _tagScale = 1.0;
                            });
                            Navigator.pop(ctx);
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

  void _publishStory() {
    final manager = KeoStoryManager();
    final newStory = KeoStoryItem(
      id: 'story_${DateTime.now().millisecondsSinceEpoch}',
      imagePath: widget.isVideo ? null : widget.mediaFile.path,
      videoPath: widget.isVideo ? widget.mediaFile.path : null,
      musicName: _selectedMusic?.title ?? 'KeoBeat Original',
      musicArtist: _selectedMusic?.artist,
      musicUrl: null,
      text: _overlayText,
      textColor: _selectedTextColor.toARGB32(),
      textStyleIndex: ['Classic', 'Modern', 'Neon', 'Handwriting', 'Typewriter', 'Strong'].indexOf(_selectedFontFamily),
      textHasBackground: _textBackground,
      textX: _textX,
      textY: _textY,
      textScale: _textScale,
      sticker: _selectedSticker,
      stickerX: _stickerX,
      stickerY: _stickerY,
      stickerScale: _stickerScale,
      filter: _selectedFilter,
      createdAt: DateTime.now(),
    );

    manager.addStory(newStory);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Story shared successfully!'),
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
          // Adaptive Background matching image colors (Facebook style)
          Positioned.fill(
            child: Image.file(
              File(widget.mediaFile.path),
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.45),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: const SizedBox.expand(),
            ),
          ),
          // Center Main Media with Selected Filter
          Positioned.fill(
            child: Center(
              child: ColorFiltered(
                colorFilter: colorFilter ?? const ColorFilter.mode(Colors.transparent, BlendMode.dst),
                child: Image.file(
                  File(widget.mediaFile.path),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // Draggable & Resizable Text overlay (Styled Font, Color & Background)
          if (_overlayText != null)
            Positioned(
              top: _textY,
              left: _textX,
              child: GestureDetector(
                onDoubleTap: _addTextDialog,
                onScaleUpdate: (details) {
                  setState(() {
                    _textX += details.focalPointDelta.dx;
                    _textY += details.focalPointDelta.dy;
                    if (details.scale != 1.0) {
                      _textScale = (_textScale * details.scale).clamp(0.5, 4.0);
                    }
                  });
                },
                child: Transform.scale(
                  scale: _textScale,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: _textBackground ? Colors.black.withValues(alpha: 0.65) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: _textBackground ? Border.all(color: Colors.white24) : null,
                        ),
                        child: Text(
                          _overlayText ?? '',
                          textAlign: TextAlign.center,
                          style: _getStoryTextStyle(_selectedFontFamily, _selectedTextColor, fontSize: 24),
                        ),
                      ),
                      Positioned(
                        top: -10,
                        right: -10,
                        child: GestureDetector(
                          onTap: () => setState(() => _overlayText = null),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.black87,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Draggable & Resizable Sticker overlay
          if (_selectedSticker != null)
            Positioned(
              top: _stickerY,
              left: _stickerX,
              child: GestureDetector(
                onScaleUpdate: (details) {
                  setState(() {
                    _stickerX += details.focalPointDelta.dx;
                    _stickerY += details.focalPointDelta.dy;
                    if (details.scale != 1.0) {
                      _stickerScale = (_stickerScale * details.scale).clamp(0.5, 4.0);
                    }
                  });
                },
                child: Transform.scale(
                  scale: _stickerScale,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(_selectedSticker!,
                          style: const TextStyle(
                            fontSize: 60,
                            shadows: [
                              Shadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 3)),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedSticker = null),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.black87,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Draggable Tag Friend Sticker Overlay (Facebook Style)
          if (_taggedFriend != null)
            Positioned(
              top: _tagY,
              left: _tagX,
              child: GestureDetector(
                onScaleUpdate: (details) {
                  setState(() {
                    _tagX += details.focalPointDelta.dx;
                    _tagY += details.focalPointDelta.dy;
                    if (details.scale != 1.0) {
                      _tagScale = (_tagScale * details.scale).clamp(0.6, 3.0);
                    }
                  });
                },
                child: Transform.scale(
                  scale: _tagScale,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF1877F2), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.person, color: Color(0xFF1877F2), size: 18),
                            const SizedBox(width: 6),
                            Text(
                              '@${_taggedFriend!}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: -8,
                        right: -8,
                        child: GestureDetector(
                          onTap: () => setState(() => _taggedFriend = null),
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Colors.black87,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Freehand Doodle Drawing Canvas
          Positioned.fill(
            child: IgnorePointer(
              child: GestureDetector(
                onPanStart: (details) {
                  setState(() {
                    _doodlePoints.add(DoodlePoint(point: details.localPosition, color: _selectedDoodleColor));
                  });
                },
                onPanUpdate: (details) {
                  setState(() {
                    _doodlePoints.add(DoodlePoint(point: details.localPosition, color: _selectedDoodleColor));
                  });
                },
                onPanEnd: (details) {
                  setState(() {
                    _doodlePoints.add(null);
                  });
                },
                child: CustomPaint(
                  painter: DoodlePainter(_doodlePoints),
                  size: Size.infinite,
                ),
              ),
            ),
          ),

          // Facebook Style Doodle Toolbar (Colors, Undo, Clear, Done)
          if (_isDoodleMode)
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.undo, color: Colors.white),
                    onPressed: () {
                      if (_doodlePoints.isNotEmpty) {
                        setState(() {
                          int lastNull = _doodlePoints.lastIndexOf(null);
                          if (lastNull != -1 && lastNull == _doodlePoints.length - 1) {
                            _doodlePoints.removeLast();
                            lastNull = _doodlePoints.lastIndexOf(null);
                          }
                          if (lastNull != -1) {
                            _doodlePoints.removeRange(lastNull + 1, _doodlePoints.length);
                          } else {
                            _doodlePoints.clear();
                          }
                        });
                      }
                    },
                  ),
                  TextButton(
                    onPressed: () => setState(() => _doodlePoints.clear()),
                    child: const Text('Clear All', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1877F2),
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    onPressed: () => setState(() => _isDoodleMode = false),
                    child: const Text('Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

          if (_isDoodleMode)
            Positioned(
              bottom: 30,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Colors.white,
                    Colors.black,
                    const Color(0xFF1877F2),
                    Colors.redAccent,
                    Colors.greenAccent,
                    Colors.amberAccent,
                    Colors.purpleAccent,
                  ].map((c) {
                    final isSelected = _selectedDoodleColor == c;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedDoodleColor = c),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.transparent,
                            width: isSelected ? 3 : 1,
                          ),
                          boxShadow: [
                            if (isSelected) const BoxShadow(color: Colors.white54, blurRadius: 6),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

          // Music playing badge indicator
          if (_selectedMusic != null)
            Positioned(
              top: 50,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
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
                _buildRightAction(Icons.person_add_alt_1_outlined, 'Tag', _openTagFriends),
                _buildRightAction(Icons.auto_fix_high, 'Effects', _openEffects),
                _buildRightAction(Icons.draw, 'Doodle', () {
                  setState(() {
                  });
                }),
              ],
            ),
          ),

          // Bottom Bar: Facebook Style Share Now Button
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 20,
            right: 16,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1877F2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
                elevation: 4,
              ),
              onPressed: _publishStory,
              icon: const Icon(Icons.send, color: Colors.white, size: 18),
              label: const Text(
                'Share now',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
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


class DoodlePoint {
  final Offset point;
  final Color color;
  final double strokeWidth;
  DoodlePoint({required this.point, required this.color, this.strokeWidth = 4.0});
}

class DoodlePainter extends CustomPainter {
  final List<DoodlePoint?> points;
  DoodlePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        final paint = Paint()
          ..color = points[i]!.color
          ..strokeCap = StrokeCap.round
          ..strokeWidth = points[i]!.strokeWidth;
        canvas.drawLine(points[i]!.point, points[i + 1]!.point, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant DoodlePainter oldDelegate) => true;
}
