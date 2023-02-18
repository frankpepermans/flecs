import 'package:flecs/src/context.dart';
import 'package:flecs/src/query.dart';

void main() {
  final context = Context();

  context.world.spawn()
    .addComponent(const Name('washing the dishes'))
    .addComponent(const Duration(1000))
    .addComponent(const Owner(Name('Frank')))
    .addComponent(const Location(Name('kitchen')));

  context.world.spawn()
    .addComponent(const Name('emptying the trash'))
    .addComponent(const Duration(1000))
    .addComponent('ok')
    .addComponent(const Location(Name('kitchen')));

  final query1 = Query<(Duration, Name, Location, Owner)>(context);
  final query2 = Query<(Name, Duration, Location)>(context);
  final query3 = Query<(Location, Owner)>(context);

  print('Query<(Duration, Name, Location, Owner)>: ');
  for (final result in query1.exec()) {
    print(' hi ${result.record.$4}, please take care of "${result.record.$2}" in the ${result.record.$3}, it should not take more than ${result.record.$1} seconds');
  }

  for (final result in query1.exec()) {
    print(' hi again ${result.record.$4}, please take care of "${result.record.$2}" in the ${result.record.$3}, it should not take more than ${result.record.$1} seconds');
  }

  print('Query<(Name, Duration, Location)>: ');
  for (final result in query2.exec()) {
    print(' could anyone please take care of "${result.record.$1}" in the ${result.record.$3}, it should not take more than ${result.record.$2} seconds');
  }

  print('Query<(Location, Owner)>: ');
  for (final result in query3.exec()) {
    print(' loc! "${result.record.$1}"');
  }
}

class Name {
  final String value;

  const Name(this.value);

  @override
  String toString() => value;
}

class Duration {
  final int milliseconds;

  const Duration(this.milliseconds);

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