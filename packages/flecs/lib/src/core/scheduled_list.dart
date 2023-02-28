part of core;

class _ScheduledList<T> {
  final List<T> _buffer = <T>[];
  List<T> _snapshot = const [];
  bool _hasUpdate = false;

  List<T> get snapshot => _snapshot;

  bool get hasUpdate => _hasUpdate;

  void update() {
    _hasUpdate = _buffer.isNotEmpty;
    _snapshot = _hasUpdate ? List.unmodifiable(_buffer) : const [];

    if (_hasUpdate) {
      _buffer.clear();
    }
  }

  void add(T entry) => _buffer.add(entry);
}
