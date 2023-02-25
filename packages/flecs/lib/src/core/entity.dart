part of core;

class Entity {
  final World _world;
  final Map<Type, Object> _components;

  int get _componentsHashCode =>
      hashObjects(_components.values.toList(growable: false));

  const Entity._(this._world, {Map<Type, Object> components = const {}})
      : _components = components;

  @mustCallSuper
  void despawn() => _world._entities.remove(this);

  @mustCallSuper
  Entity addComponent<T extends Object>(T component) {
    final nextEntity = _replaceComponent(component);

    if (nextEntity != this) {
      return nextEntity;
    }

    _world._componentTypes.add(T);

    return _withUpdatedComponents({..._components, T: component});
  }

  @mustCallSuper
  Entity removeComponent<T extends Object>(T component) {
    if (!_components.containsKey(T)) {
      return this;
    }

    return _withUpdatedComponents(_components..remove(T));
  }

  Entity _replaceComponent<T extends Object>(T component) {
    if (_components.containsKey(T)) {
      return _withUpdatedComponents(_components..[T] = component);
    }

    return this;
  }

  List<Object> _componentsFromTypes(List<Type> types) => types
      .map((type) => identical(runtimeType, type) ? this : _components[type])
      .whereType<Object>()
      .toList(growable: false);

  Entity _withUpdatedComponents(Map<Type, Object> components) =>
      _world._entities[_world._entities.indexOf(this)] =
          Entity._(_world, components: components);
}
