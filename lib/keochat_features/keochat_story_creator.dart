import 'dart:convert';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'keochat_story_manager.dart';
import 'keochat_music_picker.dart';
import 'package:audioplayers/audioplayers.dart';

class KeoMusicItem {
  final String title;
  final String artist;
  final String category;
  final String? url;
  final String? artwork;
  KeoMusicItem({required this.title, required this.artist, required this.category, this.url, this.artwork});
}



class StoryTextItem {
  final String id;
  String text;
  int textColor;
  int textStyleIndex;
  bool textHasBackground;
  double x;
  double y;
  double scale;
  double rotation;
  double prevScale;
  double prevRotation;
  int lastPointerCount;

  StoryTextItem({
    required this.id,
    required this.text,
    this.textColor = 0xFFFFFFFF,
    this.textStyleIndex = 0,
    this.textHasBackground = true,
    this.x = 60.0,
    this.y = 280.0,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.prevScale = 1.0,
    this.prevRotation = 0.0,
    this.lastPointerCount = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'textColor': textColor,
    'textStyleIndex': textStyleIndex,
    'textHasBackground': textHasBackground,
    'x': x,
    'y': y,
    'scale': scale,
    'rotation': rotation,
  };
}

class StoryStickerItem {
  final String id;
  String sticker;
  double x;
  double y;
  double scale;
  double rotation;
  double prevScale;
  double prevRotation;
  int lastPointerCount;

  StoryStickerItem({
    required this.id,
    required this.sticker,
    this.x = 140.0,
    this.y = 200.0,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.prevScale = 1.0,
    this.prevRotation = 0.0,
    this.lastPointerCount = 0,
  });

    Map<String, dynamic> toJson() => {
    'id': id,
    'sticker': sticker,
    'x': x,
    'y': y,
    'scale': scale,
    'rotation': rotation,
  };
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

class _KeoStoryCreatorScreenState extends State<KeoStoryCreatorScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  int _selectedDurationSeconds = 10;
  final AudioPlayer _creatorAudioPlayer = AudioPlayer();
  KeoMusicItem? _selectedMusic;
  String? _overlayText;
  String? _selectedFilter;
  final double _stickerX = 140.0;
  final double _stickerY = 180.0;
  final double _stickerScale = 1.0;
  final double _stickerRotation = 0.0;
  final List<StoryStickerItem> _stickers = [];
  final List<StoryTextItem> _texts = [];
  String? _activeTextId;
  String? _activeStickerId;
        String? _activeItem; // TikTok style active selected item ('text', 'sticker', null)

  final double _textX = 60.0;
  final double _textY = 280.0;
  final double _textScale = 1.0;
  final double _textRotation = 0.0;
  final Color _selectedTextColor = Colors.white;
  final String _selectedFontFamily = 'Classic';
  final bool _textBackground = false;

  String? _taggedFriend;
  double _tagX = 40.0;
  double _tagY = 140.0;
  double _tagScale = 1.0;
  double _baseTagScale = 1.0;

  bool _isDoodleMode = false;
  Color _selectedDoodleColor = Colors.white;
  final List<DoodlePoint?> _doodlePoints = [];

  

  void _openMusicSelector() async {
    try { await _creatorAudioPlayer.pause(); } catch (_) {}
    if (!mounted) return;
    final KeoMusicTrack? selected = await showModalBottomSheet<KeoMusicTrack>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const KeoMusicPickerSheet(),
    );

