class AppRoutes {
  static const login = _Route(name: 'login', path: '/login');
  static const messages = _Route(name: 'messages', path: '/messages');
  static const dashBoard = _Route(name: 'dashboard', path: '/dashboard');
  static const home = _Route(name: 'home', path: '/home');
  
  static const List<_Route> all = [login, messages, dashBoard, home];
}

class _Route {
  final String name;
  final String path;
  const _Route({required this.name, required this.path});
}

