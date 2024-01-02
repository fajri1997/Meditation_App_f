// models/music_track.dart
// models/music_track.dart
class MusicTrack {
  final int id;
  final String title;
  final String file;
  bool isFavorite;

  MusicTrack({
    required this.id,
    required this.title,
    required this.file,
    this.isFavorite = false, // Default is not a favorite
  });

  factory MusicTrack.fromJson(Map<String, dynamic> json) {
    return MusicTrack(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Unknown Title',
      file: json['file'] ?? '',
    );
  }
}
