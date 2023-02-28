import 'dart:async';

import 'package:flecs/flecs.dart';
import 'package:test/test.dart';

void main() {
  group('Resource', () {
    late StreamController controller;
    late Context context;

    setUp(() {
      controller = StreamController.broadcast(sync: true);
      context = Context(scheduler: controller.stream);
    });

    tearDown(() => controller.close());

    test('- can add and fetch a reference to it', () {
      context.world.addResource(const DummyResource('test'));

      controller.add(1);

      expect(const Resource<DummyResource>().value(context),
          isA<DummyResource>());
      expect(const Resource<DummyResource>().value(context).value, 'test');
    });

    test('- adding of the same Type throws an AssertError', () {
      context.world.addResource(const DummyResource('foo'));

      controller.add(1);

      expect(() => context.world.addResource(const DummyResource('bar')),
          throwsA(isA<AssertionError>()));
    });

    test('- throws when fetched but not added', () {
      controller.add(1);

      expect(() => const Resource<DummyResource>().value(context),
          throwsA(isA<ResourceNotFoundError<DummyResource>>()));
    });
  });
}

class DummyResource {
  final String value;

  const DummyResource(this.value);
}
