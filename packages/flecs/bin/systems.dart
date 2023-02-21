import 'package:flecs/src/context.dart';
import 'package:flecs/src/events.dart';
import 'package:flecs/src/query.dart';
import 'package:flecs/src/resource.dart';
import 'package:flecs/src/system.dart';
import 'package:flecs/src/world.dart';

import 'components.dart';
import 'events.dart';
import 'repositories.dart';

updateSystem(Context context) => System.create((
    EventReader<ChangeNameEvent>(context),
    EventReader<SpawnEntityEvent>(context),
    Resource<TaskRepository>(context),
  ), handler: (data) {
    for (final event in data.$1.iter()) {
      event.entity.addComponent(event.nextName);
    }

    for (final _ in data.$2.iter()) {
      data.$3.resource.write();

      context.world.spawn()
          .addComponent(const Name('walking the dog'))
          .addComponent(const TaskDuration(10000))
          .addComponent(const Owner(Name('Ayden')))
          .addComponent(const Location(Name('park')));
    }
  });

renderSystem(Context context) => System.create((
    Query<(TaskDuration, Name, Location, Owner, Entity)>(context),
    Query<(Name, TaskDuration, Location)>(context),
    EventWriter<ChangeNameEvent>(context),
    EventWriter<SpawnEntityEvent>(context),
  ), handler: (data) {
    print('Query<(TaskDuration, Name, Location, Owner, Entity)>: ');
    for (final (duration, name, location, owner, entity) in data.$1.iter()) {
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
    for (final (name, duration, location) in data.$2.iter()) {
      print(' could anyone please take care of "$name" in the $location, it should not take more than $duration seconds');
    }
  });