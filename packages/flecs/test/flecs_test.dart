import 'package:flecs/flecs.dart';
import 'package:test/test.dart';

void main() {
  group('World', () {
    late Context context;

    setUp(() {
      context = Context();
    });

    group(' Resource', () {
      test('  can add and fetch a reference to it', () {
        context.world.addResource(const DummyResource('test'));

        expect(const Resource<DummyResource>().value(context),
            isA<DummyResource>());
        expect(const Resource<DummyResource>().value(context).value, 'test');
      });

      test('  adding of the same Type throws an AssertError', () {
        context.world.addResource(const DummyResource('foo'));

        expect(() => context.world.addResource(const DummyResource('bar')),
            throwsA(isA<AssertionError>()));
      });

      test('  throws when fetched but not added', () {
        expect(() => const Resource<DummyResource>().value(context),
            throwsA(isA<ResourceNotFoundError<DummyResource>>()));
      });
    });
  });
}

class DummyResource {
  final String value;

  const DummyResource(this.value);
}
