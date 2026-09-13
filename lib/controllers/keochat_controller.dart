import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KeoChatController extends ChangeNotifier {
  static final KeoChatController instance = KeoChatController._internal();
  KeoChatController._internal();

  bool _isDarkMode = false;
  String _selectedWallpaper = 'none';
  double _fontSize = 15.0; // 13.0 = Small, 15.0 = Normal, 18.0 = Large
  double _wallpaperOpacity = 0.85;

  bool get isDarkMode => _isDarkMode;
  String get selectedWallpaper => _selectedWallpaper;
  double get fontSize => _fontSize;
  double get wallpaperOpacity => _wallpaperOpacity;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('keochat_is_dark') ?? false;
    _selectedWallpaper = prefs.getString('keochat_wallpaper') ?? 'none';
    _fontSize = prefs.getDouble('keochat_font_size') ?? 15.0;
    _wallpaperOpacity = prefs.getDouble('keochat_wallpaper_opacity') ?? 0.85;
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool value) async {
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('keochat_is_dark', _isDarkMode);
    notifyListeners();
  }

  Future<void> setWallpaper(String wallpaperId) async {
    _selectedWallpaper = wallpaperId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('keochat_wallpaper', _selectedWallpaper);
    notifyListeners();
  }

  Future<void> setFontSize(double size) async {
    _fontSize = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('keochat_font_size', _fontSize);
    notifyListeners();
  }

  Future<void> setWallpaperOpacity(double opacity) async {
    _wallpaperOpacity = opacity;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('keochat_wallpaper_opacity', _wallpaperOpacity);
    notifyListeners();
  }
}