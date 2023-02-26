import 'package:example/events.dart';
import 'package:flecs/flecs.dart';

final updateSystem = SystemProvider.builder((context) =>
    System((const EventReader<IntUpdater>(),), handler: (data) {
      for (final it in data.$1.iter(context)) {
        it.entity.addComponent(it.updateValue);
      }
    }));