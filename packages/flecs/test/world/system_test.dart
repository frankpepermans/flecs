import 'dart:async';

import 'package:flecs/flecs.dart';
import 'package:test/test.dart';

void main() {
  group('System', () {
    late StreamController controller;
    late Context context;

    setUp(() {
      controller = StreamController.broadcast(sync: true);
      context = Context(scheduler: controller.stream);
    });

    tearDown(() => controller.close());

    test('- runs on loop iteration, but only when change is detected', () async {
      int tick = 0;
      final system = SystemProvider.builder((context) => System((Query<(Entity, int)>(),), handler: (_) => tick++));

      context.world.addSystem(system);
      context.world.spawn()..addComponent(1)..addComponent(true);

      controller..add(1)..add(2)..add(3);

      expect(tick, 1);
    });

    test('- runs on loop iteration, inner system changes are detected', () async {
      int tickA = 0, tickB = 0;
      final query = const Query<(Entity, int, bool)>();
      final systemA = SystemProvider.builder((context) => System((query,), handler: (data) {
        for (final row in data.$1.iter(context)) {
          tickA++;
          row.$1.addComponent(false);
        }
      }));
      final systemB = SystemProvider.builder((context) => System((query,), handler: (data) {
        for (final row in data.$1.iter(context)) {
          tickB++;
          row.$1.addComponent(2);
        }
      }));

      context.world..addSystem(systemA)..addSystem(systemB);
      final entity = context.world.spawn()..addComponent(1)..addComponent(true);

      controller..add(1)..add(2)..add(3);

      expect(tickA, 2);
      expect(tickB, 2);
      expect(query.iter(context).first, (entity, 2, false));
    });
  });
}
