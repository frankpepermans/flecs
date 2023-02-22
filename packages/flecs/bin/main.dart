import 'package:flecs/src/context.dart';

import 'components.dart';
import 'repositories.dart';
import 'systems.dart';

void main() {
  final context = Context();

  context.world
    ..addResource(const TaskRepository())
    ..addSystem(updateSystem)
    ..addSystem(renderSystem)
    ..spawn()
        .addComponent(const Name('emptying the trash'))
        .addComponent(const TaskDuration(1000))
        .addComponent('ok')
        .addComponent(const Location(Name('kitchen')))
    ..spawn()
        .addComponent(const Name('washing the dishes'))
        .addComponent(const TaskDuration(1000))
        .addComponent(const Owner(Name('Frank')))
        .addComponent(const Location(Name('kitchen')));
}
