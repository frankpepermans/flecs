import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flecs/src/events.dart';
import 'package:flecs/src/system.dart';
import 'package:quiver/core.dart';

enum SchedulerPhase { start, end }

class World {
  final Set<Type> _componentTypes = <Type>{};
  final List<Entity> _entities = <Entity>[];
  final List<Event> _events = <Event>[];
  final List<Object> _resources = <Object>[];
  List<Event> _currentEventBatch = const [];
  late final StreamSubscription<SchedulerPhase> _schedulerEndListener;
  final List<StreamSubscription<SchedulerPhase>> _systemsListeners =
      <StreamSubscription<SchedulerPhase>>[];
  final Stream<SchedulerPhase> _scheduler;

  Stream<SchedulerPhase> get _schedulerStart =>
      _scheduler.where((it) => it == SchedulerPhase.start);
  Stream<SchedulerPhase> get _schedulerEnd =>
      _scheduler.where((it) => it == SchedulerPhase.end);

  World(Stream scheduler)
      : _scheduler = scheduler
            .map((_) => [SchedulerPhase.start, SchedulerPhase.end])
            .expand((it) => it) {
    _schedulerEndListener = _schedulerEnd.listen((_) {
      _currentEventBatch = List.unmodifiable(_events);
      _events.clear();
    });
  }

  void dispose() {
    _schedulerEndListener.cancel();

    for (final it in _systemsListeners) {
      it.cancel();
    }
  }

  int get entitiesHashCode =>
      hashObjects(_entities.map((it) => it.componentsHashCode));

  void addResource<T extends Object>(T resource) => _resources.add(resource);

  T fetchResource<T extends Object>() {
    try {
      return _resources.whereType<T>().first;
    } on StateError {
      throw ResourceNotFoundError<T>();
    }
  }

  Entity spawn() => Entity._(this);

  Iterable<T> createEventSession<T extends Event>() =>
      List.unmodifiable(_currentEventBatch.whereType<T>());

  WorldQuerySession createQuerySession() => WorldQuerySession(
        componentTypes: Set.unmodifiable(_componentTypes),
        entities: List.unmodifiable(_entities),
      );

  void addSystem<T extends Record>(System<T> system) {
    var hc = -1;

    _systemsListeners.add(_schedulerStart.listen((_) async {
      var hcNow = entitiesHashCode;

      if (hc != hcNow || _currentEventBatch.isNotEmpty) {
        hc = hcNow;

        await system.run();
      }
    }));
  }

  void addEvent(Event event) => _events.add(event);
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
    final nextEntity = _replaceComponent(component);

    if (nextEntity != this) {
      return nextEntity;
    }

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

  Entity _replaceComponent<T extends Object>(T component) {
    if (components.map((it) => it.runtimeType).contains(T)) {
      return _world._entities[_index] = Entity._changed(_world, _index,
          components: components
            ..removeWhere((it) => it.runtimeType == T)
            ..add(component));
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

class ResourceNotFoundError<T extends Object> extends Error {
  ResourceNotFoundError();

  @override
  String toString() => "Resource not found: $T\nPerhaps you forgot to add the resource?";
}
