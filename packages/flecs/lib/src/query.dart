import 'package:collection/collection.dart';
import 'package:flecs/src/context.dart';
import 'package:flecs/src/world.dart';

typedef Combiner = Iterable<List<Type>> Function(Type it, List<Type> data);

class Query<T extends Record> {
  static final _resolvedTypes = <Type, List<Type>>{};

  final Context context;

  const Query(this.context);

  List<QueryRecord<T>> exec() {
    final data = context.world.componentTypes.toList(growable: false);
    final indices = _resolvedTypes.putIfAbsent(T, () {
      return _combineAll(
                  (it, data) => data.where((i) => i != it).map((i) => [it, i]))
              .map(
                (level) => data
                    .map((it) => level(it, data))
                    .expand((it) => it)
                    .firstWhereOrNull(_test),
              )
              .take(data.length)
              .firstWhereOrNull((it) => it != null) ??
          const [];
    });

    return List.unmodifiable(
        _collect(indices).map((it) => QueryRecord._(it.$1, it.$2)));
  }

  bool _test(List<Type> list) {
    try {
      return _collect(list).firstOrNull?.$2 is T;
    } catch (_) {
      //
    }

    return false;
  }

  Iterable<Combiner> _combineAll(Combiner f) sync* {
    next(Type it, List<Type> data) => f(it, data)
        .map((tuple) =>
            data.where(tuple.containsNot).map((other) => [...tuple, other]))
        .expand((it) => it);

    yield next;
    yield* _combineAll(next);
  }

  Iterable<(Entity, T)> _collect(List<Type> types) sync* {
    for (final it in context.world.entities.where((it) => it.every(types))) {
      switch (types.length) {
        case 1:
          yield (it, (it.componentByType(types[0])) as T);
        case 2:
          yield (it, (it.componentByType(types[0]), it.componentByType(types[1])) as T);
        case 3:
          yield (it, (it.componentByType(types[0]), it.componentByType(types[1]), it.componentByType(types[2])) as T);
        case 4:
          yield (it, (it.componentByType(types[0]), it.componentByType(types[1]), it.componentByType(types[2]), it.componentByType(types[3])) as T);
        case 5:
          yield (it, (it.componentByType(types[0]), it.componentByType(types[1]), it.componentByType(types[2]), it.componentByType(types[3]), it.componentByType(types[4])) as T);
        case 6:
          yield (it, (it.componentByType(types[0]), it.componentByType(types[1]), it.componentByType(types[2]), it.componentByType(types[3]), it.componentByType(types[4]), it.componentByType(types[5])) as T);
      }
    }
  }
}

class QueryRecord<T extends Record> {
  final Entity entity;
  final T record;

  const QueryRecord._(this.entity, this.record);
}

extension _ListExtension<T> on List<T> {
  bool containsNot(T element) => !contains(element);
}
