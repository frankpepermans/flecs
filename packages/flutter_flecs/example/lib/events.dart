import 'package:flecs/flecs.dart';

class IntUpdater extends Event {
  final int updateValue;

  IntUpdater(Entity entity, this.updateValue) : super(entity);
}
