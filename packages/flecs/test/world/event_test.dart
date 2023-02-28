import 'dart:async';

import 'package:flecs/flecs.dart';
import 'package:test/test.dart';

void main() {
  group('Event', () {
    late StreamController controller;
    late Context context;

    setUp(() {
      controller = StreamController.broadcast(sync: true);
      context = Context(scheduler: controller.stream);
    });

    tearDown(() => controller.close());

    test('- can send events and listen to them', () async {
      final entity = context.world.spawn();
      final writer = EventWriter<TestEvent>();
      final reader = EventReader<TestEvent>();

      writer.send(context, TestEvent(entity, 'foo'));

      controller.add(1);

      expect(reader.iter(context).length, 1);
      expect(reader.iter(context).first, isA<TestEvent>());
      expect(reader.iter(context).first.message, 'foo');
    });

    test('- can use subclasses', () async {
      final entity = context.world.spawn();
      final writer = EventWriter<AnotherTestEvent>();
      final reader = EventReader<TestEvent>();

      writer.send(context, AnotherTestEvent(entity, 'foo'));

      controller.add(1);

      expect(reader.iter(context).length, 1);
      expect(reader.iter(context).first, isA<TestEvent>());
      expect(reader.iter(context).first.message, 'foo');
    });

    test('- respects Type matches', () async {
      final entity = context.world.spawn();
      final writer = EventWriter<YetAnotherTestEvent>();
      final reader = EventReader<TestEvent>();

      writer.send(context, YetAnotherTestEvent(entity, 'foo'));

      controller.add(1);

      expect(reader.iter(context), isEmpty);
    });
  });
}

class TestEvent extends Event {
  final String message;

  const TestEvent(Entity entity, this.message) : super(entity);
}

class AnotherTestEvent extends TestEvent {
  const AnotherTestEvent(Entity entity, String message)
      : super(entity, message);
}

class YetAnotherTestEvent extends Event {
  final String message;

  const YetAnotherTestEvent(Entity entity, this.message) : super(entity);
}
