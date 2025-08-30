import 'package:dartz/dartz.dart';
import '../init/constants/app_constants.dart';
import 'network_error.dart';

abstract class BaseRepository {
  const BaseRepository();
}

abstract class BaseApiRepository extends BaseRepository {
  const BaseApiRepository();
}

abstract class BaseLocalRepository extends BaseRepository {
  const BaseLocalRepository();
}

abstract class BaseRepositoryManager<T> extends BaseRepository {
  const BaseRepositoryManager();

  // CRUD Operations
  Future<Either<NetworkError, T>> create(T data);
  Future<Either<NetworkError, T>> read(String id);
  Future<Either<NetworkError, T>> update(String id, T data);
  Future<Either<NetworkError, bool>> delete(String id);
  
  // List Operations
  Future<Either<NetworkError, List<T>>> getAll();
  Future<Either<NetworkError, List<T>>> getByPage(int page, {int pageSize = AppConstants.defaultPageSize});
  Future<Either<NetworkError, List<T>>> search(String query);
  
  // Batch Operations
  Future<Either<NetworkError, List<T>>> createMany(List<T> dataList);
  Future<Either<NetworkError, bool>> updateMany(List<T> dataList);
  Future<Either<NetworkError, bool>> deleteMany(List<String> ids);
  
  // Cache Operations
  Future<Either<NetworkError, T?>> getFromCache(String key);
  Future<Either<NetworkError, bool>> saveToCache(String key, T data);
  Future<Either<NetworkError, bool>> removeFromCache(String key);
  Future<Either<NetworkError, bool>> clearCache();
}

abstract class BaseApiRepositoryManager<T> extends BaseRepositoryManager<T> {
  const BaseApiRepositoryManager();
  
  // API specific operations
  Future<Either<NetworkError, T>> createWithProgress(T data, Function(int) onProgress);
  Future<Either<NetworkError, T>> updateWithProgress(String id, T data, Function(int) onProgress);
  Future<Either<NetworkError, String>> uploadFile(String filePath, Function(int) onProgress);
  Future<Either<NetworkError, String>> downloadFile(String url, String savePath, Function(int) onProgress);
}

abstract class BaseLocalRepositoryManager<T> extends BaseRepositoryManager<T> {
  const BaseLocalRepositoryManager();
  
  // Local storage specific operations
  Future<Either<NetworkError, List<T>>> getByFilter(Map<String, dynamic> filters);
  Future<Either<NetworkError, List<T>>> getByDateRange(DateTime startDate, DateTime endDate);
  Future<Either<NetworkError, List<T>>> getByCategory(String category);
  Future<Either<NetworkError, int>> getCount();
  Future<Either<NetworkError, bool>> exists(String id);
}

// Repository Result wrapper
class RepositoryResult<T> {
  final bool isSuccess;
  final T? data;
  final NetworkError? error;
  final String? message;

  const RepositoryResult._({
    required this.isSuccess,
    this.data,
    this.error,
    this.message,
  });

  factory RepositoryResult.success(T data, [String? message]) {
    return RepositoryResult._(
      isSuccess: true,
      data: data,
      message: message,
    );
  }

  factory RepositoryResult.failure(NetworkError error, [String? message]) {
    return RepositoryResult._(
      isSuccess: false,
      error: error,
      message: message,
    );
  }

  bool get isFailure => !isSuccess;

  T? get value => isSuccess ? data : null;
  NetworkError? get failure => isFailure ? error : null;

  RepositoryResult<R> map<R>(R Function(T) transform) {
    final d = data;
    if (isSuccess && d != null) {
      return RepositoryResult.success(transform(d));
    }
    final e = error ?? NetworkError.unknown(message ?? 'Unknown error');
    return RepositoryResult.failure(e, message);
  }

  RepositoryResult<R> flatMap<R>(RepositoryResult<R> Function(T) transform) {
    final d = data;
    if (isSuccess && d != null) {
      return transform(d);
    }
    final e = error ?? NetworkError.unknown(message ?? 'Unknown error');
    return RepositoryResult.failure(e, message);
  }

  void when({
    required Function(T data) success,
    required Function(NetworkError error) failure,
  }) {
    final d = data;
    final e = error;
    if (isSuccess && d != null) {
      success(d);
    } else if (isFailure && e != null) {
      failure(e);
    }
  }

  void whenOrNull({
    Function(T data)? success,
    Function(NetworkError error)? failure,
  }) {
    final d = data;
    final e = error;
    if (isSuccess && d != null) {
      success?.call(d);
    } else if (isFailure && e != null) {
      failure?.call(e);
    }
  }
}
