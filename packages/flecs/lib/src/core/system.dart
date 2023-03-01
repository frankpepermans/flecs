part of core;

/// Describes the handler which is used to add systems to a [World].
typedef SystemBuilder<T extends Record> = System<T> Function(Context context);

/// A [SystemProvider] prepares a [System] builder which accepts [Context] and returns a [System].
///
/// ```dart
/// final priceUpdateSystem = SystemProvider.builder((context) =>
///     System((const EventReader<PriceUpdate>(),), handler: (data) {
///       for (final (priceUpdate,) in data.$1.iter(context)) {
///         priceUpdate.entity.addComponent(Price(priceUpdate.value));
///       }
///     }));
///
/// context.world.addSystem(priceUpdateSystem);
/// ```
abstract class SystemProvider {
  /// Creates a new [SystemBuilder] which can be used in a [World].
  static SystemBuilder<T> builder<T extends Record>(SystemBuilder<T> system) =>
      system;
}

/// A [System] contains a [handler] which is invoked on each [World] loop iteration.
/// When `handler` is called, it receives [params] as argument.
///
/// A [System] should not be created directly, always use [SystemBuilder.builder] instead.
///
/// ```dart
/// final someSystem = SystemProvider.builder((context) =>
///   System((
///     const EventReader<PriceUpdate>(),
///     const Resource<Config>(),
///     const Query<(Entity, Price)>()
///   ), handler: (data) {
///     // ...
///   }));
/// ```
class System<T extends Record> {
  /// Parameters which are passed as argument to [handler].
  final T params;
  /// A method which is invoked on every [World] loop iteration.
  final FutureOr<void> Function(T) handler;

  const System._(
    this.params,
    this.handler,
  );

  /// Creates a new [System] with [params] and [handler].
  factory System(T params, {required void Function(T) handler}) =>
      System<T>._(params, handler);

  /// Creates a [System] without requiring any parameters.
  /// Typically used with startup systems.
  factory System.normal(void Function() handler) =>
      System((null,) as T, handler: (_) => handler());

  FutureOr<void> _run() => handler(params);
}
