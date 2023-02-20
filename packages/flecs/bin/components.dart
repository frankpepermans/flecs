class Name {
  final String value;

  const Name(this.value);

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) =>
      other is Name ? value == other.value : false;

  @override
  String toString() => value;
}

class TaskDuration {
  final int milliseconds;

  const TaskDuration(this.milliseconds);

  @override
  String toString() => milliseconds.toString();
}

class Owner {
  final Name name;

  const Owner(this.name);

  @override
  String toString() => name.toString();
}

class Location {
  final Name name;

  const Location(this.name);

  @override
  String toString() => name.toString();
}
