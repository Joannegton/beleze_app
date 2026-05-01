import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/salon/data/datasources/salon_remote_datasource.dart';
import '../../features/salon/data/repositories/appointment_repository_impl.dart';
import '../../features/salon/data/repositories/professional_block_repository_impl.dart';
import '../../features/salon/data/repositories/salon_repository_impl.dart';
import '../../features/salon/domain/repositories/appointment_repository.dart';
import '../../features/salon/domain/repositories/professional_block_repository.dart';
import '../../features/salon/domain/repositories/salon_repository.dart';
import '../../features/salon/presentation/client/bloc/booking_bloc.dart';
import '../../features/salon/presentation/client/bloc/salon_list_bloc.dart';
import '../network/api_client.dart';
import '../network/interceptors/auth_interceptor.dart';
import '../storage/secure_storage.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Storage
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  sl.registerLazySingleton<SecureStorage>(() => SecureStorage(sl()));

  // Auth datasource & repository
  sl.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()),
  );

  // Auth usecases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));

  // Auth BLoC (as singleton to be accessible from interceptor)
  sl.registerLazySingleton<AuthBloc>(() => AuthBloc(
        authRepository: sl(),
        loginUseCase: sl(),
        registerUseCase: sl(),
      ));

  // Network
  sl.registerLazySingleton<AuthInterceptor>(() => AuthInterceptor(
        sl(),
        onSessionExpired: () async {
          sl<AuthBloc>().add(AuthLogoutRequested());
        },
      ));
  sl.registerLazySingleton<ApiClient>(() => ApiClient(authInterceptor: sl()));
  sl.registerLazySingleton<Dio>(() => sl<ApiClient>().dio);

  // Salon datasource & repositories
  sl.registerLazySingleton<SalonRemoteDatasource>(
    () => SalonRemoteDatasourceImpl(sl()),
  );
  sl.registerLazySingleton<SalonRepository>(
    () => SalonRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<AppointmentRepository>(
    () => AppointmentRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<ProfessionalBlockRepository>(
    () => ProfessionalBlockRepositoryImpl(sl()),
  );

  // Salon BLoCs
  sl.registerFactory<SalonListBloc>(() => SalonListBloc(sl()));
  sl.registerFactory<BookingBloc>(() => BookingBloc(
        salonRepository: sl(),
        appointmentRepository: sl(),
      ));
}
