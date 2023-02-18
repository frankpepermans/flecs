import 'package:collection/collection.dart';
import 'package:flecs/src/context.dart';
import 'package:flecs/src/world.dart';

typedef Combiner = Iterable<List<Type>> Function(Type it, List<Type> data);

class Query<T extends Record> {
  static final _resolvedTypes = <Type, List<Type>>{};

  final Context context;

  const Query(this.context);

  List<QueryRecord<T>> exec() {
    final querySession = context.world.createQuerySession();
    final data = querySession.componentTypes.toList(growable: false);
    final indices = _resolvedTypes.putIfAbsent(
        T,
        () =>
            _combineAll((it, data) =>
                    data.where((i) => i != it).map((i) => [it, i]))
                .map(
                  (level) => data
                      .map((it) => level(it, data))
                      .expand((it) => it)
                      .firstWhereOrNull(_test(querySession)),
                )
                .take(data.length)
                .firstWhereOrNull((it) => it != null) ??
            const []);

    return List.unmodifiable(_collect(querySession)(indices)
        .map((it) => QueryRecord._(it.$1, it.$2)));
  }

  bool Function(List<Type>) _test(WorldQuerySession querySession) =>
      (List<Type> list) {
        //print(list);
        try {
          return _collect(querySession)(list).firstOrNull?.$2 is T;
        } catch (_) {
          //
        }

        return false;
      };

  Iterable<Combiner> _combineAll(Combiner f) sync* {
    next(Type it, List<Type> data) => f(it, data)
        .map((tuple) =>
            data.where(tuple.containsNot).map((other) => [...tuple, other]))
        .expand((it) => it);

    yield f;
    yield* _combineAll(next);
  }

  Iterable<(Entity, T)> Function(List<Type>) _collect(WorldQuerySession querySession) =>
      (List<Type> types) sync* {
        for (final it in querySession.entities) {
          final components = it.componentsFromTypes(types);

          if (components.length == types.length) {
            switch (components.length) {
              case 1:
                yield (it, (components[0],) as T);
              case 2:
                yield (it, (components[0], components[1]) as T);
              case 3:
                yield (it, (components[0], components[1], components[2]) as T);
              case 4:
                yield (it, (components[0], components[1], components[2], components[3]) as T);
              case 5:
                yield (it, (components[0], components[1], components[2], components[3], components[4]) as T);
              case 6:
                yield (it, (components[0], components[1], components[2], components[3], components[4], components[5]) as T);
            }
          }
        }
  };
}

class QueryRecord<T extends Record> {
  final Entity entity;
  final T record;

  const QueryRecord._(this.entity, this.record);
}

extension _ListExtension<T> on List<T> {
  bool containsNot(T element) => !contains(element);
}