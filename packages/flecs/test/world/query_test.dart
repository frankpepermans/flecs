import 'dart:async';

import 'package:flecs/flecs.dart';
import 'package:test/test.dart';

void main() {
  group('Query', () {
    late StreamController controller;
    late Context context;

    setUp(() {
      controller = StreamController.broadcast(sync: true);
      context = Context(scheduler: controller.stream);
    });

    tearDown(() => controller.close());

    test('- can query', () async {
      final query = Query<(Entity,)>();
      final entity = context.world.spawn();

      expect(query.iter(context).length, 1);
      expect(query.iter(context).map((data) => data.$1).contains(entity), isTrue);
    });

    test('- matches requested components only', () async {
      final query = Query<(Entity, int, bool)>();

      context.world.spawn()..addComponent(1)..addComponent(true);
      context.world.spawn().addComponent(2);
      context.world.spawn().addComponent(false);

      expect(query.iter(context).length, 1);
      expect(query.iter(context).map((data) => data.$2).contains(1), isTrue);
      expect(query.iter(context).map((data) => data.$3).contains(true), isTrue);
    });

    test('- can use including', () async {
      final query = Query<(Entity,)>().including<bool>().including<int>();

      context.world.spawn()..addComponent(1)..addComponent(true);
      context.world.spawn().addComponent(2);
      context.world.spawn().addComponent(false);

      expect(query.iter(context).length, 1);
    });

    test('- can use excluding', () async {
      final query = Query<(Entity,)>().excluding<bool>();

      context.world.spawn()..addComponent(1)..addComponent(true);
      context.world.spawn().addComponent(2);
      context.world.spawn().addComponent(false);

      expect(query.iter(context).length, 1);
    });

    test('- can use filters', () async {
      final query = Query<(int,)>().where((row) => row.$1 == 2);

      context.world.spawn()..addComponent(1)..addComponent(true);
      context.world.spawn().addComponent(2);
      context.world.spawn().addComponent(false);

      expect(query.iter(context).length, 1);
      expect(query.iter(context).map((it) => it.$1).contains(2), isTrue);
    });
  });
}
