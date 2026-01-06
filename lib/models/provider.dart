abstract class Provider {

  // Abstract static method enforcement via factory method
  static void add() {
    throw UnimplementedError('add() is not implemented');
  }

  static void delete() {
    throw UnimplementedError('delete() is not implemented');
  }

  static void edit() {
    throw UnimplementedError('edit() is not implemented');
  }

  static Stream<List<Provider>> subscribe(dynamic key) {
    throw UnimplementedError('subscribe() is not implemented');
  }

  static List<Provider> fetch(dynamic key) {
    throw UnimplementedError('subscribe() is not implemented');
  }
}
