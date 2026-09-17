import '../../service_locator.dart';
import 'data/data_sources/remote/task_remote_data_source.dart';
import 'data/data_sources/remote/task_remote_data_source_impl.dart';
import 'data/repository/task_repository_impl.dart';
import 'domain/repositories/task_repository.dart';
import 'domain/usecases/add_task_usecase.dart';
import 'domain/usecases/delete_task_usecase.dart';
import 'domain/usecases/reorder_tasks_usecase.dart';
import 'domain/usecases/update_task_usecase.dart';
import 'domain/usecases/watch_tasks_usecase.dart';
import 'presentation/cubit/task_cubit.dart';

Future<void> taskMatrixInjectionContainer() async {
  sl.registerFactory(
    () => TaskCubit(
      watchTasksUsecase: sl(),
      addTaskUsecase: sl(),
      updateTaskUsecase: sl(),
      deleteTaskUsecase: sl(),
      reorderTasksUsecase: sl(),
    ),
  );

  sl.registerLazySingleton(() => WatchTasksUsecase(sl()));
  sl.registerLazySingleton(() => AddTaskUsecase(sl()));
  sl.registerLazySingleton(() => UpdateTaskUsecase(sl()));
  sl.registerLazySingleton(() => DeleteTaskUsecase(sl()));
  sl.registerLazySingleton(() => ReorderTasksUsecase(sl()));

  sl.registerLazySingleton<TaskRepository>(() => TaskRepositoryImpl(sl()));

  sl.registerLazySingleton<TaskRemoteDataSource>(
    () => TaskRemoteDataSourceImpl(sl(), sl()),
  );
}
