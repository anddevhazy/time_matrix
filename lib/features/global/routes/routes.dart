import 'package:go_router/go_router.dart';

import '../../auth/presentation/widgets/auth_gate.dart';

class Routes {
  const Routes._();

  static const String matrixPath = '/';
  static const String matrixName = 'matrix';

  static final GoRouter router = GoRouter(
    initialLocation: matrixPath,
    routes: [
      GoRoute(
        path: matrixPath,
        name: matrixName,
        builder: (context, state) => const AuthGate(),
      ),
    ],
  );
}
