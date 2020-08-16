import 'package:flutter/foundation.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class CallRingToneState extends ChangeNotifier {
  bool _isplaying=false;

  bool get isPLaying => _isplaying;
  void playRingTone() {
    _isplaying = true;
    FlutterRingtonePlayer.playRingtone();
  }

  void stopRingTone() {
    if (_isplaying) {
      _isplaying = false;
      FlutterRingtonePlayer.stop();
    }
  }
}
