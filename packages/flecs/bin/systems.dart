import 'package:flecs/src/context.dart';
import 'package:flecs/src/core.dart';

import 'components.dart';
import 'events.dart';
import 'repositories.dart';

final updateSystem = (Context context) => System((
    const EventReader<ChangeNameEvent>(),
    const EventReader<SpawnEntityEvent>(),
    const Resource<TaskRepository>(),
  ), handler: (data) {
    for (final event in data.$1.iter(context)) {
      event.entity.addComponent(event.nextName);
    }

    for (final _ in data.$2.iter(context)) {
      data.$3.value(context).write();

      context.world.spawn()
          .addComponent(const Name('walking the dog'))
          .addComponent(const TaskDuration(10000))
          .addComponent(const Owner(Name('Ayden')))
          .addComponent(const Location(Name('park')));
    }
  });

final renderSystem = (Context context) => System((
    Query<(TaskDuration, Name, Location, Owner, Entity)>(),
    Query<(Name, TaskDuration, Location)>(),
    EventWriter<ChangeNameEvent>(),
    EventWriter<SpawnEntityEvent>(),
  ), handler: (data) {
    print('Query<(TaskDuration, Name, Location, Owner, Entity)>: ');
    for (final (duration, name, location, owner, entity) in data.$1.iter(context)) {
      print(' hi $owner, please take care of "$name" in the $location, it should not take more than $duration seconds');

      if (name.value == 'washing the dishes') {
        final (changeNameWriter, spawnEntityWriter) = (data.$3, data.$4);
        changeNameWriter.send(ChangeNameEvent(entity, prevName: name, nextName: const Name('mowing the lawn')));
        spawnEntityWriter.send(SpawnEntityEvent(entity));
      }
    }

    /*for (final result in data.$1.iter()) {
            print(' hi again ${result.record.$4}, please take care of "${result.record.$2}" in the ${result.record.$3}, it should not take more than ${result.record.$1} seconds');
          }*/

    print('Query<(Name, TaskDuration, Location)>: ');
    for (final (name, duration, location) in data.$2.iter(context)) {
      print(' could anyone please take care of "$name" in the $location, it should not take more than $duration seconds');
    }
  });