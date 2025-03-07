import 'dart:async';

class TimerRepository {
  Timer? _timer;
  final Stopwatch _stopwatch = Stopwatch();
  Duration _elapsed = Duration.zero;

  Duration get elapsed => _elapsed;
  Function(Duration)? onTick;

  TimerRepository({this.onTick});

  Future<void> startTimer() async {
    if (!_stopwatch.isRunning) {
      _stopwatch.start();
       _timer = await Timer.periodic(Duration(seconds: 10), (timer) {
        _elapsed = _stopwatch.elapsed;
        if (onTick != null) onTick!(_elapsed);
      });
    }
  }

  void pauseTimer() {
    _stopwatch.stop();
    _timer?.cancel();
  }

  void resumeTimer() {
    if (!_stopwatch.isRunning) {
      _stopwatch.start();
      _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
        _elapsed = _stopwatch.elapsed;
        if (onTick != null) onTick!(_elapsed);
      });
    }
  }

  void resetTimer() {
    _stopwatch.reset();
    _elapsed = Duration.zero;
    _timer?.cancel();
    if (onTick != null) onTick!(_elapsed);
  }

  void dispose() {
    _timer?.cancel();
  }

}