class Song {
  final String id;
  final String title;
  final String author;
  final Duration? duration;
  final String url;
  final String lowThumbnail;
  final String mediumThumbnail;
  final String highThumbnail;

  Song({
    required this.id,
    required this.title,
    required this.author,
    required this.duration,
    required this.url,
    required this.lowThumbnail,
    required this.mediumThumbnail,
    required this.highThumbnail,
  });
}
