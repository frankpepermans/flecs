import 'package:flecs/flecs.dart';
import 'package:flutter/widgets.dart';

class Flecs extends StatefulWidget {
  final Widget child;
  final List<Object> resources;
  final List<SystemBuilder<Record>> startupSystems;
  final List<SystemBuilder<Record>> systems;

  const Flecs({
    Key? key,
    required this.child,
    this.resources = const [],
    this.systems = const [],
    this.startupSystems = const [],
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => FlecsState();

  static FlecsState of(BuildContext context) {
    final FlecsState? result = context.findAncestorStateOfType<FlecsState>();
    if (result != null) {
      return result;
    }
    throw FlutterError.fromParts(<DiagnosticsNode>[
      ErrorSummary(
        'FlecsState.of() called with a context that does not contain a FlecsState.',
      ),
      ErrorDescription(
        'No FlecsState ancestor could be found starting from the context that was passed to FlecsState.of(). '
        'This usually happens when the context provided is from the same StatefulWidget as that '
        'whose build function actually creates the FlecsState widget being sought.',
      ),
      context.describeElement('The context used was'),
    ]);
  }
}

class FlecsState extends State<Flecs> {
  late final Context flecsContext;

  @override
  void initState() {
    super.initState();

    flecsContext = Context();

    for (final resource in widget.resources) {
      flecsContext.world.addResource(resource);
    }

    for (final builder in widget.startupSystems) {
      flecsContext.world.addStartupSystem(builder);
    }

    for (final builder in widget.systems) {
      flecsContext.world.addSystem(builder);
    }
  }

  @override
  void dispose() {
    super.dispose();

    flecsContext.world.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

abstract class FlecsSetup {
  List<Object> get resources;
  List<SystemBuilder> get startupSystems;
  List<SystemBuilder> get systems;
}
