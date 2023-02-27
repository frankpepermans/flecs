import 'package:flecs/flecs.dart';

/// [Context] holds a single [World] and also dictates the world's loop via [scheduler].
///
/// It is also required to be able to perform lookup tasks from within [System]s.
///
/// For example, a [Query] requires it when running [Query.iter], or when you
/// wish to fetch the value of a [Resource] via [Resource.value].
///
/// [System]s can be reused to make them run over different [Context]s.
class Context {
  /// A reference to the [World] living in this [Context].
  late final World world;

  /// [scheduler] dictates how the main loop runs, for a typical front-end application,
  /// It should be set to 16 or 17 milliseconds, assuming that the app runs at 60 FPS.
  /// Important note: the [Stream] should be a [Stream.isBroadcast] so that multiple systems can subscribe to it.
  final Stream scheduler;

  Context._(this.scheduler)
      : assert(scheduler.isBroadcast, 'Context requires a broadcast Stream.') {
    world = World(this);
  }

  /// Creates a new [Context], optionally use `scheduler` to provide a custom [Stream], which
  /// takes care of the loop. For example, use a [Stream.periodic] here.
  factory Context({Stream? scheduler}) => Context._(scheduler ??
      Stream.periodic(const Duration(microseconds: 16667)).asBroadcastStream());
}
