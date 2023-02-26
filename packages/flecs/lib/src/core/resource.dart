part of core;

class Resource<T extends Object> {
  const Resource();

  T value(Context context) => context.world._fetchResource();
}

class ResourceNotFoundError<T extends Object> extends Error {
  ResourceNotFoundError();

  @override
  String toString() =>
      "Resource not found: $T\nPerhaps you forgot to add the resource?";
}
