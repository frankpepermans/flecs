import 'package:collection/collection.dart';

class World {
  final Set<Type> componentTypes = <Type>{};
  final List<Entity> entities = <Entity>[];

  World();

  Entity spawn() {
    return Entity._(this);
  }
}

class Entity {
  final World _world;
  final List components = [];

  Type typeOfIt<X>(X it) => X;

  Entity._(this._world) {
    _world.entities.add(this);
  }

  void addComponent<T>(T component) {
    _world.componentTypes.add(T);
    components.add(component);
  }

  bool every(List<Type> types) => types.every((type) =>
      components.firstWhereOrNull((it) => identical(it.runtimeType, type)) !=
      null);

  T componentByType<T>(Type type) =>
      components.firstWhere((it) => identical(it.runtimeType, type));
}