    if (selected != null && mounted) {
      setState(() {
        _selectedMusic = KeoMusicItem(
          title: selected.title,
          artist: selected.artist,
          category: 'Trending',
          url: selected.previewUrl,
          artwork: selected.artworkUrl,
        );
      });

      try {
        await _creatorAudioPlayer.stop();
        if (selected.previewUrl.isNotEmpty) {
          await _creatorAudioPlayer.setReleaseMode(ReleaseMode.loop);
          await _creatorAudioPlayer.play(UrlSource(selected.previewUrl));
        }
      } catch (_) {}

      if (!mounted) return;
    if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selected & Playing: ${selected.title} - ${selected.artist} 🎵'),
          backgroundColor: const Color(0xFF1877F2),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _addTextDialog({StoryTextItem? existingItem}) {
    final isEditing = existingItem != null;
    final controller = TextEditingController(text: isEditing ? existingItem.text : '');
    Color tempColor = isEditing ? Color(existingItem.textColor) : _selectedTextColor;
    String tempFont = isEditing ? (['Classic', 'Modern', 'Neon', 'Handwriting', 'Typewriter', 'Strong'].elementAtOrNull(existingItem.textStyleIndex) ?? 'Classic') : _selectedFontFamily;
    bool tempBg = isEditing ? existingItem.textHasBackground : _textBackground;

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
                              setModalState(() {
                                tempBg = !tempBg;
                              });
                            },
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1877F2),
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                            ),
                            onPressed: () {
                              final txt = controller.text.trim();
                              setState(() {
                                final fontIdx = ['Classic', 'Modern', 'Neon', 'Handwriting', 'Typewriter', 'Strong'].indexOf(tempFont);
                                if (isEditing) {
                                  if (txt.isEmpty) {
                                    _texts.removeWhere((t) => t.id == existingItem.id);
                                    if (_activeTextId == existingItem.id) _activeTextId = null;
                                  } else {
                                    existingItem.text = txt;
                                    existingItem.textColor = tempColor.toARGB32();
                                    existingItem.textStyleIndex = fontIdx != -1 ? fontIdx : 0;
                                    existingItem.textHasBackground = tempBg;
                                  }
                                } else if (txt.isNotEmpty) {
                                  final newItem = StoryTextItem(
                                    id: 'txt_${DateTime.now().millisecondsSinceEpoch}',
                                    text: txt,
                                    textColor: tempColor.toARGB32(),
                                    textStyleIndex: fontIdx != -1 ? fontIdx : 0,
                                    textHasBackground: tempBg,
                                    x: 80.0,
                                    y: 260.0 + (_texts.length * 40.0),
                                  );
                                  _texts.add(newItem);
                                  _activeItem = 'text';
                                  _activeTextId = newItem.id;
                                }
                                _overlayText = _texts.isNotEmpty ? _texts.first.text : null;
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
                        final newSticker = StoryStickerItem(
                          id: 'st_${DateTime.now().millisecondsSinceEpoch}_${_stickers.length}',
                          sticker: st,
                          x: 100.0 + (_stickers.length * 20.0) % 100,
                          y: 180.0 + (_stickers.length * 25.0) % 120,
                        );
                        setState(() {
                          _stickers.add(newSticker);
                          
                          _activeItem = 'sticker';
                          _activeStickerId = newSticker.id;
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
                            child: Text(f["initial"] ?? "U", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                          title: Text(f["name"] ?? "", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Text(f["badge"] ?? "Friend", style: const TextStyle(color: Colors.white70, fontSize: 12)),
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

  
  void _openDurationSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1C1E21),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final options = [
          {'seconds': 5, 'label': '5 Seconds', 'desc': 'Quick flash'},
          {'seconds': 10, 'label': '10 Seconds', 'desc': 'Standard story (Default)'},
          {'seconds': 15, 'label': '15 Seconds', 'desc': 'Classic pace'},
          {'seconds': 20, 'label': '20 Seconds', 'desc': 'Extended view'},
          {'seconds': 30, 'label': '30 Seconds', 'desc': 'Deep reading'},
          {'seconds': 60, 'label': '60 Seconds (1 Min)', 'desc': 'Maximum allowed time'},
        ];

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 18,
              right: 18,
              top: 16,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.timer, color: Color(0xFF1877F2), size: 24),
                      const SizedBox(width: 10),
                      const Text(
                        'Story Duration',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Set how long friends can view this story (Max 1 minute)',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
                  ),
                  const SizedBox(height: 14),
                  ...options.map((opt) {
                    final sec = opt['seconds'] as int;
                    final isSelected = _selectedDurationSeconds == sec;
                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        setState(() {
                          _selectedDurationSeconds = sec;
                        });
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF1877F2).withValues(alpha: 0.2) : Colors.white10,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF1877F2) : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                              color: isSelected ? const Color(0xFF1877F2) : Colors.white38,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  opt['label'] as String,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.85),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  opt['desc'] as String,
                                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _publishStory() async {
    final manager = KeoStoryManager();
    final newStory = KeoStoryItem(
      id: 'story_${DateTime.now().millisecondsSinceEpoch}',
      imagePath: widget.isVideo ? null : widget.mediaFile.path,
      videoPath: widget.isVideo ? widget.mediaFile.path : null,
      musicName: _selectedMusic?.title ?? 'KeoBeat Original',
      musicArtist: _selectedMusic?.artist,
      musicUrl: _selectedMusic?.url,
      text: _texts.isNotEmpty ? _texts.first.text : _overlayText,
      textsJson: _texts.isNotEmpty ? jsonEncode(_texts.map((t) => t.toJson()).toList()) : null,
      textColor: _selectedTextColor.toARGB32(),
      textStyleIndex: ['Classic', 'Modern', 'Neon', 'Handwriting', 'Typewriter', 'Strong'].indexOf(_selectedFontFamily),
      textHasBackground: _textBackground,
      textX: _texts.isNotEmpty ? _texts.first.x : _textX,
      textY: _texts.isNotEmpty ? _texts.first.y : _textY,
      textScale: _texts.isNotEmpty ? _texts.first.scale : _textScale,
      textRotation: _texts.isNotEmpty ? _texts.first.rotation : _textRotation,
      sticker: _stickers.isNotEmpty ? _stickers.first.sticker : null,
      stickersJson: _stickers.isNotEmpty ? jsonEncode(_stickers.map((s) => s.toJson()).toList()) : null,
      stickerX: _stickers.isNotEmpty ? _stickers.first.x : _stickerX,
      stickerY: _stickers.isNotEmpty ? _stickers.first.y : _stickerY,
      stickerScale: _stickers.isNotEmpty ? _stickers.first.scale : _stickerScale,
      stickerRotation: _stickers.isNotEmpty ? _stickers.first.rotation : _stickerRotation,
      filter: _selectedFilter,
      durationSeconds: _selectedDurationSeconds,
      taggedFriend: _taggedFriend,
      tagX: _tagX,
      tagY: _tagY,
      tagScale: _tagScale,
      createdAt: DateTime.now(),
    );

    try {
      await _creatorAudioPlayer.stop();
    } catch (_) {}

    manager.addStory(newStory);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Story shared successfully!'),
        backgroundColor: Color(0xFF31A24C),
      ),
    );
    if (!mounted) return;
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

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          try { _creatorAudioPlayer.stop(); } catch (_) {}
        }
      },
      child: Scaffold(
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
          // Tap anywhere on background to deselect item (removes border and delete button)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (_activeItem != null || _activeStickerId != null) {
                  setState(() {
                    _activeItem = null;
                    _activeStickerId = null;
                  });
                }
              },
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

