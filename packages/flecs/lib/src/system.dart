import 'dart:async';

import 'package:flecs/flecs.dart';

typedef SystemBuilder<T extends Record> = System<T> Function(Context);

abstract class SystemProvider {
  static SystemBuilder<T> builder<T extends Record>(SystemBuilder<T> system) => system;
}

class System<T extends Record> {
  final T params;
  final FutureOr<void> Function(T) handler;

  const System._(
    this.params,
    this.handler,
  );

  factory System(T params, {required void Function(T) handler}) {
    final system = System<T>._(params, handler);

    return system;
  }

  factory System.normal(void Function() handler) => System((null,) as T, handler: (_) => handler());

  FutureOr<void> run() => handler(params);
}
