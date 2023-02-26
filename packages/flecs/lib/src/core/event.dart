part of core;

abstract class Event {
  final Entity entity;

  Event(this.entity);
}

class EventReader<T extends Event> {
  const EventReader();

  Iterable<T> iter(Context context) =>
      List.unmodifiable(context.world._events.snapshot.whereType<T>());
}

class EventWriter<T extends Event> {
  const EventWriter();

  void send(Context context, T event) => context.world.addEvent(event);
}
