part of core;

/// The abstract [Event] class, which all custom events should inherit from.
///
/// ```dart
/// class MyEvent implements Event {
///   final int foo;
///   final String bar;
///
///   const MyEvent({required this.foo, required this.bar});
/// }
/// ```
abstract class Event {
  /// The [Entity] where this [Event] points to.
  final Entity entity;

  /// Creates a new [Event].
  const Event(this.entity);
}

/// An event reader can be included in a [System] and will trigger whenever
/// an equivalent [EventWriter] of type [T] sent a new [Event].
///
/// ```dart
/// final updateSystem = SystemProvider.builder((context) =>
///   System((const EventReader<PriceUpdate>(),), handler: (data) {
///     for (final it in data.$1.iter(context)) {
///       it.entity.addComponent(Price(it.value));
///     }
///   }));
/// ```
class EventReader<T extends Event> {
  /// Creates a new [EventReader].
  const EventReader();

  /// Returns an [Iterable] which contains all events of type [T] which were sent out during the last loop iteration.
  Iterable<T> iter(Context context) =>
      context.world._events.snapshot.whereType<T>();
}

/// An event reader can be included in a [System] and can be used to send an [Event] to another [System] which
/// makes use of [EventReader] of type [T].
///
/// ```dart
/// final updateSystem = SystemProvider.builder((context) =>
///   System((
///     const Query<(Entity, Price)>(),
///     const EventReader<PriceUpdate>(),
///   ), handler: (data) {
///     for (final (entity, price) in data.$1.iter(context)) {
///       if (price.value < 100.0) {
///         data.$2.send(context, const PriceUpdate(100.0));
///       }
///     }
///   }));
/// ```
class EventWriter<T extends Event> {
  /// Creates a new [EventWriter].
  const EventWriter();

  /// Sends an event of type [T] on the current [World] loop iteration.
  void send(Context context, T event) => context.world._addEvent(event);
}
