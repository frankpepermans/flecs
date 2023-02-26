import 'package:example/events.dart';
import 'package:flecs/flecs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flecs/flutter_flecs.dart';

class TasksView extends StatelessWidget {
  const TasksView({super.key});

  @override
  Widget build(BuildContext context) => QueryBuilder(
        select: (
          const Query<(int, Entity)>().excluding<String>(),
          const EventWriter<IntUpdater>(),
          const Resource<String>(),
        ),
        builder: (flecs, data) {
          final query = data.$1;
          final eventWriter = data.$2;
          final iter = query.iter(flecs).toList(growable: false);

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: ListView.builder(itemBuilder: (context, index) {
              final entry = iter[index];
              final value = entry.$1;
              final entity = entry.$2;

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('task $value'),
                  ElevatedButton(
                    onPressed: () =>
                        eventWriter.send(
                            context.flecs,
                            IntUpdater(entity, value + 1),
                        ),
                    child: const Text('add 1!'),
                  ),
                ],
              );
            },
            itemCount: iter.length,
          ),);
        });
}