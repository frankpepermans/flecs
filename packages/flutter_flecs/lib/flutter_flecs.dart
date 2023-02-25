library flutter_flecs;

import 'package:flecs/flecs.dart';
import 'package:flutter/widgets.dart';

import 'src/flecs.dart';

export 'src/flecs.dart';
export 'src/flecs_builder.dart';
export 'src/query_builder.dart';

extension FlecsContextExtension on BuildContext {
  Context get flecs => Flecs.of(this).flecsContext;
}
