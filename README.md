# 🚀 Flutter Bloc Template

Modern Flutter uygulamaları için Clean Architecture prensiplerine uygun, Bloc pattern kullanan profesyonel template.

## 📋 İçindekiler

- [Özellikler](#özellikler)
- [Hızlı Başlangıç](#hızlı-başlangıç)
- [Proje Yapısı](#proje-yapısı)
- [Kurulum](#kurulum)
- [Kullanım](#kullanım)
- [Örnekler](#örnekler)
- [Best Practices](#best-practices)
- [API Reference](#api-reference)

## ✨ Özellikler

- 🏗️ **Clean Architecture**: Katmanlı mimari
- 📱 **Bloc Pattern**: Bloc/Cubit ile state yönetimi
- 🔄 **Auto Route**: Otomatik routing ve nested navigation
- 💉 **Dependency Injection**: GetIt tabanlı DI
- 🌐 **Network**: Dio + PrettyDioLogger ile HTTP istemci
- 🔐 **Secure Storage**: flutter_secure_storage ile güvenli veri
- 📝 **Logging**: logger + özelleştirilmiş wrapper
- 🌍 **Localization**: easy_localization + key generation
- 🔔 **Notifications**: Firebase Messaging + Local Notifications
- 🖼️ **Device Preview**: Cihaz önizleme desteği
- 🎨 **Theme System**: IColors + ITextTheme ile tema
- 🧪 **Test Ready**: Test edilebilir yapı

## ⚡ Hızlı Başlangıç

```bash
# Bağımlılıkları kur
flutter pub get

# Router ve codegen
dart run build_runner build --delete-conflicting-outputs

# Dil anahtarlarını üret (easy_localization)
bash script/lang.sh

# Web’de (önerilen renderer ile) çalıştır
flutter run -d chrome --web-renderer canvaskit

# iOS/Android’de çalıştır
flutter run
```

İlk ekran: Splash → oturum durumuna göre Login veya BottomBar.

## 🏗️ Proje Yapısı

```
lib/
├── core/                           # Core functionality
│   ├── init/                      # Initialization
│   │   ├── constants/             # App constants
│   │   ├── logger/                # Logging system
│   │   └── theme/                 # Theme configuration
│   ├── router/                    # Routing
│   └── services/                  # Core services
├── data/                          # Data layer
│   ├── di/                        # Dependency injection
│   └── repositories/              # Data repositories
├── domain/                        # Business logic
│   ├── model/                     # Data models
│   └── usecase/                   # Use cases
└── presentation/                   # UI layer
    ├── common/                     # Common widgets
    │   └── base/                  # Base classes
    └── [feature]/                  # Feature modules
```

## 🚀 Kurulum

### 1. Bağımlılıkları Yükleyin
```bash
flutter pub get
```

### 2. Router'ı Oluşturun
```bash
dart run build_runner build --delete-conflicting-outputs
# veya
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### 3. Localization Key'lerini Üretin
```bash
bash script/lang.sh
```

### 4. Uygulamayı Çalıştırın
```bash
flutter run
```

Notlar:
- Web’de HTML renderer artık önerilmiyor. CanvasKit daha stabil (özellikle input/pointer olaylarında).
- Debug modda Device Preview açık gelir ve farklı cihaz boyutlarını hızla denemenizi sağlar.

## 📖 Kullanım

### 0. Dependency Injection

Tüm servis ve katman kayıtları `get_it` ile `Injection.init()` içinde yapılır.

```dart
// lib/main.dart (özet)
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Injection.init(); // DI kayıtlarını yükler
  runApp(const MyApp());
}

// lib/data/di/injection.dart (özet)
getIt.registerLazySingleton<NetworkManager>(() => NetworkManager.instance); // HTTP istemci
getIt.registerLazySingleton<SecureStorage>(() => SecureStorage.instance); // Güvenli depolama
getIt.registerLazySingleton<SecureStorageLocale>(() => SecureStorageLocale.instance); // Key-value helper

getIt.registerLazySingleton<AuthRepository>(() => AuthRepository(
  networkManager: getIt<NetworkManager>(), // ağ çağrıları burada yapılır
  secureStorage: getIt<SecureStorageLocale>(), // token saklama
));

getIt.registerLazySingleton<AuthUseCase>(() => AuthUseCase(getIt<AuthRepository>())); // iş kuralları

getIt.registerFactory<LoginBloc>(() => LoginBloc(authUseCase: getIt<AuthUseCase>()));
getIt.registerFactory<SplashBloc>(() => SplashBloc(authUseCase: getIt<AuthUseCase>()));
```

### 1. Model Oluşturma

```dart
// lib/domain/model/user/user_model.dart
class UserModel extends BaseModel<UserModel> {
  final String id;
  final String name;
  final String email;
  final String? avatar;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
    };
  }

  @override
  UserModel fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatar: json['avatar'] as String?,
    );
  }

  @override
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatar,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
    );
  }
}
```

### 2. Repository Oluşturma

```dart
// lib/data/repositories/user_repository_impl.dart
class UserRepositoryImpl {
  final NetworkManager _networkManager;
  final SecureStorage _secureStorage;

  UserRepositoryImpl({
    required NetworkManager networkManager,
    required SecureStorage secureStorage,
  })  : _networkManager = networkManager,
        _secureStorage = secureStorage;

  Future<Either<NetworkError, UserModel>> create(UserModel data) async {
    try {
      final response = await _networkManager.post<Map<String, dynamic>>(
        '/users',
        data: data.toJson(),
      );
      if (response.statusCode == 201) {
        return Left(UserModel.fromJson(response.data!));
      }
      return Right(NetworkError.serverError('User creation failed'));
    } catch (e) {
      return Right(NetworkError.unknown(e.toString()));
    }
  }

  Future<Either<NetworkError, UserModel>> read(String id) async {
    try {
      final response = await _networkManager.get<Map<String, dynamic>>('/users/$id');
      if (response.statusCode == 200) {
        return Left(UserModel.fromJson(response.data!));
      }
      return Right(NetworkError.notFound('User not found'));
    } catch (e) {
      return Right(NetworkError.unknown(e.toString()));
    }
  }
}
```

### 3. Use Case Oluşturma

```dart
// lib/domain/usecase/user/get_user_usecase.dart
class GetUserUseCase extends BaseUseCase<UserModel, String> {
  final UserRepository _userRepository;

  const GetUserUseCase(this._userRepository);

  @override
  Future<Either<NetworkError, UserModel>> call(String userId) async {
    // Hata yönetimi için Either kullanılır
    return await _userRepository.read(userId);
  }
}

// lib/domain/usecase/user/create_user_usecase.dart
class CreateUserUseCase extends BaseUseCase<UserModel, UserModel> {
  final UserRepository _userRepository;

  const CreateUserUseCase(this._userRepository);

  @override
  Future<Either<NetworkError, UserModel>> call(UserModel user) async {
    return await _userRepository.create(user);
  }
}
```

### 4. Bloc Oluşturma

```dart
// lib/presentation/user/bloc/user_bloc.dart
class UserBloc extends BaseBloc<UserEvent, UserState> {
  final GetUserUseCase _getUserUseCase;
  final CreateUserUseCase _createUserUseCase;

  UserBloc({
    required GetUserUseCase getUserUseCase,
    required CreateUserUseCase createUserUseCase,
  })  : _getUserUseCase = getUserUseCase,
        _createUserUseCase = createUserUseCase,
        super(const UserState());

  @override
  Stream<UserState> mapEventToState(UserEvent event) async* {
    if (event is LoadUser) {
      yield* _mapLoadUserToState(event);
    } else if (event is CreateUser) {
      yield* _mapCreateUserToState(event);
    }
  }

  Stream<UserState> _mapLoadUserToState(LoadUser event) async* {
    await handleAsyncOperation<UserModel>(
      operation: () => _getUserUseCase(event.userId).then((e) => e.fold((l) => Future.value(l), (r) => Future.error(r))),
      onSuccess: (_) {},
      successMessage: 'Kullanıcı başarıyla yüklendi',
    );
  }

  Stream<UserState> _mapCreateUserToState(CreateUser event) async* {
    await handleAsyncOperation<UserModel>(
      operation: () => _createUserUseCase(event.user).then((e) => e.fold((l) => Future.value(l), (r) => Future.error(r))),
      onSuccess: (_) {},
      successMessage: 'Kullanıcı başarıyla oluşturuldu',
    );
  }
}

// lib/presentation/user/bloc/user_event.dart
abstract class UserEvent extends BaseEvent {
  const UserEvent();
}

class LoadUser extends UserEvent {
  final String userId;
  
  const LoadUser(this.userId);
  
  @override
  List<Object?> get props => [userId];
}

class CreateUser extends UserEvent {
  final UserModel user;
  
  const CreateUser(this.user);
  
  @override
  List<Object?> get props => [user];
}

// lib/presentation/user/bloc/user_state.dart
class UserState extends BaseState {
  final UserModel? user;
  final List<UserModel> users;

  const UserState({
    super.status = Status.initial,
    super.message,
    super.errorMessage,
    this.user,
    this.users = const [],
  });

  @override
  UserState copyWith({
    Status? status,
    String? message,
    String? errorMessage,
    UserModel? user,
    List<UserModel>? users,
  }) {
    return UserState(
      status: status ?? this.status,
      message: message ?? this.message,
      errorMessage: errorMessage ?? this.errorMessage,
      user: user ?? this.user,
      users: users ?? this.users,
    );
  }

  @override
  List<Object?> get props => [status, message, errorMessage, user, users];
}
```

### 5. View Oluşturma

```dart
// lib/presentation/user/view/user_view.dart
class UserView extends BaseView<UserBloc> {
  const UserView({super.key});

  @override
  UserBloc createBloc() => getIt<UserBloc>();

  @override
  Widget buildView(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kullanıcılar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateUserDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state.isError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.errorMessage ?? 'Bir hata oluştu'),
                  ElevatedButton(
                    onPressed: () => context.read<UserBloc>().add(LoadUsers()),
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }
          
          if (state.users.isEmpty) {
            return const Center(
              child: Text('Henüz kullanıcı bulunmuyor'),
            );
          }
          
          return ListView.builder(
            itemCount: state.users.length,
            itemBuilder: (context, index) {
              final user = state.users[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: user.avatar != null 
                    ? NetworkImage(user.avatar!) 
                    : null,
                  child: user.avatar == null 
                    ? Text(user.name[0].toUpperCase())
                    : null,
                ),
                title: Text(user.name),
                subtitle: Text(user.email),
                onTap: () => _navigateToUserDetail(context, user),
              );
            },
          );
        },
      ),
    );
  }

  void _showCreateUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreateUserDialog(),
    );
  }

  void _navigateToUserDetail(BuildContext context, UserModel user) {
    context.router.push(UserDetailRoute(user: user));
  }
}
```

### 6. Dependency Injection

```dart
// lib/data/di/injection.dart
class Injection {
  static Future<void> init() async {
    // Core services
    await _initCoreServices();
    
    // Repositories
    await _initRepositories();
    
    // Use cases
    await _initUseCases();
    
    // Blocs
    await _initBlocs();
  }

