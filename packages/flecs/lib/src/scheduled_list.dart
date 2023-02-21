class ScheduledList<T> {
  final List<T> _buffer = <T>[];
  List<T> _snapshot = const [];
  bool _hasUpdate = false;

  List<T> get snapshot => _snapshot;

  bool get hasUpdate => _hasUpdate;

  void update() {
    _snapshot = List.unmodifiable(_buffer);
    _hasUpdate = _buffer.isNotEmpty;
    _buffer.clear();
  }

  void add(T entry) => _buffer.add(entry);
}