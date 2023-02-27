part of core;

/// A [Resource] represent a static world value of type [T].
///
/// ```dart
/// final entity = context.world.addResource(const Config());
///
/// class Config {
///   // properties
/// }
/// ```
class Resource<T extends Object> {
  /// Creates a new [Resource].
  const Resource();

  /// Using [Context], fetches an instance of [T] in the [World] belonging to `Context`.
  /// Throws a [ResourceNotFoundError] if no instance of the `Resource` could be found.
  T value(Context context) => context.world._fetchResource();
}

/// An [Error] which is thrown when requesting a [Resource] which does not exist in a [World].
class ResourceNotFoundError<T extends Object> extends Error {
  @override
  String toString() =>
      'Resource not found: $T\nPerhaps you forgot to add the resource?';
}
