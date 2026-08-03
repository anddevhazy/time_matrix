import 'package:go_router/go_router.dart';

import '../../task_matrix/presentation/pages/matrix_page.dart';

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
        builder: (context, state) => const MatrixPage(),
      ),
    ],
  );
}
