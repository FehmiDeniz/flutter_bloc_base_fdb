import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/router/app_router.gr.dart';
import '../../../data/di/injection.dart';
import '../viewmodel/splash_bloc.dart';

@RoutePage()
class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('\n=== Splash Ekranı Başlatıldı ===');
    return BlocProvider(
      create: (context) {
        debugPrint('SplashBloc başlatılıyor');
        return getIt<SplashBloc>()..add(const CheckAuthStatus());
      },
      child: const _SplashView(),
    );
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashBloc, SplashState>(
      listener: (context, state) {
        debugPrint('\nSplash Durumu Değişti: ${state.status}');

        if (state.status == SplashStatus.authenticated) {
          debugPrint('Kullanıcı oturumu açık');
          debugPrint('Ana Sayfaya (BottomBar) yönlendiriliyor');
          context.router.replace(const BottomBarRoute());
        } else if (state.status == SplashStatus.unauthenticated) {
          debugPrint('Kullanıcı oturumu kapalı');
          debugPrint('Giriş ekranına yönlendiriliyor');
          context.router.replace(const LoginRoute());
        }
      },
      child: const Scaffold(
        body: Center(
          child: SizedBox(
            height: 56,
            width: 56,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
        ),
      ),
    );
  }
}
