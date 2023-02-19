import 'package:flecs/src/context.dart';
import 'package:flecs/src/query.dart';

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
  var didAddTask = false;

  context.world.addSystem(
      (
          Query<(Name,)>(context),
      ),
      handler: (data) async {
        await Future.delayed(const Duration(seconds: 3));

        for (final result in data.$1.iter()) {
          if (result.record.$1.value == 'washing the dishes') {
            result.entity.replaceComponent(result.record.$1, const Name('mowing the lawn'));
          }
        }

        await Future.delayed(const Duration(seconds: 3));

        if (!didAddTask) {
          didAddTask = true;

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
        Query<(Name, TaskDuration, Location)>(context)
      ),
      handler: (data) {
        print('Query<(TaskDuration, Name, Location, Owner)>: ');
        for (final result in data.$1.iter()) {
          print(' hi ${result.record.$4}, please take care of "${result.record.$2}" in the ${result.record.$3}, it should not take more than ${result.record.$1} seconds');
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