import 'package:flecs/flecs.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_flecs/src/flecs.dart';

class FlecsBuilder extends StatelessWidget {
  final Widget Function(Context) builder;

  const FlecsBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) => builder(Flecs.of(context).flecsContext);
}