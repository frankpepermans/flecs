part of core;

/// A method which runs on each individual query row.
/// returns:
/// - 'true' if the row should be included
/// - 'false' if it should be excluded
typedef QueryFilter<T extends Record> = bool Function(T row);
typedef _EntityFilter = bool Function(Entity entity);

/// A [Query] uses a [Record] of type 'T', and where all values are a Type, to match all entities where
/// its components match the Types in T.
///
/// For example:
/// ```dart
/// // a query which returns entities that have all of Name, Price, IsInStock
/// const Query<(Name, Price, IsInStock)>();
/// ```
///
/// To include the [Entity] within the [Query] data, simply add the 'Entity' type:
/// ```dart
/// const Query<(Entity, Name, Price, IsInStock)>();
/// ```
class Query<T extends Record> {
  static final _resolvedTypes = <Type, List<Type>>{};
  final List<QueryFilter<T>> _filters;
  final List<_EntityFilter> _entityFilters;

  /// Constructs a new [Query].
  const Query()
      : _filters = const [],
        _entityFilters = const [];

  Query._withFilters(
      List<QueryFilter<T>> filters, List<_EntityFilter> entityFilters)
      : _filters = filters,
        _entityFilters = entityFilters;

  /// Adds a filter of [QueryFilter].
  /// ```dart
  /// // filter on products which are in stock only
  /// const Query<(Name, Price, IsInStock)>().where((data) => data.$3);
  /// ```
  Query<T> where(QueryFilter<T> filter) =>
      Query._withFilters([..._filters, filter], _entityFilters);

  /// Dictates that the entity *must* have a component of type [F],
  /// but doesn't include this component in the resulting data.
  Query<T> including<F>() => Query._withFilters(_filters,
      [..._entityFilters, (it) => it._components.containsKey(F)]);

  /// Dictates that the entity *must not* have a component of type [F],
  /// but doesn't include this component in the resulting data.
  Query<T> excluding<F>() => Query._withFilters(_filters,
      [..._entityFilters, (it) => !it._components.containsKey(F)]);

  /// Runs against the parent [World] and returns an [Iterable] where every
  /// element matches a [Record] of type [T].
  @mustCallSuper
  Iterable<T> iter(Context context) {
    final transaction = context.world._createQueryTransaction();
    final data = [Entity, ...transaction.componentTypes];
    final test = _test(transaction);

    if (_resolvedTypes.containsKey(T) && _resolvedTypes[T]!.isEmpty) {
      _resolvedTypes.remove(T);
    }

    List<Type> combineAll() =>
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
            _resolvedTypes.putIfAbsent(
                T,
                () => data
                    .map((it) => [it])
                    .firstWhere(test, orElse: combineAll)))
        .where((it) => _filters.every((filter) => filter(it)));
  }

  bool Function(List<Type>) _test(_QueryTransaction transaction) =>
      (List<Type> list) {
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
      final components = it._componentsFromTypes(types, _entityFilters);

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
