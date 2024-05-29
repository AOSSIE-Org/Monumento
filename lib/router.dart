import 'package:go_router/go_router.dart';
import 'package:monumento/main.dart';
import 'package:monumento/presentation/authentication/login_view.dart';

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
  ],
);
