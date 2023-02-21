import 'package:collection/collection.dart';
import 'package:flecs/src/context.dart';
import 'package:flecs/src/world.dart';

typedef Combiner = Iterable<List<Type>> Function(Type it, List<Type> data);

class Query<T extends Record> {
  static final _resolvedTypes = <Type, List<Type>>{};

  final Context context;

  const Query(this.context);

  Iterable<T> iter() {
    final querySession = context.world.createQuerySession();
    final data = [Entity, ...querySession.componentTypes];
    final test = _test(querySession);

    combineAll() =>
        _combineAll(
                (it, data) => data.where((i) => i != it).map((i) => [it, i]))
            .map(
              (level) => data
                  .map((it) => level(it, data))
                  .expand((it) => it)
                  .firstWhereOrNull(test),
            )
            .take(data.length)
            .firstWhereOrNull((it) => it != null) ??
        const [];

    return _collect(querySession)(_resolvedTypes.putIfAbsent(
        T, () => data.map((it) => [it]).firstWhere(test, orElse: combineAll)));
  }

  bool Function(List<Type>) _test(WorldQuerySession querySession) =>
      (List<Type> list) {
        //print(list);
        try {
          return _collect(querySession)(list).firstOrNull is T;
        } catch (_) {
          //
        }

        return false;
      };

  Iterable<Combiner> _combineAll(Combiner f) sync* {
    yield f;
    yield* _combineAll((Type it, List<Type> data) => f(it, data)
        .map((tuple) =>
            data.where(tuple.containsNot).map((other) => [...tuple, other]))
        .expand((it) => it));
  }

  Iterable<T> Function(List<Type>) _collect(WorldQuerySession querySession) =>
          (List<Type> types) sync* {
        for (final it in querySession.entities) {
          final components = it.componentsFromTypes(types);

          if (components.length == types.length) {
            try {
              switch (components.length) {
                case 1:
                  yield (components[0],) as T;
                case 2:
                  yield (components[0], components[1]) as T;
                case 3:
                  yield (components[0], components[1], components[2]) as T;
                case 4:
                  yield (components[0], components[1], components[2], components[3]) as T;
                case 5:
                  yield (components[0], components[1], components[2], components[3], components[4]) as T;
                case 6:
                  yield (components[0], components[1], components[2], components[3], components[4], components[5]) as T;
              }
            } catch (_) {
              //
            }
          }
        }
      };
}

extension _ListExtension<T> on List<T> {
  bool containsNot(T element) => !contains(element);
}
