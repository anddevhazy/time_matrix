import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'features/auth/auth_injection_container.dart';
import 'features/task_matrix/task_matrix_injection_container.dart';
import 'service_locator.dart';

Future<void> init() async {
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);

  await authInjectionContainer();
  await taskMatrixInjectionContainer();
}
