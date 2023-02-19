import 'dart:async';

import 'package:collection/collection.dart';
import 'package:quiver/core.dart';

class World {
  final Set<Type> _componentTypes = <Type>{};
  final List<Entity> _entities = <Entity>[];
  final List<StreamSubscription> _systemsListeners = <StreamSubscription>[];
  final Stream scheduler;

  World(this.scheduler);

  void dispose() {
    for (final it in _systemsListeners) {
      it.cancel();
    }
  }

  int get entitiesHashCode =>
      hashObjects(_entities.map((it) => it.componentsHashCode));

  Entity spawn() {
    return Entity._(this);
  }

  WorldQuerySession createQuerySession() => WorldQuerySession(
        componentTypes: Set.unmodifiable(_componentTypes),
        entities: List.unmodifiable(_entities),
      );

  void addSystem<T extends Record>(
    T system, {
    required FutureOr Function(T) handler,
  }) {
    var hc = -1;

    _systemsListeners.add(scheduler.listen((_) {
      final hcNow = entitiesHashCode;

      if (hc != hcNow) {
        hc = hcNow;

        handler(system);
      }
    }));
  }
}

class Entity {
  final World _world;
  final List<Object> components;
  late final int _index;

  int get componentsHashCode => hashObjects(components);

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
