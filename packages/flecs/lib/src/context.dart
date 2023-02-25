import 'package:flecs/src/core.dart';

class Context {
  late final World world;
  final Stream scheduler;

  Context._(this.scheduler) {
    world = World(this, scheduler: scheduler);
  }

  factory Context({Stream? scheduler}) => Context._(scheduler ??
      Stream.periodic(const Duration(milliseconds: 20)).asBroadcastStream());
}
