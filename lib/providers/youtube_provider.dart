import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:yt_music/models/song.dart';

class YouTubeProvider extends ChangeNotifier {
  final YoutubeExplode _yt = YoutubeExplode();
  final AudioPlayer _player = AudioPlayer();

  int _currentIndex = 0;
  late List<Song> _home = [];
  late List<Song> _songs = [];
  bool _repeat = false;
  Duration _currentDuration = const Duration();
  Duration _totalDuration = const Duration();
  bool _isPlaying = false;
  bool _isLoading = false;
  late Song _current = _songs[_currentIndex];

  YouTubeProvider() {
    listenToDuration();
  }

  //Getters
  List<Song> get songs => _songs;
  int get currentIndex => _currentIndex;
  bool get repeat => _repeat;
  Duration get currentDuration => _currentDuration;
  Duration get totalDuration => _totalDuration;
  bool get isPlaying => _isPlaying;
  Song get current => _current;
  bool get isLoading => _isLoading;
  late VideoSearchList _search;

  //Setters

  void toggleRepeat() {
    _repeat = !_repeat;
    notifyListeners();
  }

  set currentSongIndex(int index) {
    if (_currentIndex == index && _songs[_currentIndex].id == current.id) {
      return;
    }
    _currentIndex = index;
    _currentDuration = Duration.zero;
    _totalDuration = Duration.zero;
    _isLoading = true;
    _current = _songs[_currentIndex];
    notifyListeners();
    play();
  }

  List<Song> videoToSong(List<Video> videos) {
    List<Song> songs = [];
    for (var video in videos) {
      songs.add(Song(
        id: video.id.toString(),
        title: video.title,
        author: video.author,
        duration: video.duration,
        url: video.url,
        lowThumbnail: video.thumbnails.lowResUrl,
        mediumThumbnail: video.thumbnails.mediumResUrl,
        highThumbnail: video.thumbnails.highResUrl,
      ));
    }
    return songs;
  }

  Future<List> searchVideos(String query) async {
    _search = await _yt.search.search(query);
    _songs = videoToSong(_search.toList());
    if (_home.isEmpty) {
      _home = _songs;
    }
    notifyListeners();
    return _songs;
  }

  Future<void> searchMoreVideos() async {
    _search = (await _search.nextPage())!;
    _songs.addAll(videoToSong(_search.toList()));
    notifyListeners();
  }

  Future<List> homeContent() async {
    if (_home.isEmpty) {
      await searchVideos("songs");
    }
    _songs = _home;
    return _home;
  }

  Future<String> getStreamUrl() async {
    var streamInfo =
        await _yt.videos.streamsClient.getManifest(_songs[_currentIndex].id);
    AudioOnlyStreamInfo audio = streamInfo.audioOnly.sortByBitrate().first;
    return audio.url.toString();
  }

  Future<void> play() async {
    if (_songs.isEmpty) {
      await searchVideos("songs");
    }
    if (!_isLoading) {
      _isLoading = true;
      notifyListeners();
    }
    await _player.stop();
    String url = await getStreamUrl();
    _player.setSource(UrlSource(url));
    await _player.resume();
    _isLoading = false;
    _isPlaying = true;
    notifyListeners();
  }

  void pause() async {
    await _player.pause();
    _isPlaying = false;
    notifyListeners();
  }

  void resume() async {
    await _player.resume();
    _isPlaying = true;
    notifyListeners();
  }

  void pauseOrResume() {
    if (_isPlaying) {
      pause();
    } else {
      resume();
    }
  }

  void seek(Duration duration) async {
    await _player.seek(duration);
    notifyListeners();
  }

  void next() {
    if (_currentIndex == _songs.length - 1) {
      currentSongIndex = 0;
    } else {
      currentSongIndex = _currentIndex + 1;
    }
  }

  void previous() {
    if (_currentDuration.inSeconds > 3) {
      seek(Duration.zero);
    } else {
      if (_currentIndex == 0) {
        currentSongIndex = _songs.length - 1;
      } else {
        currentSongIndex = _currentIndex - 1;
      }
    }
  }

  void listenToDuration() {
    _player.onDurationChanged.listen((Duration duration) {
      _totalDuration = duration;
      notifyListeners();
    });

    _player.onPositionChanged.listen((Duration duration) {
      _currentDuration = duration;
      notifyListeners();
    });

    _player.onPlayerComplete.listen((event) {
      if (_repeat) {
        seek(Duration.zero);
        resume();
      } else {
        next();
      }
    });
  }

  @override
  void dispose() {
    _yt.close();
    _player.dispose();
    super.dispose();
  }
}
