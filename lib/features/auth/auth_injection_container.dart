import '../../service_locator.dart';
import 'data/repository/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/sign_in_with_google_usecase.dart';
import 'domain/usecases/sign_out_usecase.dart';
import 'domain/usecases/watch_auth_state_usecase.dart';
import 'presentation/cubit/auth_cubit.dart';

Future<void> authInjectionContainer() async {
  sl.registerLazySingleton(
    () => AuthCubit(
      watchAuthStateUsecase: sl(),
      signInWithGoogleUsecase: sl(),
      signOutUsecase: sl(),
    ),
  );

  sl.registerLazySingleton(() => WatchAuthStateUsecase(sl()));
  sl.registerLazySingleton(() => SignInWithGoogleUsecase(sl()));
  sl.registerLazySingleton(() => SignOutUsecase(sl()));

  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
}
