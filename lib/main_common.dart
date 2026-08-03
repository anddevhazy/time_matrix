import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/global/constants/app_theme.dart';
import 'features/global/routes/routes.dart';
import 'features/task_matrix/presentation/cubit/task_cubit.dart';
import 'main_injection_container.dart' as di;
import 'service_locator.dart';

Future<void> mainCommon() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const TimeMatrixApp());
}

class TimeMatrixApp extends StatelessWidget {
  const TimeMatrixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<TaskCubit>()),
      ],
      child: MaterialApp.router(
        title: 'Time Matrix',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: Routes.router,
      ),
    );
  }
}
