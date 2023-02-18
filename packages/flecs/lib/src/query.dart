import 'package:collection/collection.dart';
import 'package:flecs/src/context.dart';
import 'package:flecs/src/world.dart';

class Query<T extends Record> {
  static final _resolvedTypes = <Type, List<Type>>{};

  final Context context;

  const Query(this.context);

  List<QueryRecord<T>> exec() {
    final data = context.world.componentTypes.toList(growable: false);
    var indices = _resolvedTypes[T] ?? <Type>[];

    collect(List<Type> types) {
      return context.world.entities.where((it) => it.every(types)).map((it) {
        switch (types.length) {
          case 0:
            return (it, () as T);
          case 1:
            return (it, (it.componentByType(types[0])) as T);
          case 2:
            return (it, (it.componentByType(types[0]), it.componentByType(types[1])) as T);
          case 3:
            return (it, (it.componentByType(types[0]), it.componentByType(types[1]), it.componentByType(types[2])) as T);
          case 4:
            return (it, (it.componentByType(types[0]), it.componentByType(types[1]), it.componentByType(types[2]), it.componentByType(types[3])) as T);
          case 5:
            return (it, (it.componentByType(types[0]), it.componentByType(types[1]), it.componentByType(types[2]), it.componentByType(types[3]), it.componentByType(types[4])) as T);
          case 6:
            return (it, (it.componentByType(types[0]), it.componentByType(types[1]), it.componentByType(types[2]), it.componentByType(types[3]), it.componentByType(types[4]), it.componentByType(types[5])) as T);
        }
      });
    }

    level1(List<Type> data) => (it) => data
        .where((other) => other != it)
        .map((other) {
      indices = [it, other];
      return (it, other);
    });

    level2(List<Type> data) => (it) => level1(data)(it)
        .map((tuple) => data
        .where((other) => other != tuple.$1 && other != tuple.$2)
        .map((other) {
      indices = [tuple.$1, tuple.$2, other];
      return (tuple.$1, tuple.$2, other);
    })
    ).expand((it) => it);

    level3(List<Type> data) => (it) => level2(data)(it)
        .map((tuple) => data
        .where((other) => other != tuple.$1 && other != tuple.$2 && other != tuple.$3)
        .map((other) {
      indices = [tuple.$1, tuple.$2, tuple.$3, other];
      return (tuple.$1, tuple.$2, tuple.$3, other);
    })
    ).expand((it) => it);

    level4(List<Type> data) => (it) => level3(data)(it)
        .map((tuple) => data
        .where((other) => other != tuple.$1 && other != tuple.$2 && other != tuple.$3 && other != tuple.$4)
        .map((other) {
      indices = [tuple.$1, tuple.$2, tuple.$3, tuple.$4, other];
      return (tuple.$1, tuple.$2, tuple.$3, tuple.$4, other);
    })
    ).expand((it) => it);

    level5(List<Type> data) => (it) => level4(data)(it)
        .map((tuple) => data
        .where((other) => other != tuple.$1 && other != tuple.$2 && other != tuple.$3 && other != tuple.$4 && other != tuple.$5)
        .map((other) {
      indices = [tuple.$1, tuple.$2, tuple.$3, tuple.$4, tuple.$5, other];
      return (tuple.$1, tuple.$2, tuple.$3, tuple.$4, tuple.$5, other);
    })
    ).expand((it) => it);

    if (indices.isEmpty) {
      [level1, level2, level3, level4, level5]
          .map((level) => data.map(level(data))
          .expand((it) => it)
          .firstWhereOrNull((it) => it.toString() == T.toString()),
      ).firstWhereOrNull((it) => it != null);

      _resolvedTypes[T]  = indices;
    }

    return List.unmodifiable(collect(indices).map((it) => QueryRecord._(it!.$1, it.$2)));
  }
}

class QueryRecord<T extends Record> {

  final Entity entity;
  final T record;

  const QueryRecord._(this.entity, this.record);

}