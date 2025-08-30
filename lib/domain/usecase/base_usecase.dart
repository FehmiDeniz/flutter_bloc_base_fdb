import 'package:dartz/dartz.dart';
import '../../core/services/network_error.dart';

abstract class BaseUseCase<Type, Params> {
  const BaseUseCase();

  Future<Either<NetworkError, Type>> call(Params params);
}

abstract class BaseStreamUseCase<Type, Params> {
  const BaseStreamUseCase();

  Stream<Either<NetworkError, Type>> call(Params params);
}

abstract class BaseFutureUseCase<Type, Params> {
  const BaseFutureUseCase();

  Future<Type> call(Params params);
}

// No parameters use case
abstract class BaseUseCaseNoParams<Type> {
  const BaseUseCaseNoParams();

  Future<Either<NetworkError, Type>> call();
}

abstract class BaseStreamUseCaseNoParams<Type> {
  const BaseStreamUseCaseNoParams();

  Stream<Either<NetworkError, Type>> call();
}

abstract class BaseFutureUseCaseNoParams<Type> {
  const BaseFutureUseCaseNoParams();

  Future<Type> call();
}

// Use case result wrapper
class UseCaseResult<T> {
  final bool isSuccess;
  final T? data;
  final NetworkError? error;
  final String? message;

  const UseCaseResult._({
    required this.isSuccess,
    this.data,
    this.error,
    this.message,
  });

  factory UseCaseResult.success(T data, [String? message]) {
    return UseCaseResult._(
      isSuccess: true,
      data: data,
      message: message,
    );
  }

  factory UseCaseResult.failure(NetworkError error, [String? message]) {
    return UseCaseResult._(
      isSuccess: false,
      error: error,
      message: message,
    );
  }

  bool get isFailure => !isSuccess;

  T? get value => isSuccess ? data : null;
  NetworkError? get failure => isFailure ? error : null;

  UseCaseResult<R> map<R>(R Function(T) transform) {
    final d = data;
    if (isSuccess && d != null) {
      return UseCaseResult.success(transform(d));
    }
    final e = error ?? NetworkError.unknown(message ?? 'Unknown error');
    return UseCaseResult.failure(e, message);
  }

  UseCaseResult<R> flatMap<R>(UseCaseResult<R> Function(T) transform) {
    final d = data;
    if (isSuccess && d != null) {
      return transform(d);
    }
    final e = error ?? NetworkError.unknown(message ?? 'Unknown error');
    return UseCaseResult.failure(e, message);
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

// Use case parameters base class
abstract class UseCaseParams {
  const UseCaseParams();
}

// No parameters class
class NoParams extends UseCaseParams {
  const NoParams();
}

// Pagination parameters
class PaginationParams extends UseCaseParams {
  final int page;
  final int pageSize;
  final String? searchQuery;
  final Map<String, dynamic>? filters;
  final String? sortBy;
  final bool ascending;

  const PaginationParams({
    required this.page,
    this.pageSize = 20,
    this.searchQuery,
    this.filters,
    this.sortBy,
    this.ascending = true,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaginationParams &&
        other.page == page &&
        other.pageSize == pageSize &&
        other.searchQuery == searchQuery &&
        other.filters == filters &&
        other.sortBy == sortBy &&
        other.ascending == ascending;
  }

  @override
  int get hashCode {
    return page.hashCode ^
        pageSize.hashCode ^
        searchQuery.hashCode ^
        filters.hashCode ^
        sortBy.hashCode ^
        ascending.hashCode;
  }
}

// Search parameters
class SearchParams extends UseCaseParams {
  final String query;
  final Map<String, dynamic>? filters;
  final int? limit;
  final int? offset;

  const SearchParams({
    required this.query,
    this.filters,
    this.limit,
    this.offset,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchParams &&
        other.query == query &&
        other.filters == filters &&
        other.limit == limit &&
        other.offset == offset;
  }

  @override
  int get hashCode {
    return query.hashCode ^
        filters.hashCode ^
        limit.hashCode ^
        offset.hashCode;
  }
}
