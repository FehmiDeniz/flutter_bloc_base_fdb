import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kartal/kartal.dart';
import '../../../../common/utils/device_id.dart';
import '../../../../common/utils/toast_message.dart';
import '../../../../common/widget/loading_indicator.dart';
import '../../../../core/init/constants/image_constants.dart';
import '../../../../core/init/lang/locale_keys.g.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/router/app_router.gr.dart';
import '../../../../data/di/injection.dart';
import '../viewmodel/bloc/login_bloc.dart';

@RoutePage()
class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<LoginBloc>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.status == LoginStatus.success) {
          showSuccessMessage(context, state.loginResponse?.message);
          router.replace(const BottomBarRoute());
        } else if (state.status == LoginStatus.failure) {
          showErrorLoginMessage(context, state.loginResponse?.message);
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Text(state.failure?.errorMessage ?? 'error_message'),
          //     backgroundColor: Colors.red,
          //     behavior: SnackBarBehavior.floating,
          //     action: SnackBarAction(
          //       label: 'ok',
          //       textColor: Colors.white,
          //       onPressed: () {
          //         context.read<LoginBloc>().add(const ClearLoginError());
          //       },
          //     ),
          //   ),
          // );
        }
      },
      builder: (context, state) {
        final bloc = context.read<LoginBloc>();

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Padding(
                padding: context.padding.horizontalLow,
                child: Form(
                  key: bloc.formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      context.sized.emptySizedHeightBoxNormal,
                      SvgPicture.asset(ImageConstants.instance.loginLogo),
                      context.sized.emptySizedHeightBoxNormal,
                      Text(
                        LocaleKeys.login_login.tr(),
                        style: context.general.textTheme.headlineLarge,
                        textAlign: TextAlign.center,
                      ),
                      context.sized.emptySizedHeightBoxLow3x,
                      _buildUsernameField(context, bloc),
                      context.sized.emptySizedHeightBoxLow,
                      _buildPasswordField(context, bloc, state),
                      context.sized.emptySizedHeightBoxLow,
                      _buildRememberMe(context, bloc, state),
                      context.sized.emptySizedHeightBoxLow3x,
                      _buildLoginButton(context, bloc, state),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUsernameField(BuildContext context, LoginBloc bloc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: context.padding.horizontalLow,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: LocaleKeys.login_email.tr(),
                    style: context.general.textTheme.bodyLarge
                        ?.copyWith(color: context.general.colorScheme.onPrimary, fontWeight: FontWeight.w500),
                  ),
                  TextSpan(
                    text: '*',
                    style: context.general.textTheme.bodyLarge?.copyWith(
                      color: context.general.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )),
        context.sized.emptySizedHeightBoxLow,
        TextFormField(
          controller: bloc.usernameController,
          style: context.general.textTheme.bodyMedium?.copyWith(color: context.general.colorScheme.onPrimary),
          decoration: InputDecoration(
            hintText: LocaleKeys.login_emailPlaceholder.tr(),
            hintStyle: context.general.textTheme.bodyMedium,
            filled: true,
            fillColor: context.general.colorScheme.tertiary,
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: bloc.passwordController.text.isEmpty
                    ? context.general.colorScheme.onTertiary
                    : context.general.colorScheme.tertiary,
              ),
            ),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return LocaleKeys.login_invalidEmail.tr();
            }
            return null;
          },
          textInputAction: TextInputAction.next,
        ),
      ],
    );
  }

  Widget _buildPasswordField(BuildContext context, LoginBloc bloc, LoginState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: context.padding.horizontalLow,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: LocaleKeys.login_password.tr(),
                    style: context.general.textTheme.bodyLarge
                        ?.copyWith(color: context.general.colorScheme.onPrimary, fontWeight: FontWeight.w500),
                  ),
                  TextSpan(
                    text: '*',
                    style: context.general.textTheme.bodyLarge?.copyWith(
                      color: context.general.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )),
        context.sized.emptySizedHeightBoxLow,
        TextFormField(
          controller: bloc.passwordController,
          obscureText: !state.isPasswordVisible,
          style: context.general.textTheme.bodyMedium?.copyWith(color: context.general.colorScheme.onPrimary),
          decoration: InputDecoration(
            hintText: LocaleKeys.login_passwordPlaceholder.tr(),
            hintStyle: context.general.textTheme.bodyMedium,
            filled: true,
            fillColor: context.general.colorScheme.tertiary,
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: bloc.passwordController.text.isEmpty
                    ? context.general.colorScheme.onTertiary
                    : context.general.colorScheme.tertiary,
              ),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                state.isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                color: context.general.colorScheme.onPrimary,
              ),
              onPressed: () {
                bloc.add(const TogglePasswordVisibility());
              },
            ),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return LocaleKeys.login_invalidPassword.tr();
            }
            return null;
          },
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _submitForm(context, bloc),
        ),
      ],
    );
  }

  Widget _buildRememberMe(BuildContext context, LoginBloc bloc, LoginState state) {
    return Row(
      children: [
        Checkbox(
          checkColor: context.general.colorScheme.inverseSurface,
          value: state.rememberMe,
          onChanged: (_) {
            bloc.add(const ToggleRememberMe());
          },
        ),
        GestureDetector(
          onTap: () {
            bloc.add(const ToggleRememberMe());
          },
          child: Text(
            LocaleKeys.login_rememberMe.tr(),
            style: context.general.textTheme.bodyLarge?.copyWith(color: context.general.colorScheme.onPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(BuildContext context, LoginBloc bloc, LoginState state) {
    return state.status == LoginStatus.loading
        ? const Center(child: AppLoadingIndicator())
        : ElevatedButton(
            onPressed: () => _submitForm(context, bloc),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.general.colorScheme.scrim,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              LocaleKeys.login_loginButton.tr(),
              style: context.general.textTheme.bodyLarge?.copyWith(color: context.general.colorScheme.inverseSurface),
            ),
          );
  }

  Future<void> _submitForm(BuildContext context, LoginBloc bloc) async {
    if (bloc.formKey.currentState?.validate() ?? false) {
      final deviceId = await getDeviceId();

      if (!context.mounted) return;

      bloc.add(
        LoginSubmitted(
          username: bloc.usernameController.text,
          password: bloc.passwordController.text,
          deviceUnique: deviceId,
        ),
      );
    }
  }
}
