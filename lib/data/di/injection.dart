import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/services/network_manager.dart';
import '../../core/services/secure_storage.dart';
import '../../core/storage/secure_storage.dart' as locale_storage;
import '../../core/init/logger/logger.dart';
import '../repositories/auth_repository.dart';
import '../../domain/usecase/auth/auth_usecase.dart';
import '../../presentation/auth/login/viewmodel/bloc/login_bloc.dart';
import '../../presentation/splash/viewmodel/splash_bloc.dart';

final GetIt getIt = GetIt.instance;

class Injection {
  static Future<void> init() async {
    // Core services
    await _initCoreServices();
    
    // External packages
    await _initExternalPackages();
    
    // Repositories
    await _initRepositories();
    
    // Use cases
    await _initUseCases();
    
    // Blocs
    await _initBlocs();
    
    // ViewModels
    await _initViewModels();
  }

  static Future<void> _initCoreServices() async {
    // Network manager
    getIt.registerLazySingleton<NetworkManager>(
      () => NetworkManager.instance,
    );

    // Secure storage
    getIt.registerLazySingleton<SecureStorage>(
      () => SecureStorage.instance,
    );

    // Secure storage (locale wrapper used by repository)
    getIt.registerLazySingleton<locale_storage.SecureStorageLocale>(
      () => locale_storage.SecureStorageLocale.instance,
    );

    // Logger
    getIt.registerLazySingleton<Logger>(
      () => Logger.instance,
    );
  }

  static Future<void> _initExternalPackages() async {
    // Shared preferences
    final sharedPreferences = await SharedPreferences.getInstance();
    getIt.registerLazySingleton<SharedPreferences>(
      () => sharedPreferences,
    );

    // Flutter secure storage
    getIt.registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage(),
    );
  }

  static Future<void> _initRepositories() async {
    // Auth repository
    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepository(
        networkManager: getIt<NetworkManager>(),
        secureStorage: getIt<locale_storage.SecureStorageLocale>(),
      ),
    );

    // User repository
    // getIt.registerLazySingleton<UserRepository>(
    //   () => UserRepositoryImpl(
    //     networkManager: getIt<NetworkManager>(),
    //     secureStorage: getIt<SecureStorage>(),
    //   ),
    // );

    // Add more repositories as needed
  }

  static Future<void> _initUseCases() async {
    // Auth use cases
    getIt.registerLazySingleton<AuthUseCase>(
      () => AuthUseCase(getIt<AuthRepository>()),
    );

    // User use cases
    // getIt.registerLazySingleton<GetUserProfileUseCase>(
    //   () => GetUserProfileUseCase(
    //     userRepository: getIt<UserRepository>(),
    //   ),
    // );

    // getIt.registerLazySingleton<UpdateUserProfileUseCase>(
    //   () => UpdateUserProfileUseCase(
    //     userRepository: getIt<UserRepository>(),
    //   ),
    // );

    // Add more use cases as needed
  }

  static Future<void> _initBlocs() async {
    // Login bloc
    getIt.registerFactory<LoginBloc>(
      () => LoginBloc(
        authUseCase: getIt<AuthUseCase>(),
      ),
    );

    // User bloc
    // getIt.registerFactory<UserBloc>(
    //   () => UserBloc(
    //     getUserProfileUseCase: getIt<GetUserProfileUseCase>(),
    //     updateUserProfileUseCase: getIt<UpdateUserProfileUseCase>(),
    //   ),
    // );

    // Add more blocs as needed
    getIt.registerFactory<SplashBloc>(
      () => SplashBloc(
        authUseCase: getIt<AuthUseCase>(),
      ),
    );
  }

  static Future<void> _initViewModels() async {
    // Splash view model
    // getIt.registerFactory<SplashViewModel>(
    //   () => SplashViewModel(
    //     authRepository: getIt<AuthRepository>(),
    //   ),
    // );

    // Add more view models as needed
  }

  // Helper methods for dependency injection
  static T get<T extends Object>() => getIt<T>();
  
  static T getWithParam<T extends Object, P extends Object>(P param) => getIt<T>(param1: param);
  
  static bool isRegistered<T extends Object>() => getIt.isRegistered<T>();
  
  static Future<T> getAsync<T extends Object>() => getIt.getAsync<T>();
  
  static void reset() => getIt.reset();
  
  static void unregister<T extends Object>() => getIt.unregister<T>();
}

// Extension for easier access to dependencies
extension GetItExtension on GetIt {
  T get<T extends Object>() => this<T>();
  
  T getWithParam<T extends Object, P extends Object>(P param) => this<T>(param1: param);
  
  bool isRegistered<T extends Object>() => this.isRegistered<T>();
  
  Future<T> getAsync<T extends Object>() => this.getAsync<T>();
  
  void reset() => this.reset();
  
  void unregister<T extends Object>() => this.unregister<T>();
}

// Global access to dependencies
T get<T extends Object>() => getIt.get<T>();

T getWithParam<T extends Object, P extends Object>(P param) => getIt.getWithParam<T, P>(param);

bool isRegistered<T extends Object>() => getIt.isRegistered<T>();

Future<T> getAsync<T extends Object>() => getIt.getAsync<T>();

void resetDependencies() => getIt.reset();

void unregisterDependency<T extends Object>() => getIt.unregister<T>();
