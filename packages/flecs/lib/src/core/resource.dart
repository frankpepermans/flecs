part of core;

class Resource<T extends Object> {
  final Context context;

  const Resource(this.context);

  T get resource => context.world._fetchResource();
}

class ResourceNotFoundError<T extends Object> extends Error {
  ResourceNotFoundError();

  @override
  String toString() =>
      "Resource not found: $T\nPerhaps you forgot to add the resource?";
}
