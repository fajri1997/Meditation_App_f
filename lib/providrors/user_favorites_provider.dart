// providers/user_favorites_provider.dart
import 'package:flutter/material.dart';
import 'package:meditation_app/models/music_track.dart';

class UserFavoritesProvider with ChangeNotifier {
  Set<int> _favorites = {};

  Set<int> get favorites => _favorites;

  void toggleFavorite(MusicTrack track) {
    if (_favorites.contains(track.id)) {
      _favorites.remove(track.id);
    } else {
      _favorites.add(track.id);
    }

    // Notify listeners that the favorites have changed
    notifyListeners();
  }

  bool isFavorite(MusicTrack track) {
    return _favorites.contains(track.id);
  }
}
