import 'package:flecs/flecs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_flecs/src/flecs.dart';

typedef ChildBuilder<T> = Widget Function(T);

class QueryBuilder<T extends Record> extends StatefulWidget {
  final T select;
  final ChildBuilder<T> builder;

  const QueryBuilder({
    super.key,
    required this.select,
    required this.builder,
  });

  @override
  State<StatefulWidget> createState() => _QueryBuilderState<T>();
}

class _QueryBuilderState<T extends Record> extends State<QueryBuilder<T>> {
  late final Context flecsContext;
  late final SystemBuilder<T> builder;
  Widget? child;

  @override
  void initState() {
    flecsContext = Flecs.of(context).flecsContext;
    builder = (context) => System(widget.select, handler: (data) {
          setState(() {
            child = widget.builder(data);
          });
        });

    super.initState();

    flecsContext.world.addSystem(builder);
  }

  @override
  void dispose() {
    super.dispose();

    flecsContext.world.removeSystem(builder);
  }

  @override
  Widget build(BuildContext context) => child ?? Container();
}
