import 'package:go_router/go_router.dart';
import 'package:monumento/application/authentication/authentication_bloc.dart';
import 'package:monumento/application/authentication/login_register/login_register_bloc.dart';
import 'package:monumento/presentation/authentication/login_view.dart';
import 'package:monumento/presentation/authentication/onboarding_view.dart';
import 'package:monumento/presentation/authentication/reset_password_view.dart';
import 'package:monumento/presentation/authentication/sign_up_view.dart';
import 'package:monumento/presentation/home/home_view.dart';
import 'package:monumento/presentation/settings/mobile/update_profile_screen_mobile.dart';
import 'package:monumento/service_locator.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeView(),
      redirect: (context, state) {
        final authState = locator<AuthenticationBloc>().state;

        // Allow access if authenticated
        if (authState is Authenticated) {
          return null;
        }

        // Allow access if currently authenticating (during signup flow)
        if (authState is Uninitialized) {
          return null;
        }

        // Only redirect to login if definitely unauthenticated
        if (authState is Unauthenticated) {
          return '/login';
        }

        return null;
      },
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginView(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const SignUpView(),
    ),
    GoRoute(
      path: '/reset-password',
      builder: (context, state) => const ResetPasswordView(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingView(),
    ),
    GoRoute(
      path: '/update_profile',
      builder: (context, state) => const UpdateProfileScreenMobile(),
    ),
  ],
);
