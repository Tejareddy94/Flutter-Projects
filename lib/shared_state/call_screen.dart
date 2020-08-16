import 'dart:async';

import 'package:flutter/foundation.dart';

class CallScreenState extends ChangeNotifier {
  bool _isCallDailed = false;

  bool get isCallDailed => _isCallDailed;

  set updateIsCallDailled(bool isDailled) {
    _isCallDailed = isDailled;
    notifyListeners();
  }
}

class TimerCounterState extends ChangeNotifier {
  Stopwatch _watch;
  Timer _timer;
  Duration _currentDuration = Duration.zero;

  Duration get currentDuration => _currentDuration;

  bool get isRunning => _timer != null;

  TimerCounterState() {
    _watch = Stopwatch();
  }

  void _onTick(Timer timer) {
    _currentDuration = _watch.elapsed;
    notifyListeners();
  }

  void start() {
    if (_timer != null) return;

    _timer = Timer.periodic(Duration(seconds: 1), _onTick);
    _watch.start();

    notifyListeners();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _watch.stop();
    _currentDuration = _watch.elapsed;

    notifyListeners();
  }

  void reset() {
    stop();
    _watch.reset();
    _currentDuration = Duration.zero;

    notifyListeners();
  }
}

class CallTimerOutState extends ChangeNotifier {
  Stopwatch _watch;
  Timer _timer;
  Duration _currentDuration = Duration.zero;

  Duration get currentDuration => _currentDuration;

  bool get isRunning => _timer != null;

  CallTimerOutState() {
    _watch = Stopwatch();
  }

  void _onTick(Timer timer) {
    _currentDuration = _watch.elapsed;
    notifyListeners();
  }

  void start() {
    if (_timer != null) return;

    _timer = Timer.periodic(Duration(seconds: 1), _onTick);
    _watch.start();

    notifyListeners();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _watch.stop();
    _currentDuration = _watch.elapsed;

    notifyListeners();
  }

  void reset() {
    stop();
    _watch.reset();
    _currentDuration = Duration.zero;

    notifyListeners();
  }
}
