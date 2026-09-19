import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

class KeoMusicTrack {
  final String title;
  final String artist;
  final String previewUrl;
  final String artworkUrl;

  KeoMusicTrack({
    required this.title,
    required this.artist,
    required this.previewUrl,
    required this.artworkUrl,
  });

  factory KeoMusicTrack.fromApple(Map<String, dynamic> json) {
    return KeoMusicTrack(
      title: json['trackName'] ?? 'Unknown Track',
      artist: json['artistName'] ?? 'Unknown Artist',
      previewUrl: json['previewUrl'] ?? '',
      artworkUrl: json['artworkUrl100'] ?? json['artworkUrl60'] ?? '',
    );
  }
}

class KeoMusicPickerSheet extends StatefulWidget {
  const KeoMusicPickerSheet({super.key});

  @override
  State<KeoMusicPickerSheet> createState() => _KeoMusicPickerSheetState();
}

class _KeoMusicPickerSheetState extends State<KeoMusicPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<KeoMusicTrack> _tracks = [];
  bool _isLoading = false;
  String? _currentlyPlayingUrl;

  final List<String> _trendingTags = ['Viral', 'Trending', 'Bangla', 'Bollywood', 'Nasheed', 'Pop', 'Hip-Hop'];
  String _selectedTag = 'Trending';

  @override
  void initState() {
    super.initState();
    _fetchTracks('trending songs 2026');

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _currentlyPlayingUrl = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchTracks(String query) async {
    if (query.trim().isEmpty) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final encoded = Uri.encodeComponent(query);
      final url = Uri.parse('https://itunes.apple.com/search?term=$encoded&entity=song&limit=30');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List results = data['results'] ?? [];
        final parsed = results
            .where((item) => item['previewUrl'] != null && (item['previewUrl'] as String).isNotEmpty)
            .map((item) => KeoMusicTrack.fromApple(item))
            .toList();

        if (mounted) {
          setState(() {
            _tracks = parsed;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _togglePlayPreview(KeoMusicTrack track) async {
    if (_currentlyPlayingUrl == track.previewUrl) {
      await _audioPlayer.stop();
      setState(() {
        _currentlyPlayingUrl = null;
      });
    } else {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(track.previewUrl));
      setState(() {
        _currentlyPlayingUrl = track.previewUrl;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF141416),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.music_note_rounded, color: Color(0xFF1877F2), size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Add Music to Story',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () {
                    _audioPlayer.stop();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF22242A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search songs, artists, global audio...',
                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: Colors.white38),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white38),
                          onPressed: () {
                            _searchController.clear();
                            _fetchTracks('trending songs');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onSubmitted: (val) {
                  _fetchTracks(val);
                },
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: _trendingTags.map((tag) {
                final isSelected = _selectedTag == tag;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(tag),
                    selected: isSelected,
                    selectedColor: const Color(0xFF1877F2),
                    backgroundColor: const Color(0xFF22242A),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    onSelected: (_) {
                      setState(() => _selectedTag = tag);
                      _fetchTracks('$tag songs');
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(color: Colors.white10, height: 1),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF1877F2)),
                  )
                : _tracks.isEmpty
                    ? const Center(
                        child: Text(
                          'No songs found. Try another search!',
                          style: TextStyle(color: Colors.white38),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _tracks.length,
                        itemBuilder: (context, index) {
                          final track = _tracks[index];
                          final isPlaying = _currentlyPlayingUrl == track.previewUrl;
                          return ListTile(
                            leading: Stack(
                              alignment: Alignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: track.artworkUrl.isNotEmpty
                                      ? Image.network(
                                          track.artworkUrl,
                                          width: 48,
                                          height: 48,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            width: 48,
                                            height: 48,
                                            color: Colors.white12,
                                            child: const Icon(Icons.music_note, color: Colors.white54),
                                          ),
                                        )
                                      : Container(
                                          width: 48,
                                          height: 48,
                                          color: Colors.white12,
                                          child: const Icon(Icons.music_note, color: Colors.white54),
                                        ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                                    color: isPlaying ? const Color(0xFF1877F2) : Colors.white,
                                    size: 32,
                                  ),
                                  onPressed: () => _togglePlayPreview(track),
                                ),
                              ],
                            ),
                            title: Text(
                              track.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                            subtitle: Text(
                              track.artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                            trailing: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1877F2),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              ),
                              onPressed: () {
                                _audioPlayer.stop();
                                Navigator.pop(context, track);
                              },
                              child: const Text('Select', style: TextStyle(color: Colors.white, fontSize: 12)),
                            ),
                            onTap: () => _togglePlayPreview(track),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