  static Future<void> _initCoreServices() async {
    getIt.registerLazySingleton<NetworkManager>(
      () => NetworkManager.instance,
    );
    
    getIt.registerLazySingleton<SecureStorage>(
      () => SecureStorage.instance,
    );
    
    getIt.registerLazySingleton<Logger>(
      () => Logger.instance,
    );
  }

  static Future<void> _initRepositories() async {
    getIt.registerLazySingleton<UserRepository>(
      () => UserRepositoryImpl(
        networkManager: getIt<NetworkManager>(),
        secureStorage: getIt<SecureStorage>(),
      ),
    );
  }

  static Future<void> _initUseCases() async {
    getIt.registerLazySingleton<GetUserUseCase>(
      () => GetUserUseCase(getIt<UserRepository>()),
    );
    
    getIt.registerLazySingleton<CreateUserUseCase>(
      () => CreateUserUseCase(getIt<UserRepository>()),
    );
  }

  static Future<void> _initBlocs() async {
    getIt.registerFactory<UserBloc>(
      () => UserBloc(
        getUserUseCase: getIt<GetUserUseCase>(),
        createUserUseCase: getIt<CreateUserUseCase>(),
      ),
    );
  }
}
```

### 7. Router Konfigürasyonu

```dart
// lib/core/router/app_router.dart
@AutoRouterConfig(replaceInRouteName: 'View,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: SplashRoute.page, initial: true),
        AutoRoute(page: LoginRoute.page),
        AutoRoute(
          page: BottomBarRoute.page,
          children: [
            AutoRoute(page: HomeRoute.page),
            AutoRoute(page: UserRoute.page),
            AutoRoute(page: ProfileRoute.page),
          ],
        ),
        AutoRoute(page: UserDetailRoute.page),
      ];
}
```

## 🎯 Best Practices

### 1. **State Management**
- Her feature için ayrı bloc kullanın
- State'leri immutable yapın
- copyWith metodunu kullanın

### 2. **Error Handling**
- NetworkError sınıfını kullanın
- User-friendly hata mesajları gösterin
- Retry mekanizması ekleyin

### 3. **Performance**
- Lazy loading kullanın
- Pagination implement edin
- Image caching ekleyin

### 4. **Testing**
- Unit testler yazın
- Widget testler ekleyin
- Integration testler yapın

### 5. **Code Organization**
- Feature-based klasör yapısı kullanın
- Common widget'ları shared klasörüne koyun
- Constants'ları ayrı dosyalarda tutun

## 🔧 API Reference

### Base Classes

#### BaseModel
```dart
abstract class BaseModel<T> {
  Map<String, dynamic> toJson();
  T fromJson(Map<String, dynamic> json);
  T copyWith();
}
```

#### BaseState
```dart
abstract class BaseState {
  final Status status;
  final String? message;
  final String? errorMessage;
  
