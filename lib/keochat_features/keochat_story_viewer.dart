import 'keochat_room_screen.dart';
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:audioplayers/audioplayers.dart';
import 'keochat_story_manager.dart';

class FloatingReaction {
  final Key key = UniqueKey();
  final String emoji;
  final double startX;
  FloatingReaction({required this.emoji, required this.startX});
}

class KeoStoryViewerScreen extends StatefulWidget {
  final bool isMyStory;
  final String userName;
  final String userInitial;
  final List<KeoStoryItem> stories;

  const KeoStoryViewerScreen({
    super.key,
    required this.isMyStory,
    required this.userName,
    required this.userInitial,
    required this.stories,
  });

  @override
  State<KeoStoryViewerScreen> createState() => _KeoStoryViewerScreenState();
}

class _KeoStoryViewerScreenState extends State<KeoStoryViewerScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  void _playStoryMusic() async {
    try {
      await _audioPlayer.stop();
      if (widget.stories.isEmpty || _currentIndex >= widget.stories.length) return;
      final currentStory = widget.stories[_currentIndex];
      final url = currentStory.musicUrl;
      if (url != null && url.isNotEmpty) {
        await _audioPlayer.play(UrlSource(url));
      }
    } catch (_) {}
  }

  int _currentIndex = 0;
  Timer? _storyTimer;
  double _progress = 0.0;
  bool _isPaused = false;
  final List<FloatingReaction> _floatingReactions = [];
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();

  final List<Map<String, String>> _sampleFriends = const [
    {'name': 'Sadia Afrin', 'initial': 'S', 'time': '2m ago'},
    {'name': 'Tanvir Ahmed', 'initial': 'T', 'time': '15m ago'},
    {'name': 'Rahim Khan', 'initial': 'R', 'time': '1h ago'},
    {'name': 'Maya Hossain', 'initial': 'M', 'time': '2h ago'},
  ];

  @override
  void initState() {
    super.initState();
    _playStoryMusic();
    _startStoryProgress();
    _commentFocusNode.addListener(() {
      if (_commentFocusNode.hasFocus) {
        _pauseStory(); // Pause story when user taps comment textfield
      } else {
        _resumeStory(); // Resume story if user leaves textfield without commenting
      }
    });
  }

  void _startStoryProgress() {
    _storyTimer?.cancel();
    try { _audioPlayer.stop(); _audioPlayer.dispose(); } catch (_) {}
    _storyTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) return;
      if (_isPaused) return; // Paused when pressed and held

      setState(() {
        _progress += 0.01;
        if (_progress >= 1.0) {
          _progress = 0.0;
          if (_currentIndex < widget.stories.length - 1) {
            _currentIndex++;
          } else {
            _storyTimer?.cancel();
            Navigator.pop(context);
          }
        }
      });
    });
  }

  void _pauseStory() {
    setState(() {
      _isPaused = true;
    });
  }

  void _resumeStory() {
    setState(() {
      _isPaused = false;
    });
  }

  @override
  void dispose() {
    _storyTimer?.cancel();
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  void _addFloatingReaction(String emoji) {
    final randomX = 0.5 + (math.Random().nextDouble() * 0.4 - 0.2);
    setState(() {
      _floatingReactions.add(FloatingReaction(emoji: emoji, startX: randomX));
    });
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        setState(() {
          if (_floatingReactions.isNotEmpty) _floatingReactions.removeAt(0);
        });
      }
    });
  }

  void _confirmDeleteStory(KeoStoryItem story) {
    _pauseStory();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF242526),
        title: const Text('Delete story?', style: TextStyle(color: Colors.white, fontSize: 18)),
        content: const Text(
          'Are you sure you want to delete this story? It will be removed for everyone.',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _resumeStory();
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              KeoStoryManager().deleteStory(story.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Story deleted successfully')),
              );
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showViewersSheet(KeoStoryItem story) {
    _pauseStory();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1E21),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Story Viewers (${_sampleFriends.length})',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Icon(Icons.remove_red_eye, color: Colors.white70, size: 18),
                ],
              ),
              const SizedBox(height: 12),
              ..._sampleFriends.map((f) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(0xFF0084FF),
                      child: Text(f['initial']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(f['name']!, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                    ),
                    Text(f['time']!, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                  ],
                ),
              )),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    ).then((_) {
      if (mounted) _resumeStory();
    });
  }

  void _validateAndSendComment(String text) {
    final words = text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.length > 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('সর্বোচ্চ ২০ টি শব্দের মধ্যে কমেন্ট লিখুন'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    if (words.isNotEmpty) {
      final commentMsg = text.trim();
      _commentController.clear();
      FocusScope.of(context).unfocus();
      
      // Close story and navigate directly to chat room with story reply!
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => KeoChatRoomScreen(
            friendName: widget.userName,
            initial: widget.userInitial,
            storyReplyText: commentMsg,
            storyReplyAuthor: widget.userName,
            storyImagePath: widget.stories[_currentIndex].imagePath,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stories.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Text('No story available', style: TextStyle(color: Colors.white))),
      );
    }
    final currentStory = widget.stories[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onLongPressStart: (_) => _pauseStory(), // Press and hold: time pauses!
        onLongPressEnd: (_) => _resumeStory(),   // Release hold: time resumes!
        onTapUp: (details) {
          final width = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < width * 0.3) {
            if (_currentIndex > 0) {
              setState(() {
                _currentIndex--;
                _progress = 0.0;
              });
            }
          } else if (details.globalPosition.dx > width * 0.7) {
            if (_currentIndex < widget.stories.length - 1) {
              setState(() {
                _currentIndex++;
                _progress = 0.0;
              });
            } else {
              Navigator.pop(context);
            }
          }
        },
        child: Stack(
          children: [
            // 1. Story Media in Center with Effects & Overlays
            if (currentStory.imagePath != null && File(currentStory.imagePath!).existsSync()) ...[
              // Adaptive Background matching image colors (Facebook style)
              Positioned.fill(
                child: Image.file(
                  File(currentStory.imagePath!),
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.4),
                ),
              ),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: const SizedBox.expand(),
                ),
              ),
            ],
            Positioned.fill(
              child: Builder(
                builder: (context) {
                  ColorFilter? colorFilter;
                  if (currentStory.filter == 'Warm') {
                    colorFilter = const ColorFilter.mode(Colors.orangeAccent, BlendMode.color);
                  } else if (currentStory.filter == 'Cool') {
                    colorFilter = const ColorFilter.mode(Colors.blueAccent, BlendMode.color);
                  } else if (currentStory.filter == 'Vintage') {
                    colorFilter = const ColorFilter.mode(Colors.amber, BlendMode.modulate);
                  } else if (currentStory.filter == 'B&W') {
                    colorFilter = const ColorFilter.mode(Colors.grey, BlendMode.saturation);
                  }

                  final hasImage = currentStory.imagePath != null && File(currentStory.imagePath!).existsSync();
                  Widget mediaWidget;

                  if (hasImage) {
                    final file = File(currentStory.imagePath!);
                    mediaWidget = Center(
                      child: Image.file(
                        file,
                        fit: BoxFit.contain,
                      ),
                    );
                  } else {
                    mediaWidget = Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.auto_awesome, color: Colors.white70, size: 54),
                            const SizedBox(height: 12),
                            Text(
                              'KeoChat Story',
                              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (colorFilter != null) {
                    mediaWidget = ColorFiltered(colorFilter: colorFilter, child: mediaWidget);
                  }
                  return mediaWidget;
                },
              ),
            ),

            // Text overlay only if present and non-empty
            if (currentStory.text != null && currentStory.text!.trim().isNotEmpty)
              Positioned(
                top: currentStory.textY,
                left: currentStory.textX,
                child: Transform.rotate(
                  angle: currentStory.textRotation,
                  child: Transform.scale(
                    scale: currentStory.textScale,
                    child: Builder(
                      builder: (context) {
                        final textColor = Color(currentStory.textColor);
                        final fontIdx = currentStory.textStyleIndex;
                        TextStyle style;
                        switch (fontIdx) {
                          case 1:
                            style = TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1.2);
                            break;
                          case 2:
                            style = TextStyle(
                              color: textColor,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(color: textColor.withOpacity(0.9), blurRadius: 16),
                                const Shadow(color: Colors.white, blurRadius: 8),
                              ],
                            );
                            break;
                          case 3:
                            style = TextStyle(color: textColor, fontSize: 24, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600);
                            break;
                          case 4:
                            style = TextStyle(color: textColor, fontSize: 24, fontFamily: 'monospace', fontWeight: FontWeight.w600);
                            break;
                          case 5:
                            style = TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5);
                            break;
                          default:
                            style = TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.w700);
                        }

                        return Container(
                          padding: currentStory.textHasBackground
                              ? const EdgeInsets.symmetric(horizontal: 14, vertical: 8)
                              : EdgeInsets.zero,
                          decoration: BoxDecoration(
                            color: currentStory.textHasBackground ? Colors.black.withOpacity(0.65) : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            currentStory.text!,
                            textAlign: TextAlign.center,
                            style: style.copyWith(
                              shadows: [
                                const Shadow(color: Colors.black87, blurRadius: 8, offset: Offset(0, 1)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

            // Sticker overlay only if present
            if (currentStory.sticker != null && currentStory.sticker!.isNotEmpty)
              Positioned(
                top: currentStory.stickerY,
                left: currentStory.stickerX,
                child: Transform.rotate(
                  angle: currentStory.stickerRotation,
                  child: Transform.scale(
                    scale: currentStory.stickerScale,
                    child: Text(
                      currentStory.sticker!,
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
            // 2. Floating Reactions
            ..._floatingReactions.map((reaction) => _buildFloatingReactionWidget(reaction)),

            // 3. Top Header: Progress Bars & Info Row
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black54, Colors.transparent],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Progress Bars
                      Row(
                        children: List.generate(widget.stories.length, (index) {
                          return Expanded(
                            child: Container(
                              height: 3,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: Colors.white30,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: index < _currentIndex
                                    ? 1.0
                                    : (index == _currentIndex ? _progress.clamp(0.0, 1.0) : 0.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 10),
                      // User Profile Info & Action Icons
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: const Color(0xFF1877F2),
                            child: Text(widget.userInitial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.userName,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (currentStory.musicName != null)
                                  Row(
                                    children: [
                                      const Icon(Icons.music_note, color: Colors.white70, size: 12),
                                      const SizedBox(width: 3),
                                      Text(
                                        currentStory.musicName!,
                                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          if (widget.isMyStory)
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.white, size: 22),
                              tooltip: 'Delete Story',
                              onPressed: () => _confirmDeleteStory(currentStory),
                            ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white, size: 24),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 4. Bottom Controls: Lifts smoothly above keyboard
            Positioned(
              left: 0,
              right: 0,
              bottom: MediaQuery.of(context).viewInsets.bottom,
              child: SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black45],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: widget.isMyStory
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () => _showViewersSheet(currentStory),
                              child: Row(
                                children: const [
                                  Icon(Icons.keyboard_arrow_up, color: Colors.white),
                                  SizedBox(width: 4),
                                  Text(
                                    'Viewers',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                ],
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                try {
                                  _audioPlayer.stop();
                                } catch (_) {}
                                Navigator.pop(context, 'ADD_STORY');
                              },
                              icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 18),
                              label: const Text('Add story', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Horizontal Reaction Chips
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildQuickPill('Very pretty ❤️'),
                                  const SizedBox(width: 6),
                                  _buildQuickPill('looks perfect ❤️'),
                                  const SizedBox(width: 6),
                                  _buildQuickPill('wow so good 🔥'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Input & Emoji Row
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 40,
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.white30),
                                    ),
                                    child: TextField(
                                      controller: _commentController,
                                      focusNode: _commentFocusNode,
                                      cursorColor: const Color(0xFF1877F2),
                                      cursorWidth: 2.0,
                                      style: const TextStyle(color: Colors.white, fontSize: 14),
                                      decoration: const InputDecoration(
                                        hintText: 'Send message... (max 20 words)',
                                        hintStyle: TextStyle(color: Colors.white60, fontSize: 13),
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(vertical: 9),
                                      ),
                                      onTap: () {
                                        _pauseStory();
                                      },
                                      onSubmitted: _validateAndSendComment,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                ValueListenableBuilder<TextEditingValue>(
                                  valueListenable: _commentController,
                                  builder: (context, val, child) {
                                    final hasText = val.text.trim().isNotEmpty;
                                    if (hasText) {
                                      return GestureDetector(
                                        onTap: () => _validateAndSendComment(_commentController.text),
                                        child: Container(
                                          width: 38,
                                          height: 38,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF1877F2),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.send_rounded,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      );
                                    }
                                    return Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _buildEmojiButton('❤️'),
                                        _buildEmojiButton('👍'),
                                        _buildEmojiButton('😂'),
                                        _buildEmojiButton('😮'),
                                        _buildEmojiButton('😢'),
                                        _buildEmojiButton('😡'),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickPill(String text) {
    return GestureDetector(
      onTap: () => _addFloatingReaction('❤️'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white24),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildEmojiButton(String emoji) {
    return InkWell(
      onTap: () => _addFloatingReaction(emoji),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3.0),
        child: Text(emoji, style: const TextStyle(fontSize: 22)),
      ),
    );
  }

  Widget _buildFloatingReactionWidget(FloatingReaction reaction) {
    return TweenAnimationBuilder<double>(
      key: reaction.key,
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1600),
      builder: (context, val, child) {
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;
        final bottomPos = 80 + (val * (screenHeight * 0.55));
        final opacity = (1.0 - val).clamp(0.0, 1.0);
        final horizontalOffset = math.sin(val * 4 * math.pi) * 18;

        return Positioned(
          bottom: bottomPos,
          left: (screenWidth * reaction.startX) + horizontalOffset,
          child: Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: 0.8 + (val * 0.5),
              child: Text(reaction.emoji, style: const TextStyle(fontSize: 30)),
            ),
          ),
        );
      },
    );
  }
}