          // TikTok Style Multi-Text Overlay with Double Tap to Edit, Sharp Border & Delete Tooltip
          for (final txtItem in _texts)
            Positioned(
              top: txtItem.y,
              left: txtItem.x,
              child: Transform.rotate(
                angle: txtItem.rotation,
                child: Transform.scale(
                  scale: txtItem.scale,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() {
                      _activeItem = 'text';
                      _activeTextId = txtItem.id;
                    }),
                    onDoubleTap: () => _addTextDialog(existingItem: txtItem),
                    onScaleStart: (details) {
                      txtItem.prevScale = 1.0;
                      txtItem.prevRotation = 0.0;
                      txtItem.lastPointerCount = details.pointerCount;
                      setState(() {
                        _activeItem = 'text';
                        _activeTextId = txtItem.id;
                      });
                    },
                    onScaleUpdate: (details) {
                      setState(() {
                        txtItem.x += details.focalPointDelta.dx;
                        txtItem.y += details.focalPointDelta.dy;
                        if (details.pointerCount >= 2 || txtItem.lastPointerCount >= 2) {
                          if (details.scale != 1.0) {
                            final deltaScale = details.scale / txtItem.prevScale;
                            txtItem.scale = (txtItem.scale * deltaScale).clamp(0.4, 5.0);
                            txtItem.prevScale = details.scale;
                          }
                          if (details.rotation != 0.0) {
                            final deltaRotation = details.rotation - txtItem.prevRotation;
                            txtItem.rotation += deltaRotation;
                            txtItem.prevRotation = details.rotation;
                          }
                        }
                      });
                    },
                    child: Container(
                      padding: txtItem.textHasBackground
                          ? const EdgeInsets.symmetric(horizontal: 14, vertical: 8)
                          : const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: txtItem.textHasBackground
                            ? Colors.black.withValues(alpha: 0.65)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: (_activeItem == 'text' && _activeTextId == txtItem.id)
                            ? Border.all(color: Colors.white, width: (2.0 / txtItem.scale).clamp(0.6, 2.5))
                            : null,
                      ),
                      child: Text(
                        txtItem.text,
                        textAlign: TextAlign.center,
                        style: _getStoryTextStyle(
                          ['Classic', 'Modern', 'Neon', 'Handwriting', 'Typewriter', 'Strong'].elementAtOrNull(txtItem.textStyleIndex) ?? 'Classic',
                          Color(txtItem.textColor),
                          fontSize: 24,
                        ).copyWith(
                          shadows: const [
                            Shadow(color: Colors.black87, blurRadius: 8, offset: Offset(0, 1)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Separate Independent Delete Button for Active Text
          if (_activeItem == 'text' && _activeTextId != null) ...[
            for (final txtItem in _texts)
              if (txtItem.id == _activeTextId)
                Positioned(
                  top: (txtItem.y - (28 * txtItem.scale) - 35).clamp(60.0, MediaQuery.of(context).size.height - 120),
                  left: (txtItem.x + 20).clamp(20.0, MediaQuery.of(context).size.width - 110),
                  child: TikTokDeleteTooltip(
                    currentScale: 1.0,
                    onDelete: () {
                      setState(() {
                        _texts.removeWhere((t) => t.id == txtItem.id);
                        _activeTextId = null;
                        _activeItem = null;
                        _overlayText = _texts.isNotEmpty ? _texts.first.text : null;
                      });
                    },
                  ),
                ),
          ],

          // TikTok Style Multi-Sticker Overlay with Sharp Border & HitTest
          for (final stItem in _stickers)
            Positioned(
              top: stItem.y,
              left: stItem.x,
              child: Transform.rotate(
                angle: stItem.rotation,
                child: Transform.scale(
                  scale: stItem.scale,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() {
                      _activeItem = 'sticker';
                      _activeStickerId = stItem.id;
                    }),
                    onScaleStart: (details) {
                      stItem.prevScale = 1.0;
                      stItem.prevRotation = 0.0;
                      stItem.lastPointerCount = details.pointerCount;
                      setState(() {
                        _activeItem = 'sticker';
                        _activeStickerId = stItem.id;
                      });
                    },
                    onScaleUpdate: (details) {
                      setState(() {
                        stItem.x += details.focalPointDelta.dx;
                        stItem.y += details.focalPointDelta.dy;

                        if (details.pointerCount >= 2) {
                          if (stItem.lastPointerCount < 2) {
                            stItem.prevScale = details.scale;
                            stItem.prevRotation = details.rotation;
                          } else {
                            final double scaleDelta = stItem.prevScale > 0.0001 ? (details.scale / stItem.prevScale) : 1.0;
                            final double rotationDelta = details.rotation - stItem.prevRotation;

                            stItem.scale = (stItem.scale * scaleDelta).clamp(0.4, 4.5);
                            stItem.rotation += rotationDelta;

                            stItem.prevScale = details.scale;
                            stItem.prevRotation = details.rotation;
                          }
                        } else {
                          stItem.prevScale = 1.0;
                          stItem.prevRotation = 0.0;
                        }
                        stItem.lastPointerCount = details.pointerCount;
                      });
                    },
                    onScaleEnd: (details) {
                      stItem.prevScale = 1.0;
                      stItem.prevRotation = 0.0;
                      stItem.lastPointerCount = 0;
                    },
                    child: Container(
                      width: 120,
                      height: 120,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0x01000000),
                        border: (_activeItem == 'sticker' && _activeStickerId == stItem.id)
                            ? Border.all(color: Colors.white, width: (1.5 / stItem.scale).clamp(0.3, 3.0))
                            : null,
                      ),
                      child: Text(
                        stItem.sticker,
                        style: const TextStyle(
                          fontSize: 60,
                          shadows: [
                            Shadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 3)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Separate Independent Delete Button for Active Sticker (Always clickable at any scale)
          if (_activeItem == 'sticker' && _activeStickerId != null) ...[
            for (final stItem in _stickers)
              if (stItem.id == _activeStickerId)
                Positioned(
                  top: (stItem.y + 60 - (60 * stItem.scale) - 46).clamp(60.0, MediaQuery.of(context).size.height - 120),
                  left: (stItem.x + 60 - 45).clamp(20.0, MediaQuery.of(context).size.width - 110),
                  child: TikTokDeleteTooltip(
                    currentScale: 1.0,
                    onDelete: () {
                      setState(() {
                        _stickers.removeWhere((s) => s.id == stItem.id);
                        if (_stickers.isEmpty) {
                          
                        } else {
                          
                        }
                        _activeStickerId = null;
                        _activeItem = null;
                      });
                    },
                  ),
                ),
          ],

          if (_taggedFriend != null) ...[
            Positioned(
              top: _tagY,
              left: _tagX,
              child: GestureDetector(
                onScaleStart: (details) {
                  _baseTagScale = _tagScale;
                },
                onScaleUpdate: (details) {
                  setState(() {
                    _tagX += details.focalPointDelta.dx;
                    _tagY += details.focalPointDelta.dy;
                    if (details.scale != 1.0) {
                      _tagScale = (_baseTagScale * details.scale).clamp(0.5, 3.5);
                    }
                  });
                },
                onScaleEnd: (details) {
                  _baseTagScale = _tagScale;
                },
                child: Transform.scale(
                  scale: _tagScale,
                  child: Container(
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
                        const Icon(Icons.person, color: Color(0xFF1877F2), size: 16),
                        const SizedBox(width: 6),
                        Text(
                          _taggedFriend!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: (_tagY - 36).clamp(50.0, MediaQuery.of(context).size.height - 120),
              left: _tagX.clamp(16.0, MediaQuery.of(context).size.width - 90),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _taggedFriend = null),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2))
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.delete_outline, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text('Delete', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
                onPressed: () async {
                  try { await _creatorAudioPlayer.stop(); } catch (_) {}
                  if (context.mounted) Navigator.pop(context);
                },
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
                _buildRightAction(Icons.timer_outlined, '${_selectedDurationSeconds}s', _openDurationSelector),
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      try { _creatorAudioPlayer.pause(); } catch (_) {}
    } else if (state == AppLifecycleState.resumed && _selectedMusic != null) {
      try { _creatorAudioPlayer.resume(); } catch (_) {}
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    try {
      _creatorAudioPlayer.stop();
      _creatorAudioPlayer.dispose();
    } catch (_) {}
    super.dispose();
  }
}

// TikTok Style Speech-Bubble Delete Tooltip (Fixed UI scale regardless of sticker/text zoom)
class TikTokDeleteTooltip extends StatelessWidget {
  final VoidCallback onDelete;
  final double currentScale;

  const TikTokDeleteTooltip({super.key, required this.onDelete, required this.currentScale});

  @override
  Widget build(BuildContext context) {
    final counterScale = currentScale > 0 ? (1.0 / currentScale) : 1.0;

    return Transform.scale(
      scale: counterScale,
      alignment: Alignment.bottomCenter,
      child: GestureDetector(
        onTap: onDelete,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xEE333333),
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(color: Colors.black54, blurRadius: 6, offset: Offset(0, 2)),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete_outline_rounded, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Delete',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
            CustomPaint(
              size: const Size(10, 5),
              painter: _TrianglePainter(const Color(0xEE333333)),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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