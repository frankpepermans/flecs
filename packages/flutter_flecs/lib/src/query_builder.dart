import 'package:flecs/flecs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_flecs/flutter_flecs.dart';

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
  @override
  void initState() {
    context.flecs.world.addSystem(_builder);

    super.initState();
  }

  @override
  void dispose() {
    context.flecs.world.removeSystem(_builder);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(widget.select);

  System<T> _builder(Context context) =>
      System(widget.select, handler: (_) => setState(() {}));
}
