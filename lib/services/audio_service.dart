import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioPlayer _player = AudioPlayer();
  static bool _isPlaying = false;

  static Future<void> playNewOrderSound() async {
    // Don't play if already playing
    if (_isPlaying) return;

    try {
      _isPlaying = true;
      await _player.play(AssetSource('audio/new_order.mp3'));

      // Reset flag when playback completes
      _player.onPlayerComplete?.listen((event) {
        _isPlaying = false;
      });
    } catch (e) {
      print('Error playing sound: $e');
      _isPlaying = false;
    }
  }

  static Future<void> stopSound() async {
    await _player.stop();
    _isPlaying = false;
  }

  static void dispose() {
    _player.dispose();
  }
}
