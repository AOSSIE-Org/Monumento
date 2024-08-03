import 'package:go_router/go_router.dart';
import 'package:monumento/main.dart';
import 'package:monumento/presentation/authentication/login_view.dart';
import 'package:monumento/presentation/authentication/onboarding_view.dart';
import 'package:monumento/presentation/authentication/reset_password_view.dart';
import 'package:monumento/presentation/authentication/sign_up_view.dart';
import 'package:monumento/presentation/settings/mobile/update_profile_screen_mobile.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const Wrapper(),
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