  bool get isLoading;
  bool get isSuccess;
  bool get isError;
}
```

#### BaseBloc
```dart
abstract class BaseBloc<Event extends BaseEvent, State extends BaseState> {
  void emitLoading([String? message]);
  void emitSuccess([String? message]);
  void emitError(String errorMessage, [String? message]);
  void emitInitial();
}
```

### Network Layer

#### NetworkManager
```dart
class NetworkManager {
  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters});
  Future<Response<T>> post<T>(String path, {dynamic data});
  Future<Response<T>> put<T>(String path, {dynamic data});
  Future<Response<T>> delete<T>(String path);
  void setAuthToken(String token);
  Future<bool> hasInternetConnection();
}
```

Not: NetworkManager, PrettyDioLogger ile istek/yanıtları loglar. Auth token eklemek için `setAuthToken` kullanılabilir (Authorization: Bearer ...).

#### NetworkError
```dart
abstract class NetworkError implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;
  
  factory NetworkError.unknown(String message);
  factory NetworkError.badRequest(String message);
  factory NetworkError.unauthorized(String message);
  factory NetworkError.serverError(String message);
}
```

Not: Tüm repository/use case akışlarında `Either<NetworkError, T>` kullanılır.

### Logging

```dart
import 'core/init/logger/logger.dart';

