import 'package:my_app/app/app.dart';
import 'package:my_app/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() => const App());
}
