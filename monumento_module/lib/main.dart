import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monumento/app_intro.dart';
import 'home_screen.dart';

FirebaseUser _loggedInUser;
bool _isLoggedIn = false;

Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (await FirebaseAuth.instance.currentUser() != null) {
    print('LOGGED IN: ' + FirebaseAuth.instance.currentUser().toString());
    _loggedInUser = await FirebaseAuth.instance.currentUser();
    _isLoggedIn = true;
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);
    return MaterialApp(
      title: 'Monumento',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.amber,
          fontFamily: GoogleFonts.montserrat().fontFamily),
      home: _isLoggedIn
          ? HomeScreen(
              user: _loggedInUser,
            )
          : AppIntroPage(),
    );
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
