library core;

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flecs/flecs.dart';
import 'package:meta/meta.dart';
import 'package:quiver/core.dart';

part 'core/entity.dart';
part 'core/event.dart';
part 'core/query.dart';
part 'core/resource.dart';
part 'core/world.dart';

enum _SchedulerPhase { start, end }

typedef _Combiner = Iterable<List<Type>> Function(Type it, List<Type> data);

class _QueryTransaction {
  final Set<Type> componentTypes;
  final List<Entity> entities;

  _QueryTransaction({
    required this.entities,
    required this.componentTypes,
  });
}
