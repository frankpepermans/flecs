import 'package:flecs/src/context.dart';

class Resource<T extends Object> {
  final Context context;

  const Resource(this.context);

  T get resource => context.world.fetchResource();
}