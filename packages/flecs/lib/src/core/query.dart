part of core;

class Query<T extends Record> {
  static final _resolvedTypes = <Type, List<Type>>{};

  final Context context;

  const Query(this.context);

  @mustCallSuper
  Iterable<T> iter() {
    final transaction = context.world._createQueryTransaction();
    final data = [Entity, ...transaction.componentTypes];
    final test = _test(transaction);

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

    return _collect(
        transaction,
        _resolvedTypes.putIfAbsent(T,
            () => data.map((it) => [it]).firstWhere(test, orElse: combineAll)));
  }

  bool Function(List<Type>) _test(_QueryTransaction transaction) =>
      (List<Type> list) {
        //print(list);
        try {
          return _collect(transaction, list).firstOrNull is T;
        } catch (_) {
          //
        }

        return false;
      };

  Iterable<_Combiner> _combineAll(_Combiner f) sync* {
    yield f;
    yield* _combineAll((Type it, List<Type> data) => f(it, data)
        .map((tuple) =>
            data.where(tuple.containsNot).map((other) => [...tuple, other]))
        .expand((it) => it));
  }

  Iterable<T> _collect(_QueryTransaction transaction, List<Type> types) sync* {
    for (final it in transaction.entities) {
      final components = it._componentsFromTypes(types);

      if (components.length == types.length) {
        try {
          switch (components.length) {
            case 1:
              yield (components[0],) as T;
              break;
            case 2:
              yield (components[0], components[1]) as T;
              break;
            case 3:
              yield (components[0], components[1], components[2]) as T;
              break;
            case 4:
              yield (
                components[0],
                components[1],
                components[2],
                components[3]
              ) as T;
              break;
            case 5:
              yield (
                components[0],
                components[1],
                components[2],
                components[3],
                components[4]
              ) as T;
              break;
            case 6:
              yield (
                components[0],
                components[1],
                components[2],
                components[3],
                components[4],
                components[5]
              ) as T;
              break;
            case 7:
              yield (
                components[0],
                components[1],
                components[2],
                components[3],
                components[4],
                components[5],
                components[6]
              ) as T;
              break;
            case 8:
              yield (
                components[0],
                components[1],
                components[2],
                components[3],
                components[4],
                components[5],
                components[6],
                components[7]
              ) as T;
              break;
            case 9:
              yield (
                components[0],
                components[1],
                components[2],
                components[3],
                components[4],
                components[5],
                components[6],
                components[7],
                components[8]
              ) as T;
              break;
            case 10:
              yield (
                components[0],
                components[1],
                components[2],
                components[3],
                components[4],
                components[5],
                components[6],
                components[7],
                components[8],
                components[9]
              ) as T;
              break;
          }
        } catch (_) {
          //
        }
      }
    }
  }
}

extension _ListExtension<T> on List<T> {
  bool containsNot(T element) => !contains(element);
}
