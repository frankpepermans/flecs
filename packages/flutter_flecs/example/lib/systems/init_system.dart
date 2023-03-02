import 'package:flecs/flecs.dart';

final initSystem = SystemProvider.builder((context) =>
  System.noParams(() {
    context.world.spawn().addComponent(1);
    context.world.spawn().addComponent(2);
    context.world.spawn().addComponent(3).addComponent(true);
    context.world.spawn().addComponent('test').addComponent(4);
  }));