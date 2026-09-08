import '../../service_locator.dart';
import 'data/data_sources/remote/dump_remote_data_source.dart';
import 'data/data_sources/remote/dump_remote_data_source_impl.dart';
import 'data/repository/dump_repository_impl.dart';
import 'domain/repositories/dump_repository.dart';
import 'domain/usecases/add_dump_entry_usecase.dart';
import 'domain/usecases/delete_dump_entries_usecase.dart';
import 'domain/usecases/watch_dump_entries_usecase.dart';
import 'presentation/cubit/dump_cubit.dart';

Future<void> mindDumpInjectionContainer() async {
  sl.registerFactory(
    () => DumpCubit(
      watchDumpEntriesUsecase: sl(),
      addDumpEntryUsecase: sl(),
      deleteDumpEntriesUsecase: sl(),
      addTaskUsecase: sl(),
    ),
  );

  sl.registerLazySingleton(() => WatchDumpEntriesUsecase(sl()));
  sl.registerLazySingleton(() => AddDumpEntryUsecase(sl()));
  sl.registerLazySingleton(() => DeleteDumpEntriesUsecase(sl()));

  sl.registerLazySingleton<DumpRepository>(() => DumpRepositoryImpl(sl()));

  sl.registerLazySingleton<DumpRemoteDataSource>(
    () => DumpRemoteDataSourceImpl(sl(), sl()),
  );
}
