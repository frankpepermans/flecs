import 'package:flecs/src/context.dart';
import 'package:flecs/src/world.dart';

class EventReader<T extends Event> {
  final Context context;

  const EventReader(this.context);

  Iterable<T> iter() => context.world.createEventSession();
}

class EventWriter<T extends Event> {
  final Context context;

  const EventWriter(this.context);

  void send(T event) => context.world.addEvent(event);
}

abstract class Event {
  final Entity entity;

  Event(this.entity);
}