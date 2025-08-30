part of 'splash_bloc.dart';

abstract class SplashEvent {
  const SplashEvent();
}

class CheckAuthStatus extends SplashEvent {
  const CheckAuthStatus();
}
