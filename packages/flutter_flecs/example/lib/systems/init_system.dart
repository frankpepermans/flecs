import 'package:flecs/flecs.dart';

final initSystem = SystemProvider.builder((context) =>
  System.normal(() {
    context.world.spawn().addComponent(1);
    context.world.spawn().addComponent(2);
    context.world.spawn().addComponent(3);
  }));