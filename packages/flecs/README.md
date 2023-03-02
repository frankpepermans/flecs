Flecs is an experimental library which aims to provide a similar API
as [bevy_ecs](https://docs.rs/bevy_ecs/latest/bevy_ecs/),
which is an open-source Rust library for ECS (Entity Component System).

It currently relies on an experimental Dart feature Records, so please make sure to have
a dev channel SDK installed.

You can then run code via:
```
dart --enable-experiment=records ...
```

## What?

Entity Component System (ECS) is a software architectural pattern mostly used in
video game development for the representation of game world objects.
An ECS comprises entities composed from components of data,
with systems which operate on entities' components.

ECS follows the principle of composition over inheritance,
meaning that every entity is defined not by a type hierarchy,
but by the components that are associated with it.
Systems act globally over all entities which have the required components.

## How it works

With an ECS, you have a `World`, which contains basically all the data related to the application.
This world can contain both `Resources` and `Entities`:

- A resource is typically a single entry, which is often referenced to within `Systems`.
- An Entity is an entry point for Components, the combined components that are added to it, make up more complex data structures.

For example:

```dart
final context = Context();

// add a resource
context.world.addResource(const Size(width: 100.0, height: 200.0));

// add entities
context.world.spawn() // creates a new Entity
  ..addComponent(const Name('test')) // add components
  ..addComponent(const Price(100.0));
```

Now that the world has data, we can start building `Systems`. Context contains a loop scheduler, on every
loop instance, the world detects if any data has changed, and if that is the case, it then runs all systems
that it was given.

```dart
final mySystem = SystemProvider.builder((context) => System((
    const Resource<Size>(),
    const Query<(Name, Price)>(),
), handler: ((size, query)) {
    print('size is ${size.width} - ${size.height}');
    for (final (name, price) in query.iter(context)) {
      print('Name ${name.value} costs ${price.value}');
    }
}));

// add the system
context.world.addSystem(mySystem);
```

## Getting started

The core Flecs library is written in pure Dart and can be found under [packages/flecs](https://github.com/frankpepermans/flecs/tree/master/packages/flecs).

The Flutter library introduces widgets to readily use Flecs and can be found under [packages/flutter_flecs](https://github.com/frankpepermans/flecs/tree/master/packages/flutter_flecs).

## Usage

```dart
/// prints
/// 
/// Event doctor appointment planned at Main Street 12, 782010 Springfield!
/// Event holiday at the beach has no location...
/// 
/// Event doctor appointment planned at Main Street 12, 782010 Springfield!
/// Event holiday at the beach has no location...
/// 
/// Event doctor appointment planned at Main Street 12, 782010 Springfield!
/// Event holiday at the beach planned at Unknown location!
/// 
/// Because of the main loop, systems are executed whenever data changes or when events are fired,
/// so we do get multiple updates as systems run multiple times,
/// until they idle when no more changes are detected.
void main() {
  final context = Context();

  // creates a System which runs just once, on startup
  final initSystem = SystemProvider.builder((context) => System.noParams(() {
    // spawn some entities
    context.world.spawn()
      ..addComponent(const EventName('doctor appointment'))
      ..addComponent(const Location('Main Street 12, 782010 Springfield'))
      ..addComponent(StartDate(DateTime.parse('2023-02-27 13:00:00')))
      ..addComponent(EndDate(DateTime.parse('2023-02-27 13:30:00')));

    context.world.spawn()
      ..addComponent(const EventName('holiday at the beach'))
      ..addComponent(StartDate(DateTime.parse('2023-03-29')))
      ..addComponent(
          MiscEventParams(isAllDayEvent: true, isMultiPersonEvent: true));
  }));

  // query some data
  final demoSystem = SystemProvider.builder((context) => System((
      const Query<(EventName, Location)>(),
      const Query<(Entity, EventName)>().excluding<Location>(),
      const EventWriter<MissingLocationEvent>(),
  ), handler: ((queryA, queryB, eventWriter)) {
    for (final (eventName, location) in queryA.iter(context)) {
      print('Event ${eventName.value} planned at ${location.value}!');
    }

    for (final (entity, eventName,) in queryB.iter(context)) {
      print('Event ${eventName.value} has no location...');
      // send an event which notifies about a missing Location
      eventWriter.send(context, MissingLocationEvent(entity));
    }
  }));

  // update some data
  final updateSystem = SystemProvider.builder((context) => System((
    const EventReader<MissingLocationEvent>(),
  ), handler: ((eventReader,)) {
      for (final event in eventReader.iter(context)) {
        // receive an event which notifies about a missing Location
        event.entity.addComponent(const Location('Unknown location'));
      }
  }));

  context.world
    ..addStartupSystem(initSystem)
    ..addSystem(demoSystem)
    ..addSystem(updateSystem);
}

class EventName {
  final String value;

  const EventName(this.value);
}

class Location {
  final String value;

  const Location(this.value);
}

class StartDate {
  final DateTime value;

  const StartDate(this.value);
}

class EndDate {
  final DateTime value;

  const EndDate(this.value);
}

class MiscEventParams {
  final bool isAllDayEvent;
  final bool isMultiPersonEvent;

  const MiscEventParams({
    required this.isAllDayEvent,
    required this.isMultiPersonEvent,
  });
}

class MissingLocationEvent extends Event {
  MissingLocationEvent(super.entity);
}
```
