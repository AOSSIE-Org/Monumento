import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:monumento/presentation/authentication/login_view.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'application/authentication/authentication_bloc.dart';
import 'firebase_options.dart';
import 'presentation/authentication/onboarding_view.dart';
import 'presentation/home/home_view.dart';
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  setupLocator();
  runApp(const MyApp());
}

class NoThumbScrollBehavior extends ScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Size designSize;
    if (kIsWeb) {
      // if width is less than 530, it means the user resized the window to a smaller size
      if (MediaQuery.of(context).size.width < 530) {
        designSize = const Size(390, 844);
      } else {
        designSize = const Size(1440, 1024);
      }
    } else {
      if (Platform.isIOS || Platform.isAndroid) {
        designSize = const Size(390, 844);
      } else if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
        // if width is less than 530, it means the user resized the window to a smaller size
        if (MediaQuery.of(context).size.width < 530) {
          designSize = const Size(390, 844);
        } else {
          designSize = const Size(1440, 1024);
        }
      } else {
        designSize = const Size(360, 690);
      }
    }

    return MaterialApp.router(
      routerConfig: router,
      scrollBehavior: NoThumbScrollBehavior().copyWith(scrollbars: false),
      title: 'Monumento',
      theme: ThemeData(
        useMaterial3: false,
      ),
      builder: (context, child) {
        return ResponsiveBreakpoints.builder(
          child: ScreenUtilInit(
              designSize: designSize,
              minTextAdapt: true,
              builder: (context, _) {
                return child!;
              }),
          breakpoints: [
            const Breakpoint(start: 0, end: 450, name: MOBILE),
            const Breakpoint(start: 451, end: 800, name: TABLET),
            const Breakpoint(start: 801, end: 1920, name: DESKTOP),
            const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
          ],
        );
      },
    );
  }
}

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      bloc: locator<AuthenticationBloc>(),
      builder: (context, state) {
        if (state is Authenticated) {
          return const HomeView();
        } else if (state is Unauthenticated) {
          return const LoginView();
        } else if (state is OnboardingIncomplete) {
          return const OnboardingView();
        }
        return const Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: CircularProgressIndicator(
              color: AppColor.appPrimary,
            ),
          ),
        );
      },
    );
  }
}
