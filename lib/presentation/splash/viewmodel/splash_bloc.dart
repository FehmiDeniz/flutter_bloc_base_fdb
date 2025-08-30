import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecase/auth/auth_usecase.dart';
part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final AuthUseCase _authUseCase;

  SplashBloc({
    required AuthUseCase authUseCase,
  })  : _authUseCase = authUseCase,
        super(const SplashState()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<SplashState> emit,
  ) async {
    debugPrint('\n=== Oturum Durumu Kontrol Ediliyor ===');
    emit(state.copyWith(status: SplashStatus.loading));
    debugPrint('Durum güncellendi: yükleniyor');

    debugPrint('Minimum splash süresi bekleniyor (1 saniye)');
    await Future.delayed(const Duration(seconds: 1));

    debugPrint('Kullanıcı girişi kontrol ediliyor');
    final isLoggedIn = await _authUseCase.isLoggedIn();
    debugPrint('Giriş durumu: ${isLoggedIn ? "Açık" : "Kapalı"}');

    final newStatus = isLoggedIn ? SplashStatus.authenticated : SplashStatus.unauthenticated;

    debugPrint('Durum güncelleniyor: $newStatus');
    emit(state.copyWith(status: newStatus));
    debugPrint('=== Oturum Kontrolü Tamamlandı ===\n');
  }
}
