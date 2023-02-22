import 'package:example/events.dart';
import 'package:flecs/flecs.dart';

final updateSystem = SystemProvider.builder((context) =>
    System((EventReader<IntUpdater>(context),), handler: (data) {
      for (final it in data.$1.iter()) {
        it.entity.addComponent(it.updateValue);
      }
    }));