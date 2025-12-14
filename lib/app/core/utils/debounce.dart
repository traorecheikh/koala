import 'dart:async';
import 'dart:ui';

class Debounce {
  final Duration delay;
  final VoidCallback action;
  Timer? _timer;

  Debounce(this.delay, this.action);

  void call() {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void cancel() {
    _timer?.cancel();
  }
}

