import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../../core/router/app_router.gr.dart';
import '../../data/di/injection.dart';
import '../../domain/usecase/auth/auth_usecase.dart';

@RoutePage()
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: const Text('profile'),
        actions: [
          IconButton(
            onPressed: () => _showLogoutDialog(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: const Center(
        child: Text('Profil'),
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    debugPrint('Çıkış yapmak istediğinize emin misiniz?');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('logout_title'),
        content: const Text('logout_message'),
        actions: [
          TextButton(
            onPressed: () {
              debugPrint('Logout cancelled');
              context.router.maybePop(false);
            },
            child: const Text('cancel'),
          ),
          TextButton(
            onPressed: () {
              debugPrint('Çıkış işlemi onaylandı.');
              context.router.maybePop(true);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('logout'),
          ),
        ],
      ),
    );

    debugPrint('Dialog result: $result');

    if (!context.mounted) return;
    if (result == true) {
      await _logout(context);
    }
  }

  Future<void> _logout(BuildContext context) async {
    debugPrint('Çıkış işlemi başlatılıyor.');

    try {
      final authUseCase = getIt<AuthUseCase>();

      debugPrint('Saklanan tokenlar ve kullanıcı verileri temizleniyor.');
      await authUseCase.logout();
      debugPrint('Tokenlar ve kullanıcı verileri başarıyla temizlendi.');

      if (context.mounted) {
        debugPrint('Giriş ekranına yönlendiriliyor.');
        context.router.replace(const LoginRoute());
        debugPrint('Yönlendirme tamamlandı.');
      }
    } catch (e) {
      debugPrint('Çıkış işlemi sırasında bir hata oluştu: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('logout_error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
