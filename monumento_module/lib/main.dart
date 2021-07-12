import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monumento/blocs/feed/feed_bloc.dart';
import 'package:monumento/blocs/new_post/new_post_bloc.dart';
import 'package:monumento/resources/social/firebase_social_repository.dart';
import 'package:monumento/resources/social/social_repository.dart';
import 'package:monumento/screens/app_intro.dart';
import 'package:monumento/blocs/authentication/authentication_bloc.dart';
import 'package:monumento/blocs/bookmarked_monuments/bookmarked_monuments_bloc.dart';
import 'package:monumento/blocs/login_register/login_register_bloc.dart';
import 'package:monumento/blocs/popular_monuments/popular_monuments_bloc.dart';
import 'package:monumento/blocs/profile/profile_bloc.dart';
import 'package:monumento/resources/authentication/firebase_authentication_repository.dart';
import 'package:monumento/resources/monuments/firebase_monument_repository.dart';
import 'package:monumento/screens/feed/feed_screen.dart';
import 'package:monumento/screens/new_post/new_post_screen.dart';
import 'screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';

Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseAuthenticationRepository _authRepository =
  FirebaseAuthenticationRepository();
  final FirebaseMonumentRepository _monumentRepository =
  FirebaseMonumentRepository();
  final FirebaseSocialRepository _socialRepository = FirebaseSocialRepository();
  AuthenticationBloc _authenticationBloc;
  LoginRegisterBloc _loginRegisterBloc;
  ProfileBloc _profileBloc;
  BookmarkedMonumentsBloc _bookmarkedMonumentsBloc;
  PopularMonumentsBloc _popularMonumentsBloc;
  NewPostBloc _newPostBloc;
  FeedBloc _feedBloc;


  @override
  void initState() {
    super.initState();
    _authenticationBloc =
        AuthenticationBloc(authenticationRepository: _authRepository);
    _loginRegisterBloc = LoginRegisterBloc(
        authenticationRepository: _authRepository,
        authenticationBloc: _authenticationBloc);
    _profileBloc = ProfileBloc(firebaseMonumentRepository: _monumentRepository);
    _bookmarkedMonumentsBloc = BookmarkedMonumentsBloc(
        firebaseMonumentRepository: _monumentRepository);
    _popularMonumentsBloc =
        PopularMonumentsBloc(firebaseMonumentRepository: _monumentRepository);
    _newPostBloc = NewPostBloc(socialRepository: _socialRepository);
    _feedBloc = FeedBloc(socialRepository: _socialRepository);

    _popularMonumentsBloc.add(GetPopularMonuments());
    _authenticationBloc.add(AppStarted());
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthenticationBloc>(
          create: (_) => _authenticationBloc,
        ),
        BlocProvider<LoginRegisterBloc>(
          create: (_) => _loginRegisterBloc,
        ),
        BlocProvider<ProfileBloc>(
          create: (_) => _profileBloc,
        ),
        BlocProvider<PopularMonumentsBloc>(
          create: (_) => _popularMonumentsBloc,
        ),
        BlocProvider<BookmarkedMonumentsBloc>(
          create: (_) => _bookmarkedMonumentsBloc,
        ),

        BlocProvider<NewPostBloc>(
          create: (_) => _newPostBloc,
        ),
        BlocProvider<FeedBloc>(
          create: (_) => _feedBloc,
        ),

      ],
      child: MaterialApp(
        title: 'Monumento',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
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
        routes: {'/newPostScreen': (_) => NewPostScreen()},
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _bookmarkedMonumentsBloc.close();
    _popularMonumentsBloc.close();
    _profileBloc.close();
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
