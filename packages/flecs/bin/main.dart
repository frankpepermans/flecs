import 'package:flecs/src/context.dart';
import 'package:flecs/src/events.dart';
import 'package:flecs/src/query.dart';
import 'package:flecs/src/world.dart';

void main() {
  final context = Context();

  context.world.spawn()
    .addComponent(const Name('washing the dishes'))
    .addComponent(const TaskDuration(1000))
    .addComponent(const Owner(Name('Frank')))
    .addComponent(const Location(Name('kitchen')));

  context.world.spawn()
    .addComponent(const Name('emptying the trash'))
    .addComponent(const TaskDuration(1000))
    .addComponent('ok')
    .addComponent(const Location(Name('kitchen')));

  final query3 = Query<(Location,)>(context);

  context.world.addSystem(
      (
        EventReader<ChangeNameEvent>(context),
        EventReader<SpawnEntityEvent>(context),
      )
      , handler: (data) {
    for (final event in data.$1.iter()) {
      event.entity.addComponent(event.nextName);
    }

    for (final _ in data.$2.iter()) {
      context.world.spawn()
          .addComponent(const Name('walking the dog'))
          .addComponent(const TaskDuration(10000))
          .addComponent(const Owner(Name('Ayden')))
          .addComponent(const Location(Name('park')));
    }
  });

  context.world.addSystem(
      (
        Query<(TaskDuration, Name, Location, Owner)>(context),
        Query<(Name, TaskDuration, Location)>(context),
        EventWriter<ChangeNameEvent>(context),
        EventWriter<SpawnEntityEvent>(context),
      ),
      handler: (data) {
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

  print('Query<(Location,)>: ');
  for (final result in query3.iter()) {
    print(' loc! "${result.record.$1}"');
  }
}

class Name {
  final String value;

  const Name(this.value);

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) => other is Name ? value == other.value : false;

  @override
  String toString() => value;
}

class TaskDuration {
  final int milliseconds;

  const TaskDuration(this.milliseconds);

  @override
  String toString() => milliseconds.toString();
}

class Owner {
  final Name name;

  const Owner(this.name);

  @override
  String toString() => name.toString();
}

class Location {
  final Name name;

  const Location(this.name);

  @override
  String toString() => name.toString();
}

class ChangeNameEvent extends Event {
  final Name prevName, nextName;

  ChangeNameEvent(Entity entity, {required this.prevName, required this.nextName}) : super(entity);
}

class SpawnEntityEvent extends Event {
  SpawnEntityEvent(Entity entity) : super(entity);
}