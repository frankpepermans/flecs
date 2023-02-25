part of core;

abstract class Event {
  final Entity entity;

  Event(this.entity);
}

class EventReader<T extends Event> {
  final Context context;

  const EventReader(this.context);

  Iterable<T> iter() =>
      List.unmodifiable(context.world._events.snapshot.whereType<T>());
}

class EventWriter<T extends Event> {
  final Context context;

  const EventWriter(this.context);

  void send(T event) => context.world.addEvent(event);
}