logger.info('App started'); // bilgi mesajı
logger.debug('Payload', {'id': 1}); // debug içeriği
logger.error('Oops', Exception('fail')); // hata

// API özel logları
logger.logApiRequest(method: 'POST', url: '/auth/login', body: {...});
logger.logApiResponse(statusCode: 200, url: '/auth/login', body: {...});
logger.logApiError(method: 'POST', url: '/auth/login', error: 'Timeout');
```

### Notifications

Firebase Messaging + Local Notifications kullanılır. Kurulum için:

1) Firebase projesi oluşturun ve `google-services.json`/`GoogleService-Info.plist` ekleyin
2) Android ve iOS konfigürasyonlarını FlutterFire yönergelerine göre tamamlayın
3) Gerekirse bildirim simgesi ve kanal ayarlarınızı güncelleyin

Servisi başlatmak için uygun yerde:

```dart
await NotificationService.instance.initialize();
```

### Localization

Dil dosyaları `assets/lang` altında tutulur. Key üretimi için:

```bash
bash script/lang.sh
```

`EasyLocalization` `main.dart` içinde yapılandırılmıştır.

## 🎨 Özelleştirme

- Tema renkleri: `lib/core/init/theme/colors/color_theme.dart` (AppColors)
- Renk şeması: `lib/core/init/theme/colors/light_color.dart` (ColorScheme)
- Yazı tipleri: `lib/core/init/theme/text/text_theme_light.dart`
- Başlangıç rotası: `lib/core/router/app_router.dart`
- Base URL: `lib/core/init/constants/app_constants.dart`

Koyu tema eklemek için `DarkColors` ve `AppThemeDark` benzeri bir yapı tanımlayıp `ThemeManager.createTheme` ile seçebilirsiniz.

## 🧱 Base Template Garantisi

Bu depo “markasız” bir başlangıç şablonudur. Görseller, renkler ve yazılar nötrdür; yeni projelerde yalnızca logo, renk paleti ve metinleri değiştirerek hızla adapte edebilirsiniz.

### Storage

#### SecureStorage
```dart
class SecureStorage {
  Future<void> writeString({required String key, required String value});
  Future<String?> readString({required String key});
  Future<void> writeBool({required String key, required bool value});
  Future<bool?> readBool({required String key});
  Future<void> delete({required String key});
  Future<void> deleteAll();
}
```

## 📱 Örnek Uygulama

Bu template ile oluşturulmuş örnek bir uygulama:

- **Authentication**: Login, Register, Logout
- **User Management**: CRUD operations
- **Navigation**: Bottom navigation, Nested routes
- **State Management**: Loading, Success, Error states
- **Network**: API calls, Error handling
- **Storage**: Secure storage, Shared preferences

## 🧪 Testing

```bash
# Unit tests
flutter test

# Widget tests
flutter test test/widget_test.dart

# Integration tests
flutter test integration_test/
```

## 📦 Build & Deploy

```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release

# iOS build
flutter build ios --release
```

## 🛠️ Scriptler

- `script/lang.sh`: easy_localization için key üretimi
- `script/deep_clean.sh`: iOS/Flutter derin temizlik ve pod işlemleri

## 🤝 Katkıda Bulunma

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Commit yapın (`git commit -m 'Add amazing feature'`)
4. Push yapın (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakın.

## 📞 İletişim

- **Proje Linki**: [https://github.com/FehmiDeniz/flutter_bloc_base_fdb](https://github.com/FehmiDeniz/flutter_bloc_base_fdb)
- **Issues**: [https://github.com/username/flutter_bloc_template/issues](https://github.com/username/flutter_bloc_template/issues)

---

⭐ Bu projeyi beğendiyseniz yıldız vermeyi unutmayın!
