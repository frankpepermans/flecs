part of core;

/// An [Entity] represents an entry point for data within a [World].
/// It's actual value is represented in components.
///
/// ```dart
/// final entity = context.world.spawn()
///   .addComponent(const Name('MyProduct'))
///   .addComponent(const Price(99.90))
///   .addComponent(const IsInStock(true));
/// ```
class Entity {
  final World _world;
  Map<Type, Object> _components = const <Type, Object>{};
  List<Type> _changed = const [];
  List<Type> _added = const [];

  int get _componentsHashCode =>
      hashObjects(_components.values.toList(growable: false));

  Entity._(this._world);

  /// Removes the [Entity] from its [World].
  @mustCallSuper
  void despawn() => _world._entities.remove(this);

  /// Adds a new component of type [T] to this [Entity].
  /// If a component [T] was added before, then the existing component will
  /// be replaced.
  ///
  /// ```dart
  /// final entity = context.world.spawn()
  ///   .addComponent(const Name('foo'))
  ///   .addComponent(const Name('bar')); // entity now contains 1 component, Name('bar')
  /// ```
  @mustCallSuper
  Entity addComponent<T extends Object>(T component) {
    final componentsHashCode = _componentsHashCode;

    _replaceComponent(component);

    if (componentsHashCode != _componentsHashCode) {
      return this;
    }

    _world._componentTypes.add(T);
    _components = {..._components, T: component};
    _added = [..._added, T];

    return this;
  }

  /// Removes a component of type [T].
  ///
  /// ```dart
  /// final entity = context.world.spawn()
  ///   .addComponent(const Name('foo'))
  ///   .removeComponent<Name>(); // entity has no components
  /// ```
  @mustCallSuper
  Entity removeComponent<T extends Object>() {
    if (!_components.containsKey(T)) {
      return this;
    }

    _components.remove(T);

    return this;
  }

  void _clearDelta() {
    _changed = const [];
    _added = const [];
  }

  Entity _replaceComponent<T extends Object>(T component) {
    if (_components.containsKey(T)) {
      _components[T] = component;
      _changed = [..._changed, T];
    }

    return this;
  }

  List<Object> _componentsFromTypes(
          List<Type> types, List<_EntityFilter> entityFilters) =>
      types
          .map((type) => identical(runtimeType, type)
              ? entityFilters.every((filter) => filter(this))
                  ? this
                  : null
              : _components[type])
          .whereType<Object>()
          .toList(growable: false);
}
