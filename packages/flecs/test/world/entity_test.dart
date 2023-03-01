import 'dart:async';

import 'package:flecs/flecs.dart';
import 'package:test/test.dart';

void main() {
  group('Entity', () {
    late StreamController controller;
    late Context context;

    setUp(() {
      controller = StreamController.broadcast(sync: true);
      context = Context(scheduler: controller.stream);
    });

    tearDown(() => controller.close());

    test('- can spawn and despawn', () async {
      final query = Query<(Entity,)>();
      final entity = context.world.spawn();

      expect(query.iter(context).length, 1);
      expect(query.iter(context).map((data) => data.$1).contains(entity), isTrue);

      entity.despawn();

      expect(query.iter(context).map((data) => data.$1).contains(entity), isFalse);
    });

    test('- can add components', () async {
      final query = Query<(Entity, int, bool)>();
      final entity = context.world.spawn()..addComponent(1)..addComponent(true);

      expect(query.iter(context).length, 1);
      expect(query.iter(context).map((data) => data.$1).contains(entity), isTrue);
      expect(query.iter(context).map((data) => data.$2).contains(1), isTrue);
      expect(query.iter(context).map((data) => data.$3).contains(true), isTrue);
    });

    test('- can overwrite components', () async {
      final query = Query<(Entity, int)>();
      final entity = context.world.spawn()..addComponent(1)..addComponent(2);

      expect(query.iter(context).length, 1);
      expect(query.iter(context).map((data) => data.$1).contains(entity), isTrue);
      expect(query.iter(context).map((data) => data.$2).contains(2), isTrue);
    });

    test('- can remove components', () async {
      final query = Query<(Entity, int)>();

      context.world.spawn()..addComponent(1)..removeComponent<int>();

      expect(query.iter(context), isEmpty);
    });
  });
}
