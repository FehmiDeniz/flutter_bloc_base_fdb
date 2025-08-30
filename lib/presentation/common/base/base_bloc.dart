import 'package:bloc/bloc.dart';

// Base state enum
enum Status { initial, loading, success, error }

// Base state class
abstract class BaseState {
  final Status status;
  final String? message;
  final String? errorMessage;

  const BaseState({
    this.status = Status.initial,
    this.message,
    this.errorMessage,
  });

  bool get isLoading => status == Status.loading;
  bool get isSuccess => status == Status.success;
  bool get isError => status == Status.error;
  bool get isInitial => status == Status.initial;

  BaseState copyWith({
    Status? status,
    String? message,
    String? errorMessage,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BaseState &&
        other.status == status &&
        other.message == message &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => status.hashCode ^ message.hashCode ^ errorMessage.hashCode;

  @override
  String toString() => 'BaseState(status: $status, message: $message, errorMessage: $errorMessage)';
}

// Base event class
abstract class BaseEvent {
  const BaseEvent();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BaseEvent && other.runtimeType == runtimeType;
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => '$runtimeType()';
}

// Base bloc class
// ignore_for_file: invalid_use_of_visible_for_testing_member

abstract class BaseBloc<Event extends BaseEvent, State extends BaseState>
    extends Bloc<Event, State> {

  BaseBloc(super.initialState);

  // Helper methods for state management
  void emitLoading([String? message]) {
    emit(state.copyWith(
      status: Status.loading,
      message: message,
      errorMessage: null,
    ) as State);
  }

  void emitSuccess([String? message]) {
    emit(state.copyWith(
      status: Status.success,
      message: message,
      errorMessage: null,
    ) as State);
  }

  void emitError(String errorMessage, [String? message]) {
    emit(state.copyWith(
      status: Status.error,
      message: message,
      errorMessage: errorMessage,
    ) as State);
  }

  void emitInitial() {
    emit(state.copyWith(
      status: Status.initial,
      message: null,
      errorMessage: null,
    ) as State);
  }

  // Helper method for async operations
  Future<void> handleAsyncOperation<T>({
    required Future<T> Function() operation,
    required Function(T data) onSuccess,
    Function(String error)? onError,
    String? loadingMessage,
    String? successMessage,
  }) async {
    try {
      emitLoading(loadingMessage);
      final result = await operation();
      onSuccess(result);
      emitSuccess(successMessage);
    } catch (e) {
      final errorMessage = e.toString();
      onError?.call(errorMessage);
      emitError(errorMessage);
    }
  }

  // Helper method for stream operations
  Stream<T> handleStreamOperation<T>({
    required Stream<T> Function() operation,
    required Function(T data) onData,
    Function(String error)? onError,
  }) {
    return operation().handleError((error) {
      final errorMessage = error.toString();
      onError?.call(errorMessage);
      emitError(errorMessage);
    }).map((data) {
      onData(data);
      return data;
    });
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    super.onError(error, stackTrace);
    emitError(error.toString());
  }
}

// Base cubit class
abstract class BaseCubit<State extends BaseState> extends Cubit<State> {
  BaseCubit(super.initialState);

  // Helper methods for state management
  void emitLoading([String? message]) {
    emit(state.copyWith(
      status: Status.loading,
      message: message,
      errorMessage: null,
    ) as State);
  }

  void emitSuccess([String? message]) {
    emit(state.copyWith(
      status: Status.success,
      message: message,
      errorMessage: null,
    ) as State);
  }

  void emitError(String errorMessage, [String? message]) {
    emit(state.copyWith(
      status: Status.error,
      message: message,
      errorMessage: errorMessage,
    ) as State);
  }

  void emitInitial() {
    emit(state.copyWith(
      status: Status.initial,
      message: null,
      errorMessage: null,
    ) as State);
  }

  // Helper method for async operations
  Future<void> handleAsyncOperation<T>({
    required Future<T> Function() operation,
    required Function(T data) onSuccess,
    Function(String error)? onError,
    String? loadingMessage,
    String? successMessage,
  }) async {
    try {
      emitLoading(loadingMessage);
      final result = await operation();
      onSuccess(result);
      emitSuccess(successMessage);
    } catch (e) {
      final errorMessage = e.toString();
      onError?.call(errorMessage);
      emitError(errorMessage);
    }
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    super.onError(error, stackTrace);
    emitError(error.toString());
  }
}
