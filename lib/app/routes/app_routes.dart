class AppRoutes {
  static const messages = _Route(name: 'messages');
  
  static const List<_Route> all = [messages];
}

class _Route {
  final String name;
  const _Route({required this.name});
}

