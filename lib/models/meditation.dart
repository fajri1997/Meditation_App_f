// meditation.dart
class MeditationSession {
  final int id;
  final String title;
  final String file;

  MeditationSession({
    required this.id,
    required this.title,
    required this.file,
  });

  factory MeditationSession.fromJson(Map<String, dynamic> json) {
    return MeditationSession(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Default title',
      file: json['file'] ?? 'Default file',
    );
  }
}
