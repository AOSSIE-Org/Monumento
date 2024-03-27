import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monumento/blocs/feed/feed_bloc.dart';
import 'package:monumento/navigation/route_generator.dart';
import 'package:monumento/resources/authentication/authentication_repository.dart';
import 'package:monumento/resources/monuments/monument_repository.dart';
import 'package:monumento/resources/social/firebase_social_repository.dart';
import 'package:monumento/resources/social/social_repository.dart';
import 'package:monumento/blocs/authentication/authentication_bloc.dart';
import 'package:monumento/blocs/bookmarked_monuments/bookmarked_monuments_bloc.dart';
import 'package:monumento/blocs/login_register/login_register_bloc.dart';
import 'package:monumento/resources/authentication/firebase_authentication_repository.dart';
import 'package:monumento/resources/monuments/firebase_monument_repository.dart';
import 'package:monumento/utilities/simple_bloc_observer.dart';
import 'package:monumento/ui/screens/app_intro/app_intro.dart';
import 'package:monumento/ui/screens/home/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  }
  Bloc.observer = SimpleBlocObserver();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthenticationRepository _authRepository =
      FirebaseAuthenticationRepository();
  final MonumentRepository _monumentRepository = FirebaseMonumentRepository();
  final SocialRepository _socialRepository = FirebaseSocialRepository();
  AuthenticationBloc _authenticationBloc;
  LoginRegisterBloc _loginRegisterBloc;
  BookmarkedMonumentsBloc _bookmarkedMonumentsBloc;
  FeedBloc _feedBloc;

  @override
  void initState() {
    super.initState();
    _authenticationBloc =
        AuthenticationBloc(authenticationRepository: _authRepository);
    _loginRegisterBloc = LoginRegisterBloc(
        authenticationRepository: _authRepository,
        authenticationBloc: _authenticationBloc,
        socialRepository: _socialRepository);
    _bookmarkedMonumentsBloc = BookmarkedMonumentsBloc(
        firebaseMonumentRepository: _monumentRepository);
    _feedBloc = FeedBloc(socialRepository: _socialRepository);
    _authenticationBloc.add(AppStarted());
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return MultiRepositoryProvider(
        providers: [
          RepositoryProvider(create: (_) => _socialRepository),
          RepositoryProvider(create: (_) => _authRepository),
          RepositoryProvider(create: (_) => _monumentRepository)
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AuthenticationBloc>(
              create: (_) => _authenticationBloc,
            ),
            BlocProvider<LoginRegisterBloc>(
              create: (_) => _loginRegisterBloc,
            ),
            BlocProvider<BookmarkedMonumentsBloc>(
              create: (_) => _bookmarkedMonumentsBloc,
            ),
            BlocProvider<FeedBloc>(
              create: (_) => _feedBloc,
            ),
          ],
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
                statusBarIconBrightness: Brightness.dark,
                statusBarColor: Colors.white),
            child: MaterialApp(
              title: 'Monumento',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                  appBarTheme: AppBarTheme(
                      systemOverlayStyle: SystemUiOverlayStyle.dark),
                  scaffoldBackgroundColor: Colors.white,
                  primarySwatch: Colors.amber,
                  fontFamily: GoogleFonts.montserrat().fontFamily),
              home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
                  builder: (BuildContext context, AuthenticationState state) {
                if (state is Authenticated) {
                  return HomeScreen(
                    user: state.user,
                  );
                  // return Scaffold(body: FeedScreen());
                } else if (state is Unauthenticated) {
                  return AppIntroPage();
                }
                return Scaffold(
                  backgroundColor: Colors.white,
                );
              }),
              onGenerateRoute: RouteGenerator.onGenerateRoute,
            ),
          ),
        ));
  }

  @override
  void dispose() {
    super.dispose();
    _bookmarkedMonumentsBloc.close();
    _loginRegisterBloc.close();
    _authenticationBloc.close();
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Text(
          'Welcome to Monumento!',
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(
          Icons.home,
          color: Colors.white,
        ),
      ),
    );
  }
}
