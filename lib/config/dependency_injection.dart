import 'package:get_it/get_it.dart';
import 'package:picky_load/services/local/saved_service.dart';
import '../data/data_source/api_client.dart';
import '../domain/repository/user_repository.dart';
import '../domain/repository/trip_repository.dart';
import '../domain/repository/driver_repository.dart';

/// Dependency injection container
final GetIt getIt = GetIt.instance;

/// Initialize all dependencies
Future<void> setupDependencyInjection() async {
  // Register API Client (singleton)
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());
  getIt.registerLazySingleton<SavedService>(() => SavedService());

  // Register Repositories (singletons)
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepository(getIt<ApiClient>(), getIt<SavedService>()),
  );

  // Register Trip Repository
  getIt.registerLazySingleton<TripRepository>(
    () => TripRepository(getIt<ApiClient>()),
  );

  // Register Driver Repository
  getIt.registerLazySingleton<DriverRepository>(
    () => DriverRepository(getIt<ApiClient>()),
  );
}
