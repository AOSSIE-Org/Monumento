import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monumento/app_intro.dart';
import 'package:monumento/blocs/authentication/authentication_bloc.dart';
import 'package:monumento/blocs/login_register/login_register_bloc.dart';
import 'package:monumento/resources/authentication/firebase_authentication_repository.dart';
import 'home_screen.dart';
import 'package:monumento/blocs/authentication/authentication_bloc.dart';

// FirebaseUser _loggedInUser;
// bool _isLoggedIn = false;

Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // if (await FirebaseAuth.instance.currentUser() != null) {
  //   print('LOGGED IN: ' + FirebaseAuth.instance.currentUser().toString());
  //   _loggedInUser = await FirebaseAuth.instance.currentUser();
  //   _isLoggedIn = true;
  // }
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseAuthenticationRepository _authRepository = FirebaseAuthenticationRepository();
  AuthenticationBloc _authenticationBloc;
  LoginRegisterBloc _loginRegisterBloc;

  @override
  void initState() {
    super.initState();
    _authenticationBloc =
        AuthenticationBloc(authenticationRepository: _authRepository);
    _loginRegisterBloc =
        LoginRegisterBloc(authenticationRepository: _authRepository,authenticationBloc: _authenticationBloc);
    _authenticationBloc.add(AppStarted());
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);
    return MultiBlocProvider(
      providers: [BlocProvider<AuthenticationBloc>(
        create: (_) => _authenticationBloc,), BlocProvider<LoginRegisterBloc>(
        create: (_) => _loginRegisterBloc,)
      ],
      child: MaterialApp(
          title: 'Monumento',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
              primarySwatch: Colors.amber,
              fontFamily: GoogleFonts
                  .montserrat()
                  .fontFamily),
          home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
              builder: (BuildContext context, AuthenticationState state) {
                if (state is Authenticated) {
                  return HomeScreen(user: state.user,);
                }
                else if (state is Unauthenticated) {
                  return AppIntroPage();
                }
                return Center(child: CircularProgressIndicator(),);
              }

          )),);
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
