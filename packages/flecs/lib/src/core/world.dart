part of core;

/// A [World] is a collection of all data that can be requested.
class World {
  final Context _context;
  final Set<Type> _componentTypes = <Type>{};
  final List<Entity> _entities = <Entity>[];
  final _ScheduledList<Event> _events = _ScheduledList<Event>();
  final List<Object> _resources = <Object>[];
  late final StreamSubscription<_SchedulerPhase> _schedulerEndListener;
  final List<_SystemRunner<Record>> _runners = <_SystemRunner<Record>>[];
  late final Stream<_SchedulerPhase> _schedulerPre =
      _scheduler.where((it) => it == _SchedulerPhase.pre);
  late final Stream<_SchedulerPhase> _schedulerStart =
      _scheduler.where((it) => it == _SchedulerPhase.start);
  late final Stream<_SchedulerPhase> _schedulerEnd =
      _scheduler.where((it) => it == _SchedulerPhase.end);
  final Stream<_SchedulerPhase> _scheduler;

  int get _entitiesHashCode =>
      hashObjects(_entities.map((it) => it._componentsHashCode));

  /// Creates a new [World] within the referenced [Context].
  World(this._context)
      : _scheduler = _context.scheduler
            .map((_) => [
                  _SchedulerPhase.pre,
                  _SchedulerPhase.start,
                  _SchedulerPhase.end
                ])
            .expand((it) => it) {
    _schedulerEndListener = _schedulerEnd.listen((_) {
      _events.update();

      for (final entity in _entities) {
        entity._clearDelta();
      }
    });
  }

  /// Should be invoked whenever this [World] is no longer needed, as it performs
  /// some necessary cleanup, such as terminating all [System] subscribers.
  @mustCallSuper
  void dispose() {
    _schedulerEndListener.cancel();

    for (final it in _runners) {
      it.subscription.cancel();
    }

    _entities.clear();
    _componentTypes.clear();
    _resources.clear();
    _runners.clear();
  }

  /// Registers a new [Resource] into the [World].
  /// You can only register a single resource per Type, for example
  ///
  /// ```dart
  /// // adding 2 Strings is not allowed
  /// context.world.addResource('one');
  /// context.world.addResource('two'); // throws, because a String resource was already added.
  ///
  /// // instead, use a custom class to provide more String values,
  /// // or use a custom class which contains multiple String values:
  ///
  /// context.world.addResource(const One('one'));
  /// context.world.addResource(const Two('two')); // ok, since One and Two are different Types.
  ///
  /// class One {
  ///   final String value;
  ///
  ///   const One(this.value);
  /// }
  ///
  /// class Two {
  ///   final String value;
  ///
  ///   const Two(this.value);
  /// }
  /// ```
  @mustCallSuper
  void addResource<T extends Object>(T resource) {
    assert(
        !_resources.map((it) => it.runtimeType).contains(resource.runtimeType),
        'A resource of Type ${resource.runtimeType} was already added.');

    _resources.add(resource);
  }

  /// Spawns a new [Entity] inside this [World].
  @mustCallSuper
  Entity spawn() {
    final entity = Entity._(this);

    _entities.add(entity);

    return entity;
  }

  /// Adds a system which runs at the very beginning of a [World] loop.
  @mustCallSuper
  void addStartupSystem<T extends Record>(
      SystemBuilder<T> systemBuilder) async {
    await _schedulerPre.first;
    await systemBuilder(_context)._run();
  }

  /// Adds a system which runs on every loop iteration.
  @mustCallSuper
  void addSystem<T extends Record>(SystemBuilder<T> systemBuilder) {
    if (_runners.map((it) => it.builder).contains(systemBuilder)) {
      return;
    }

    final system = systemBuilder(_context);
    var hc = 0;
    final runner =
        _SystemRunner(systemBuilder, _schedulerStart.listen((_) async {
      var hcNow = _entitiesHashCode;

      if (hc != hcNow || _events.hasUpdate) {
        hc = hcNow;

        await system._run();
      }
    }));

    _runners.add(runner);
  }

  /// Removes a system.
  @mustCallSuper
  void removeSystem<T extends Record>(SystemBuilder<T> systemBuilder) {
    final runner =
        _runners.firstWhereOrNull((it) => it.builder == systemBuilder);

    if (runner != null) {
      runner.subscription.cancel();
      _runners.remove(runner);
    }
  }

  @mustCallSuper
  void _addEvent(Event event) => _events.add(event);

  _QueryTransaction _createQueryTransaction() => _QueryTransaction(
        componentTypes: Set.unmodifiable(_componentTypes),
        entities: List.unmodifiable(_entities),
      );

  T _fetchResource<T extends Object>() {
    try {
      return _resources.whereType<T>().single;
    } on StateError {
      throw ResourceNotFoundError<T>();
    }
  }
}

class _SystemRunner<T extends Record> {
  final SystemBuilder<T> builder;
  final StreamSubscription<_SchedulerPhase> subscription;

  _SystemRunner(this.builder, this.subscription);
}
