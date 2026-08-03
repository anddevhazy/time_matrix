import 'package:shared_preferences/shared_preferences.dart';

import 'features/task_matrix/task_matrix_injection_container.dart';
import 'service_locator.dart';

Future<void> init() async {
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => prefs);

  await taskMatrixInjectionContainer();
}
