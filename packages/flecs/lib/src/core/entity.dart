part of core;

class Entity {
  final World _world;
  Map<Type, Object> _components = const <Type, Object>{};
  List<Type> _changed = const [];
  List<Type> _added = const [];

  int get _componentsHashCode =>
      hashObjects(_components.values.toList(growable: false));

  Entity._(this._world);

  @mustCallSuper
  void despawn() => _world._entities.remove(this);

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

  @mustCallSuper
  Entity removeComponent<T extends Object>(T component) {
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
          List<Type> types, List<EntityFilter> entityFilters) =>
      types
          .map((type) => identical(runtimeType, type)
              ? entityFilters.every((filter) => filter(this))
                  ? this
                  : null
              : _components[type])
          .whereType<Object>()
          .toList(growable: false);
}
