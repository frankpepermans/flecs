import 'package:flecs/src/events.dart';
import 'package:flecs/src/world.dart';

import 'components.dart';

class ChangeNameEvent extends Event {
  final Name prevName, nextName;

  ChangeNameEvent(
      Entity entity, {
        required this.prevName,
        required this.nextName,
      }) : super(entity);
}

class SpawnEntityEvent extends Event {
  SpawnEntityEvent(Entity entity) : super(entity);
}