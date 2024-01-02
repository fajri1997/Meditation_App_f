import 'package:flutter/material.dart';
import 'package:meditation_app/models/music_track.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserFavoritesProvider with ChangeNotifier {
  Set<int> _favorites = {};

  Set<int> get favorites => _favorites;

  void toggleFavorite(MusicTrack track) {
    if (_favorites.contains(track.id)) {
      _favorites.remove(track.id);
    } else {
      _favorites.add(track.id);
    }
    notifyListeners();
    // Save favorites to persistent storage if necessary
  }

  bool isFavorite(MusicTrack track) {
    return _favorites.contains(track.id);
  }

  Future<void> saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'favorites', _favorites.map((id) => id.toString()).toList());
  }

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? favoritesIds = prefs.getStringList('favorites');
    if (favoritesIds != null) {
      _favorites = favoritesIds.map((id) => int.parse(id)).toSet();
      notifyListeners();
    }
  }
}
