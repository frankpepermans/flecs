part of core;

class World {
  final Context context;
  final Set<Type> _componentTypes = <Type>{};
  final List<Entity> _entities = <Entity>[];
  final ScheduledList<Event> _events = ScheduledList<Event>();
  final List<Object> _resources = <Object>[];
  late final StreamSubscription<_SchedulerPhase> _schedulerEndListener;
  final List<_SystemRunner<Record>> _runners = <_SystemRunner<Record>>[];
  late final Stream<_SchedulerPhase> _schedulerStart =
      _scheduler.where((it) => it == _SchedulerPhase.start);
  late final Stream<_SchedulerPhase> _schedulerEnd =
      _scheduler.where((it) => it == _SchedulerPhase.end);
  final Stream<_SchedulerPhase> _scheduler;

  int get entitiesHashCode =>
      hashObjects(_entities.map((it) => it._componentsHashCode));

  World(this.context, {required Stream scheduler})
      : _scheduler = scheduler
            .map((_) => [_SchedulerPhase.start, _SchedulerPhase.end])
            .expand((it) => it) {
    _schedulerEndListener = _schedulerEnd.listen((_) => _events.update());
  }

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

  @mustCallSuper
  void addResource<T extends Object>(T resource) => _resources.add(resource);

  @mustCallSuper
  Entity spawn() {
    final entity = Entity._(this);

    _entities.add(entity);

    return entity;
  }

  @mustCallSuper
  void addStartupSystem<T extends Record>(
      SystemBuilder<T> systemBuilder) async {
    final system = systemBuilder(context);

    await system.run();
  }

  @mustCallSuper
  void addSystem<T extends Record>(SystemBuilder<T> systemBuilder) {
    if (_runners.map((it) => it.builder).contains(systemBuilder)) {
      return;
    }

    final system = systemBuilder(context);
    var hc = -1;
    final runner =
        _SystemRunner(systemBuilder, _schedulerStart.listen((_) async {
      var hcNow = entitiesHashCode;

      if (hc != hcNow || _events.hasUpdate) {
        hc = hcNow;

        await system.run();
      }
    }));

    _runners.add(runner);
  }

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
  void addEvent(Event event) => _events.add(event);

  _QueryTransaction _createQueryTransaction() => _QueryTransaction(
    componentTypes: Set.unmodifiable(_componentTypes),
    entities: List.unmodifiable(_entities),
  );

  T _fetchResource<T extends Object>() {
    try {
      return _resources.whereType<T>().first;
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
