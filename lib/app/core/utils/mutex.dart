/// Simple Mutex implementation for synchronizing access to critical sections
/// Ensures that only one async operation can execute at a time
class Mutex {
  bool _locked = false;
  final List<_LockRequest> _queue = [];

  /// Protects a critical section by ensuring only one caller executes at a time
  /// Other callers will wait until the current one completes
  Future<T> protect<T>(Future<T> Function() fn) async {
    final request = _LockRequest();

    _queue.add(request);

    // Wait until it's our turn (we're first in queue and no one else has lock)
    while (_queue.isNotEmpty && (_queue.first != request || _locked)) {
      await Future.delayed(const Duration(microseconds: 100));
    }

    try {
      _locked = true;
      return await fn();
    } finally {
      _locked = false;
      _queue.remove(request);
    }
  }
}

class _LockRequest {
  // Marker class for identifying queue position
}
