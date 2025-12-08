import 'package:facility/app/app.dart';
import 'package:facility/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() => const App());
}
