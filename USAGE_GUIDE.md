# 📚 Flutter Bloc Template - Detaylı Kullanım Kılavuzu

Bu doküman, Flutter Bloc Template'in nasıl kullanılacağını adım adım açıklar.

## 🎯 İçindekiler

1. [Hızlı Başlangıç](#hızlı-başlangıç)
2. [Proje Kurulumu](#proje-kurulumu)
3. [Temel Yapılar](#temel-yapılar)
4. [Yeni Feature Geliştirme](#yeni-feature-geliştirme)
5. [Örnek Uygulamalar](#örnek-uygulamalar)
6. [Özelleştirme](#özelleştirme)
7. [Web İpuçları](#web-ipuçları)
8. [Troubleshooting](#troubleshooting)

## 🚀 Hızlı Başlangıç

Amaç: Yeni bir özelliği (feature) minimum adımla iskelet halinde çıkarmak ve katmanlara (presentation/data/domain) doğru dağıtmak.

### 1. Yeni Feature Oluşturma

```bash
# Feature klasörü oluştur
mkdir -p lib/presentation/user

# Alt klasörler
mkdir -p lib/presentation/user/{bloc,view,widget}
mkdir -p lib/domain/model/user
mkdir -p lib/domain/usecase/user
mkdir -p lib/data/repositories
```

### 2. Temel Dosya Yapısı

```
user/
├── bloc/
│   ├── user_bloc.dart
│   ├── user_event.dart
│   └── user_state.dart
├── view/
│   ├── user_view.dart
│   └── user_detail_view.dart
├── widget/
│   ├── user_list_item.dart
│   └── user_form.dart
```

## 🏗️ Proje Kurulumu

Bu bölüm projeyi ilk defa ayağa kaldırmak için gereklidir. Aşamalar sırasıyla bağımlılıkların indirilmesi, router için kod üretimi ve temel ayarların yapılmasını kapsar.

### 1. Bağımlılıkları Yükleyin

```bash
flutter pub get
```

### 2. Uygulama Ayarları

`.env` yerine `lib/core/init/constants/app_constants.dart` üzerinden ayarları yapılandırın:

```dart
class AppConstants {
  static const String baseUrl = 'https://api.example.com';
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
  // ...
}
```

### 3. Build Runner Kurulumu

```bash
# Code generation (router, vs.)
dart run build_runner build --delete-conflicting-outputs
```

## 📋 Temel Yapılar

Bu şablonda temel kavramlar:
- BaseModel<T>: JSON dönüşümü ve kopyalama (`copyWith`) sözleşmesini tanımlar.
- UseCase: İş kurallarını ayrı bir katmanda toplar (UI ve data’dan bağımsız).
- Repository: API/Local depolama erişimini soyutlar; `Either<NetworkError, T>` ile sonuç dönerek tutarlı hata yönetimi sağlar.
- Bloc/Cubit: UI state yönetimi; `emitLoading/emitSuccess/emitError` yardımcıları ile okunabilir akış.

### 1. Model Oluşturma

```dart
// lib/domain/model/user/user_model.dart
import '../base_model.dart';

class UserModel extends BaseModel<UserModel> {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final DateTime createdAt;
  final bool isActive;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    required this.createdAt,
    this.isActive = true,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive,
    };
  }

  @override
  UserModel fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatar: json['avatar'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  @override
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatar,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  // Helper methods
  bool get hasAvatar => avatar != null && avatar!.isNotEmpty;
  String get displayName => name.isNotEmpty ? name : email;
  bool get isRecentlyCreated => 
      DateTime.now().difference(createdAt).inDays < 7;
}
```

### 2. Repository Interface

```dart
// lib/domain/repositories/user_repository.dart
import '../model/user/user_model.dart';
import '../../core/services/network_error.dart';
import 'package:dartz/dartz.dart';

abstract class UserRepository {
  Future<Either<NetworkError, UserModel>> getUser(String id);
  Future<Either<NetworkError, List<UserModel>>> getUsers();
  Future<Either<NetworkError, UserModel>> createUser(UserModel user);
  Future<Either<NetworkError, UserModel>> updateUser(UserModel user);
  Future<Either<NetworkError, bool>> deleteUser(String id);
  Future<Either<NetworkError, List<UserModel>>> searchUsers(String query);
}
```

### 3. Repository Implementation

```dart
// lib/data/repositories/user_repository_impl.dart
import '../../domain/repositories/user_repository.dart';
import '../../domain/model/user/user_model.dart';
import '../../core/services/network_manager.dart';
import '../../core/services/network_error.dart';
import '../../core/services/secure_storage.dart';
import 'package:dartz/dartz.dart';

class UserRepositoryImpl implements UserRepository {
  final NetworkManager _networkManager;
  final SecureStorage _secureStorage;

  UserRepositoryImpl({
    required NetworkManager networkManager,
    required SecureStorage secureStorage,
  })  : _networkManager = networkManager,
        _secureStorage = secureStorage;

  @override
  Future<Either<NetworkError, UserModel>> getUser(String id) async {
    try {
      final response = await _networkManager.get<Map<String, dynamic>>('/users/$id');
      
      if (response.statusCode == 200) {
        final user = UserModel.fromJson(response.data!);
        return Left(user);
      }
      
      if (response.statusCode == 404) {
        return Right(NetworkError.notFound('User not found'));
      }
      
      return Right(NetworkError.serverError('Failed to get user'));
    } catch (e) {
      return Right(NetworkError.unknown(e.toString()));
    }
  }

  @override
  Future<Either<NetworkError, List<UserModel>>> getUsers() async {
    try {
      final response = await _networkManager.get<List<dynamic>>('/users');
      
      if (response.statusCode == 200) {
        final users = (response.data! as List)
            .map((json) => UserModel.fromJson(json))
            .toList();
        return Left(users);
      }
      
      return Right(NetworkError.serverError('Failed to get users'));
    } catch (e) {
      return Right(NetworkError.unknown(e.toString()));
    }
  }

  @override
  Future<Either<NetworkError, UserModel>> createUser(UserModel user) async {
    try {
      final response = await _networkManager.post<Map<String, dynamic>>(
        '/users',
        data: user.toJson(),
      );
      
      if (response.statusCode == 201) {
        final createdUser = UserModel.fromJson(response.data!);
        return Left(createdUser);
      }
      
      return Right(NetworkError.serverError('Failed to create user'));
    } catch (e) {
      return Right(NetworkError.unknown(e.toString()));
    }
  }

  @override
  Future<Either<NetworkError, UserModel>> updateUser(UserModel user) async {
    try {
      final response = await _networkManager.put<Map<String, dynamic>>(
        '/users/${user.id}',
        data: user.toJson(),
      );
      
      if (response.statusCode == 200) {
        final updatedUser = UserModel.fromJson(response.data!);
        return Left(updatedUser);
      }
      
      return Right(NetworkError.serverError('Failed to update user'));
    } catch (e) {
      return Right(NetworkError.unknown(e.toString()));
    }
  }

  @override
  Future<Either<NetworkError, bool>> deleteUser(String id) async {
    try {
      final response = await _networkManager.delete('/users/$id');
      
      if (response.statusCode == 200) {
        return const Left(true);
      }
      
      return Right(NetworkError.serverError('Failed to delete user'));
    } catch (e) {
      return Right(NetworkError.unknown(e.toString()));
    }
  }

  @override
  Future<Either<NetworkError, List<UserModel>>> searchUsers(String query) async {
    try {
      final response = await _networkManager.get<List<dynamic>>(
        '/users/search',
        queryParameters: {'q': query},
      );
      
      if (response.statusCode == 200) {
        final users = (response.data! as List)
            .map((json) => UserModel.fromJson(json))
            .toList();
        return Left(users);
      }
      
      return Right(NetworkError.serverError('Failed to search users'));
    } catch (e) {
      return Right(NetworkError.unknown(e.toString()));
    }
  }
}
```

### 4. Use Cases

```dart
// lib/domain/usecase/user/get_user_usecase.dart
import '../base_usecase.dart';
import '../../model/user/user_model.dart';
import '../../repositories/user_repository.dart';
import '../../../core/services/network_error.dart';
import 'package:dartz/dartz.dart';

class GetUserUseCase extends BaseUseCase<UserModel, String> {
  final UserRepository _userRepository;

  const GetUserUseCase(this._userRepository);

  @override
  Future<Either<NetworkError, UserModel>> call(String userId) async {
    return await _userRepository.getUser(userId);
  }
}

// lib/domain/usecase/user/get_users_usecase.dart
class GetUsersUseCase extends BaseUseCaseNoParams<List<UserModel>> {
  final UserRepository _userRepository;

  const GetUsersUseCase(this._userRepository);

  @override
  Future<Either<NetworkError, List<UserModel>>> call() async {
    return await _userRepository.getUsers();
  }
}

// lib/domain/usecase/user/create_user_usecase.dart
class CreateUserUseCase extends BaseUseCase<UserModel, UserModel> {
  final UserRepository _userRepository;

  const CreateUserUseCase(this._userRepository);

  @override
  Future<Either<NetworkError, UserModel>> call(UserModel user) async {
    return await _userRepository.createUser(user);
  }
}

// lib/domain/usecase/user/update_user_usecase.dart
class UpdateUserUseCase extends BaseUseCase<UserModel, UserModel> {
  final UserRepository _userRepository;

  const UpdateUserUseCase(this._userRepository);

  @override
  Future<Either<NetworkError, UserModel>> call(UserModel user) async {
    return await _userRepository.updateUser(user);
  }
}

// lib/domain/usecase/user/delete_user_usecase.dart
class DeleteUserUseCase extends BaseUseCase<bool, String> {
  final UserRepository _userRepository;

  const DeleteUserUseCase(this._userRepository);

  @override
  Future<Either<NetworkError, bool>> call(String userId) async {
    return await _userRepository.deleteUser(userId);
  }
}

// lib/domain/usecase/user/search_users_usecase.dart
class SearchUsersUseCase extends BaseUseCase<List<UserModel>, String> {
  final UserRepository _userRepository;

  const SearchUsersUseCase(this._userRepository);

  @override
  Future<Either<NetworkError, List<UserModel>>> call(String query) async {
    return await _userRepository.searchUsers(query);
  }
}
```

### 5. Bloc Implementation

```dart
// lib/presentation/user/bloc/user_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/base/base_bloc.dart';
import '../../../domain/usecase/user/get_user_usecase.dart';
import '../../../domain/usecase/user/get_users_usecase.dart';
import '../../../domain/usecase/user/create_user_usecase.dart';
import '../../../domain/usecase/user/update_user_usecase.dart';
import '../../../domain/usecase/user/delete_user_usecase.dart';
import '../../../domain/usecase/user/search_users_usecase.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends BaseBloc<UserEvent, UserState> {
  final GetUserUseCase _getUserUseCase;
  final GetUsersUseCase _getUsersUseCase;
  final CreateUserUseCase _createUserUseCase;
  final UpdateUserUseCase _updateUserUseCase;
  final DeleteUserUseCase _deleteUserUseCase;
  final SearchUsersUseCase _searchUsersUseCase;

  UserBloc({
    required GetUserUseCase getUserUseCase,
    required GetUsersUseCase getUsersUseCase,
    required CreateUserUseCase createUserUseCase,
    required UpdateUserUseCase updateUserUseCase,
    required DeleteUserUseCase deleteUserUseCase,
    required SearchUsersUseCase searchUsersUseCase,
  })  : _getUserUseCase = getUserUseCase,
        _getUsersUseCase = getUsersUseCase,
        _createUserUseCase = createUserUseCase,
        _updateUserUseCase = updateUserUseCase,
        _deleteUserUseCase = deleteUserUseCase,
        _searchUsersUseCase = searchUsersUseCase,
        super(const UserState());

  @override
  Stream<UserState> mapEventToState(UserEvent event) async* {
    if (event is LoadUsers) {
      yield* _mapLoadUsersToState();
    } else if (event is LoadUser) {
      yield* _mapLoadUserToState(event);
    } else if (event is CreateUser) {
      yield* _mapCreateUserToState(event);
    } else if (event is UpdateUser) {
      yield* _mapUpdateUserToState(event);
    } else if (event is DeleteUser) {
      yield* _mapDeleteUserToState(event);
    } else if (event is SearchUsers) {
      yield* _mapSearchUsersToState(event);
    } else if (event is RefreshUsers) {
      yield* _mapRefreshUsersToState();
    }
  }

  Stream<UserState> _mapLoadUsersToState() async* {
    emitLoading('Kullanıcılar yükleniyor...');
    
    final result = await _getUsersUseCase();
    
    result.fold(
      (users) => emitSuccess('Kullanıcılar başarıyla yüklendi'),
      (error) => emitError(error.message),
    );
  }

  Stream<UserState> _mapLoadUserToState(LoadUser event) async* {
    emitLoading('Kullanıcı yükleniyor...');
    
    final result = await _getUserUseCase(event.userId);
    
    result.fold(
      (user) => emitSuccess('Kullanıcı başarıyla yüklendi'),
      (error) => emitError(error.message),
    );
  }

  Stream<UserState> _mapCreateUserToState(CreateUser event) async* {
    emitLoading('Kullanıcı oluşturuluyor...');
    
    final result = await _createUserUseCase(event.user);
    
    result.fold(
      (user) => emitSuccess('Kullanıcı başarıyla oluşturuldu'),
      (error) => emitError(error.message),
    );
  }

  Stream<UserState> _mapUpdateUserToState(UpdateUser event) async* {
    emitLoading('Kullanıcı güncelleniyor...');
    
    final result = await _updateUserUseCase(event.user);
    
    result.fold(
      (user) => emitSuccess('Kullanıcı başarıyla güncellendi'),
      (error) => emitError(error.message),
    );
  }

  Stream<UserState> _mapDeleteUserToState(DeleteUser event) async* {
    emitLoading('Kullanıcı siliniyor...');
    
    final result = await _deleteUserUseCase(event.userId);
    
    result.fold(
      (success) => emitSuccess('Kullanıcı başarıyla silindi'),
      (error) => emitError(error.message),
    );
  }

  Stream<UserState> _mapSearchUsersToState(SearchUsers event) async* {
    if (event.query.isEmpty) {
      add(LoadUsers());
      return;
    }
    
    emitLoading('Kullanıcılar aranıyor...');
    
    final result = await _searchUsersUseCase(event.query);
    
    result.fold(
      (users) => emitSuccess('${users.length} kullanıcı bulundu'),
      (error) => emitError(error.message),
    );
  }

  Stream<UserState> _mapRefreshUsersToState() async* {
    add(LoadUsers());
  }
}
```

### 6. Events

```dart
// lib/presentation/user/bloc/user_event.dart
import '../../../common/base/base_bloc.dart';

abstract class UserEvent extends BaseEvent {
  const UserEvent();
}

class LoadUsers extends UserEvent {
  const LoadUsers();
  
  @override
  List<Object?> get props => [];
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

class UpdateUser extends UserEvent {
  final UserModel user;
  
  const UpdateUser(this.user);
  
  @override
  List<Object?> get props => [user];
}

class DeleteUser extends UserEvent {
  final String userId;
  
  const DeleteUser(this.userId);
  
  @override
  List<Object?> get props => [userId];
}

class SearchUsers extends UserEvent {
  final String query;
  
  const SearchUsers(this.query);
  
  @override
  List<Object?> get props => [query];
}

class RefreshUsers extends UserEvent {
  const RefreshUsers();
  
  @override
  List<Object?> get props => [];
}
```

### 7. State

```dart
// lib/presentation/user/bloc/user_state.dart
import '../../../common/base/base_bloc.dart';
import '../../../domain/model/user/user_model.dart';

class UserState extends BaseState {
  final UserModel? selectedUser;
  final List<UserModel> users;
  final List<UserModel> filteredUsers;
  final String? searchQuery;

  const UserState({
    super.status = Status.initial,
    super.message,
    super.errorMessage,
    this.selectedUser,
    this.users = const [],
    this.filteredUsers = const [],
    this.searchQuery,
  });

  @override
  UserState copyWith({
    Status? status,
    String? message,
    String? errorMessage,
    UserModel? selectedUser,
    List<UserModel>? users,
    List<UserModel>? filteredUsers,
    String? searchQuery,
  }) {
    return UserState(
      status: status ?? this.status,
      message: message ?? this.message,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedUser: selectedUser ?? this.selectedUser,
      users: users ?? this.users,
      filteredUsers: filteredUsers ?? this.filteredUsers,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  // Computed properties
  List<UserModel> get displayUsers => 
      searchQuery?.isNotEmpty == true ? filteredUsers : users;
  
  bool get hasUsers => users.isNotEmpty;
  bool get hasFilteredUsers => filteredUsers.isNotEmpty;
  bool get isSearching => searchQuery?.isNotEmpty == true;

  @override
  List<Object?> get props => [
    status, 
    message, 
    errorMessage, 
    selectedUser, 
    users, 
    filteredUsers, 
    searchQuery
  ];
}
```

### 8. View Implementation

```dart
// lib/presentation/user/view/user_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/base/base_view.dart';
import '../../../data/di/injection.dart';
import '../bloc/user_bloc.dart';
import '../bloc/user_event.dart';
import '../bloc/user_state.dart';
import '../widget/user_list_item.dart';
import '../widget/user_form.dart';

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
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateUserDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<UserBloc>().add(RefreshUsers()),
          ),
        ],
      ),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Kullanıcılar yükleniyor...'),
                ],
              ),
            );
          }
          
          if (state.isError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.errorMessage ?? 'Bir hata oluştu',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => context.read<UserBloc>().add(RefreshUsers()),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }
          
          if (!state.hasUsers) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz kullanıcı bulunmuyor',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showCreateUserDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('İlk Kullanıcıyı Ekle'),
                  ),
                ],
              ),
            );
          }
          
          return Column(
            children: [
              if (state.isSearching) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Arama: "${state.searchQuery}"',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => context.read<UserBloc>().add(RefreshUsers()),
                        child: const Text('Temizle'),
                      ),
                    ],
                  ),
                ),
              ],
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<UserBloc>().add(RefreshUsers());
                  },
                  child: ListView.builder(
                    itemCount: state.displayUsers.length,
                    itemBuilder: (context, index) {
                      final user = state.displayUsers[index];
                      return UserListItem(
                        user: user,
                        onTap: () => _navigateToUserDetail(context, user),
                        onEdit: () => _showEditUserDialog(context, user),
                        onDelete: () => _showDeleteConfirmation(context, user),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const SearchUserDialog(),
    );
  }

  void _showCreateUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const UserFormDialog(),
    );
  }

  void _showEditUserDialog(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (context) => UserFormDialog(user: user),
    );
  }

  void _showDeleteConfirmation(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kullanıcıyı Sil'),
        content: Text('${user.name} kullanıcısını silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<UserBloc>().add(DeleteUser(user.id));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  void _navigateToUserDetail(BuildContext context, UserModel user) {
    context.router.push(UserDetailRoute(user: user));
  }
}
```

## 🔧 Dependency Injection

### Injection Setup

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
    
    getIt.registerLazySingleton<GetUsersUseCase>(
      () => GetUsersUseCase(getIt<UserRepository>()),
    );
    
    getIt.registerLazySingleton<CreateUserUseCase>(
      () => CreateUserUseCase(getIt<UserRepository>()),
    );
    
    getIt.registerLazySingleton<UpdateUserUseCase>(
      () => UpdateUserUseCase(getIt<UserRepository>()),
    );
    
    getIt.registerLazySingleton<DeleteUserUseCase>(
      () => DeleteUserUseCase(getIt<UserRepository>()),
    );
    
    getIt.registerLazySingleton<SearchUsersUseCase>(
      () => SearchUsersUseCase(getIt<UserRepository>()),
    );
  }

  static Future<void> _initBlocs() async {
    getIt.registerFactory<UserBloc>(
      () => UserBloc(
        getUserUseCase: getIt<GetUserUseCase>(),
        getUsersUseCase: getIt<GetUsersUseCase>(),
        createUserUseCase: getIt<CreateUserUseCase>(),
        updateUserUseCase: getIt<UpdateUserUseCase>(),
        deleteUserUseCase: getIt<DeleteUserUseCase>(),
        searchUsersUseCase: getIt<SearchUsersUseCase>(),
      ),
    );
  }
}
```

## 🎨 Widget Implementation

### User List Item

```dart
// lib/presentation/user/widget/user_list_item.dart
import 'package:flutter/material.dart';
import '../../../domain/model/user/user_model.dart';

class UserListItem extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const UserListItem({
    super.key,
    required this.user,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundImage: user.hasAvatar 
            ? NetworkImage(user.avatar!) 
            : null,
          child: user.hasAvatar 
            ? null 
            : Text(
                user.displayName[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
        ),
        title: Text(
          user.displayName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            if (user.isRecentlyCreated)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Yeni',
                  style: TextStyle(
                    color: Colors.green[800],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onEdit != null)
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: onEdit,
                tooltip: 'Düzenle',
              ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
                tooltip: 'Sil',
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
```

### User Form Dialog

```dart
// lib/presentation/user/widget/user_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/model/user/user_model.dart';
import '../bloc/user_bloc.dart';
import '../bloc/user_event.dart';
import '../bloc/user_state.dart';

class UserFormDialog extends StatefulWidget {
  final UserModel? user;

  const UserFormDialog({super.key, this.user});

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _avatarController = TextEditingController();

  bool get isEditing => widget.user != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameController.text = widget.user!.name;
      _emailController.text = widget.user!.email;
      _avatarController.text = widget.user!.avatar ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state.isSuccess) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message ?? 'İşlem başarılı'),
              backgroundColor: Colors.green,
            ),
          );
        }
        
        if (state.isError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Bir hata oluştu'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: AlertDialog(
        title: Text(isEditing ? 'Kullanıcı Düzenle' : 'Yeni Kullanıcı'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Ad Soyad',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ad soyad gerekli';
                  }
                  if (value.length < 2) {
                    return 'Ad soyad en az 2 karakter olmalı';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-posta',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'E-posta gerekli';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Geçerli bir e-posta adresi girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _avatarController,
                decoration: const InputDecoration(
                  labelText: 'Avatar URL (Opsiyonel)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: _submitForm,
            child: Text(isEditing ? 'Güncelle' : 'Oluştur'),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final user = UserModel(
        id: widget.user?.id ?? '',
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        avatar: _avatarController.text.trim().isEmpty 
          ? null 
          : _avatarController.text.trim(),
        createdAt: widget.user?.createdAt ?? DateTime.now(),
        isActive: widget.user?.isActive ?? true,
      );

      if (isEditing) {
        context.read<UserBloc>().add(UpdateUser(user));
      } else {
        context.read<UserBloc>().add(CreateUser(user));
      }
    }
  }
}
```

## 🧪 Testing

### Unit Tests

```dart
// test/domain/usecase/user/get_user_usecase_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:your_app/domain/usecase/user/get_user_usecase.dart';
import 'package:your_app/domain/repositories/user_repository.dart';
import 'package:your_app/domain/model/user/user_model.dart';
import 'package:your_app/core/services/network_error.dart';

@GenerateMocks([UserRepository])
void main() {
  late GetUserUseCase useCase;
  late MockUserRepository mockRepository;

  setUp(() {
    mockRepository = MockUserRepository();
    useCase = GetUserUseCase(mockRepository);
  });

  const testUserId = 'test-user-id';
  const testUser = UserModel(
    id: testUserId,
    name: 'Test User',
    email: 'test@example.com',
    createdAt: null,
  );

  test('should get user from repository', () async {
    // arrange
    when(mockRepository.getUser(testUserId))
        .thenAnswer((_) async => const Left(testUser));

    // act
    final result = await useCase(testUserId);

    // assert
    expect(result, const Left(testUser));
    verify(mockRepository.getUser(testUserId));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return error when repository fails', () async {
    // arrange
    const error = NetworkError.serverError('Server error');
    when(mockRepository.getUser(testUserId))
        .thenAnswer((_) async => const Right(error));

    // act
    final result = await useCase(testUserId);

    // assert
    expect(result, const Right(error));
    verify(mockRepository.getUser(testUserId));
    verifyNoMoreInteractions(mockRepository);
  });
}
```

### Widget Tests

```dart
// test/presentation/user/widget/user_list_item_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_app/presentation/user/widget/user_list_item.dart';
import 'package:your_app/domain/model/user/user_model.dart';

void main() {
  late UserModel testUser;

  setUp(() {
    testUser = const UserModel(
      id: 'test-id',
      name: 'Test User',
      email: 'test@example.com',
      createdAt: null,
    );
  });

  testWidgets('should display user information correctly', (tester) async {
    // arrange
    bool onTapCalled = false;
    bool onEditCalled = false;
    bool onDeleteCalled = false;

    // act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UserListItem(
            user: testUser,
            onTap: () => onTapCalled = true,
            onEdit: () => onEditCalled = true,
            onDelete: () => onDeleteCalled = true,
          ),
        ),
      ),
    );

    // assert
    expect(find.text('Test User'), findsOneWidget);
    expect(find.text('test@example.com'), findsOneWidget);
    expect(find.byIcon(Icons.edit), findsOneWidget);
    expect(find.byIcon(Icons.delete), findsOneWidget);
  });

  testWidgets('should call onTap when tapped', (tester) async {
    // arrange
    bool onTapCalled = false;

    // act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UserListItem(
            user: testUser,
            onTap: () => onTapCalled = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ListTile));

    // assert
    expect(onTapCalled, true);
  });
}
```

## 🚀 Performance Optimization

### 1. Lazy Loading

```dart
// Pagination support
class PaginatedUserState extends UserState {
  final bool hasReachedMax;
  final int currentPage;
  
