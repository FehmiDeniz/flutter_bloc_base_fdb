part of 'splash_bloc.dart';

enum SplashStatus { initial, loading, authenticated, unauthenticated }

class SplashState {
  final SplashStatus status;

  const SplashState({
    this.status = SplashStatus.initial,
  });

  SplashState copyWith({
    SplashStatus? status,
  }) {
    return SplashState(
      status: status ?? this.status,
    );
  }
}
