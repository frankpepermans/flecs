import 'dart:async';

class System<T extends Record> {
  final T params;
  final FutureOr<void> Function(T) handler;

  const System._(
    this.params,
    this.handler,
  );

  factory System.create(T params, {required void Function(T) handler}) {
    final system = System<T>._(params, handler);

    return system;
  }

  FutureOr<void> run() => handler(params);
}