  const PaginatedUserState({
    super.status,
    super.message,
    super.errorMessage,
    super.selectedUser,
    super.users,
    super.filteredUsers,
    super.searchQuery,
    this.hasReachedMax = false,
    this.currentPage = 1,
  });
  
  @override
  PaginatedUserState copyWith({...}) {
    // Implementation
  }
}
```

### 2. Image Caching

```dart
// Cached network image
CachedNetworkImage(
  imageUrl: user.avatar!,
  placeholder: (context, url) => const CircularProgressIndicator(),
  errorWidget: (context, url, error) => const Icon(Icons.error),
  imageBuilder: (context, imageProvider) => CircleAvatar(
    backgroundImage: imageProvider,
  ),
)
```

### 3. Debounced Search

```dart
// Search with debounce
Timer? _searchDebounce;

void _onSearchChanged(String query) {
  if (_searchDebounce?.isActive ?? false) {
    _searchDebounce!.cancel();
  }
  
  _searchDebounce = Timer(const Duration(milliseconds: 500), () {
    context.read<UserBloc>().add(SearchUsers(query));
  });
}
```

## 🎨 Özelleştirme

- Tema: `lib/core/init/theme/colors/*`, `lib/core/init/theme/text/*`
- Logo: `assets/images/logo/app_logo.svg`
- Başlangıç rotası: `lib/core/router/app_router.dart`
- Localization: `assets/lang`, script: `bash script/lang.sh`
- Logging: `lib/core/init/logger/logger.dart` üzerinden
- Network: `lib/core/services/network_manager.dart` + `NetworkError`
- Storage: `lib/core/services/secure_storage.dart` + `lib/core/storage/secure_storage.dart`

Koyu tema eklemek için `DarkColors`/`AppThemeDark` yapısı oluşturup `ThemeManager.createTheme` ile seçebilirsiniz.

## 🧭 Web İpuçları

- Renderer: `--web-renderer canvaskit` daha stabil ve önerilir.
- Device Preview: Web’de debug modunda açıktır; farklı cihaz boyutlarını taklit eder.
- Input assert uyarıları debug’ta çıkabilir; release modda görünmez.

## 🔍 Troubleshooting

### Common Issues

#### 1. Build Runner Errors
```bash
# Clean and rebuild
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

#### 2. Dependency Injection Errors
```dart
// Check if service is registered
if (getIt.isRegistered<UserRepository>()) {
  final repository = getIt<UserRepository>();
}
```

#### 3. Network Errors
```dart
// Check internet connection
final hasInternet = await NetworkManager.instance.hasInternetConnection();
if (!hasInternet) {
  // Show offline message
}
```

#### 4. State Management Issues
```dart
// Use BlocListener for side effects
BlocListener<UserBloc, UserState>(
  listener: (context, state) {
    if (state.isError) {
      // Handle error
    }
  },
  child: YourWidget(),
)
```

## 📚 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Bloc Documentation](https://bloclibrary.dev/)
- [Auto Route Documentation](https://autoroute.vercel.app/)
- [GetIt Documentation](https://pub.dev/packages/get_it)
- [Dio Documentation](https://pub.dev/packages/dio)

---

Bu kılavuz ile Flutter Bloc Template'i etkili bir şekilde kullanabilir ve geliştirebilirsiniz! 🎉
