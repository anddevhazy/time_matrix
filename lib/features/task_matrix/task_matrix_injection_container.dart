import 'data/data_sources/local/task_local_data_source.dart';
import 'data/data_sources/local/task_local_data_source_impl.dart';
import 'data/repository/task_repository_impl.dart';
import 'domain/repositories/task_repository.dart';
import 'domain/usecases/add_task_usecase.dart';
import 'domain/usecases/delete_task_usecase.dart';
import 'domain/usecases/get_tasks_usecase.dart';
import 'domain/usecases/update_task_usecase.dart';
import 'presentation/cubit/task_cubit.dart';
import '../../service_locator.dart';

Future<void> taskMatrixInjectionContainer() async {
  sl.registerFactory(
    () => TaskCubit(
      getTasksUsecase: sl(),
      addTaskUsecase: sl(),
      updateTaskUsecase: sl(),
      deleteTaskUsecase: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetTasksUsecase(sl()));
  sl.registerLazySingleton(() => AddTaskUsecase(sl()));
  sl.registerLazySingleton(() => UpdateTaskUsecase(sl()));
  sl.registerLazySingleton(() => DeleteTaskUsecase(sl()));

  sl.registerLazySingleton<TaskRepository>(() => TaskRepositoryImpl(sl()));

  sl.registerLazySingleton<TaskLocalDataSource>(() => TaskLocalDataSourceImpl(sl()));
}
