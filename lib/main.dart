import 'dart:io';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:monumento/application/authentication/authentication_bloc.dart';
import 'package:monumento/application/monument_review_hub/review_hub_provider.dart';
import 'package:monumento/domain/repositories/review_hub_repository.dart';
import 'package:monumento/presentation/authentication/onboarding_view.dart';
import 'package:monumento/presentation/home/home_view.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/bloc_observer_logger.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Failed to load .env file: $e');
  }

  setupLocator();
  Bloc.observer = BlocObserverLogger();

  runApp(
    DevicePreview(
      enabled: !kReleaseMode && kIsWeb,
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => locator<AuthenticationBloc>()),
        ],
        child: const MyApp(),
      ),
    ),
  );
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
      designSize = MediaQuery.of(context).size.width < 530
          ? const Size(390, 844)
          : const Size(1440, 1024);
    } else if (Platform.isIOS || Platform.isAndroid) {
      designSize = const Size(390, 844);
    } else {
      designSize = MediaQuery.of(context).size.width < 530
          ? const Size(390, 844)
          : const Size(1440, 1024);
    }

    final reviewHubRepo = locator<ReviewHubRepository>();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ReviewHubProvider(reviewHubRepo),
        ),
      ],
      child: MaterialApp.router(
        useInheritedMediaQuery: true,
        locale: DevicePreview.locale(context),
        routerConfig: router,
        scrollBehavior: NoThumbScrollBehavior().copyWith(scrollbars: false),
        title: 'Monumento',
        theme: ThemeData(
          useMaterial3: false,
          tabBarTheme: const TabBarThemeData(
            indicatorColor: AppColor.appPrimary,
          ),
        ),
        builder: (context, child) {
          return DevicePreview.appBuilder(
            context,
            ResponsiveBreakpoints.builder(
              child: ScreenUtilInit(
                designSize: designSize,
                minTextAdapt: true,
                builder: (context, _) => child!,
              ),
              breakpoints: const [
                Breakpoint(start: 0, end: 450, name: MOBILE),
                Breakpoint(start: 451, end: 800, name: TABLET),
                Breakpoint(start: 801, end: 1920, name: DESKTOP),
                Breakpoint(start: 1921, end: double.infinity, name: '4K'),
              ],
            ),
          );
        },
      ),
    );
  }
}
