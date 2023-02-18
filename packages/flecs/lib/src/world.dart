import 'package:collection/collection.dart';

class World {
  final Set<Type> _componentTypes = <Type>{};
  final List<Entity> _entities = <Entity>[];

  World();

  Entity spawn() {
    return Entity._(this);
  }

  WorldQuerySession createQuerySession() => WorldQuerySession(
        componentTypes: Set.unmodifiable(_componentTypes),
        entities: List.unmodifiable(_entities),
      );
}

class Entity {
  final World _world;
  final List<Object> components;
  late final int _index;

  Entity._(this._world) : components = const [] {
    _index = _world._entities.length;

    _world._entities.add(this);
  }

  Entity._changed(this._world, this._index, {required this.components});

  Entity addComponent<T extends Object>(T component) {
    _world._componentTypes.add(T);

    return _world._entities[_index] =
        Entity._changed(_world, _index, components: [...components, component]);
  }

  Entity removeComponent<T extends Object>(T component) {
    if (!components.contains(component)) {
      return this;
    }

    return _world._entities[_index] = Entity._changed(_world, _index,
        components: components..remove(component));
  }

  Entity replaceComponent<T extends Object>(T oldComponent, T newComponent) {
    if (components.contains(oldComponent)) {
      return _world._entities[_index] = Entity._changed(_world, _index,
          components: components
            ..remove(oldComponent)
            ..add(newComponent));
    }

    return this;
  }

  List<Object> componentsFromTypes(List<Type> types) => types
      .map((type) =>
          components.firstWhereOrNull((it) => identical(it.runtimeType, type)))
      .whereType<Object>()
      .toList(growable: false);
}

class WorldQuerySession {
  final Set<Type> componentTypes;
  final List<Entity> entities;

  WorldQuerySession({
    required this.entities,
    required this.componentTypes,
  });
}
