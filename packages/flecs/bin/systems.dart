import 'package:flecs/src/context.dart';
import 'package:flecs/src/events.dart';
import 'package:flecs/src/query.dart';
import 'package:flecs/src/resource.dart';
import 'package:flecs/src/system.dart';

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
    Query<(TaskDuration, Name, Location, Owner)>(context),
    Query<(Name, TaskDuration, Location)>(context),
    EventWriter<ChangeNameEvent>(context),
    EventWriter<SpawnEntityEvent>(context),
  ), handler: (data) {
    print('Query<(TaskDuration, Name, Location, Owner)>: ');
    for (final result in data.$1.iter()) {
      print(' hi ${result.record.$4}, please take care of "${result.record.$2}" in the ${result.record.$3}, it should not take more than ${result.record.$1} seconds');

      if (result.record.$2.value == 'washing the dishes') {
        data.$3.send(ChangeNameEvent(result.entity, prevName: result.record.$2, nextName: const Name('mowing the lawn')));
        data.$4.send(SpawnEntityEvent(result.entity));
      }
    }

    /*for (final result in data.$1.iter()) {
            print(' hi again ${result.record.$4}, please take care of "${result.record.$2}" in the ${result.record.$3}, it should not take more than ${result.record.$1} seconds');
          }*/

    print('Query<(Name, TaskDuration, Location)>: ');
    for (final result in data.$2.iter()) {
      print(' could anyone please take care of "${result.record.$1}" in the ${result.record.$3}, it should not take more than ${result.record.$2} seconds');
    }
  });