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

enum SchedulerPhase { start, end }

typedef Combiner = Iterable<List<Type>> Function(Type it, List<Type> data);

class WorldQuerySession {
  final Set<Type> componentTypes;
  final List<Entity> entities;

  WorldQuerySession({
    required this.entities,
    required this.componentTypes,
  });
}
