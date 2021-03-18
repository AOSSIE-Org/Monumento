import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monumento/blocs/authentication/authentication_bloc.dart';
import 'package:monumento/blocs/login_register/login_register_bloc.dart';
import 'constants.dart';
import 'home_screen.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  var _emailController = TextEditingController();
  var _nameController = TextEditingController();
  var _statusController = TextEditingController();
  var _passwordController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isseen = false;

  AuthenticationBloc _authenticationBloc;
  LoginRegisterBloc _loginRegisterBloc;

  @override
  void initState() {
    super.initState();
    isseen = false;
    _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
    _loginRegisterBloc = BlocProvider.of<LoginRegisterBloc>(context);
  }

  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<FirebaseUser> signUp(email, password) async {
    try {
      AuthResult authResult = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = authResult.user;
      assert(user != null);
      assert(await user.getIdToken() != null);
      return user;
    } catch (e) {
      return null;
    }
  }

  Widget _buildEmailTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Email',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            keyboardType: TextInputType.emailAddress,
            controller: _emailController,
            style: TextStyle(
              color: Colors.amber,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.email,
                color: Colors.amber,
              ),
              hintText: 'Enter your Email',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNameTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Name',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            keyboardType: TextInputType.text,
            controller: _nameController,
            style: TextStyle(
              color: Colors.amber,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.person_pin,
                color: Colors.amber,
              ),
              hintText: 'Enter your Name',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Status',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            keyboardType: TextInputType.text,
            controller: _statusController,
            style: TextStyle(
              color: Colors.amber,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.work,
                color: Colors.amber,
              ),
              hintText: 'Enter your current status',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Password',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            obscureText: !isseen,
            keyboardType: TextInputType.visiblePassword,
            controller: _passwordController,
            style: TextStyle(
              color: Colors.amber,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.amber,
              ),
              hintText: 'Enter your Password',
              hintStyle: kHintTextStyle,
              suffixIcon: IconButton(
                icon: Icon(
                  // Based on passwordVisible state choose the icon
                  isseen ? Icons.visibility : Icons.visibility_off,
                  color: Theme
                      .of(context)
                      .primaryColorDark,
                ),
                onPressed: () {
                  // Update the state i.e. toogle the state of passwordVisible variable
                  setState(() {
                    isseen = !isseen;
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<bool> createUser(FirebaseUser user) async {
    String collection = "users";
    Map<String, dynamic> map = new Map();
    map["auth_id"] = user.uid;
    map["name"] = _nameController.text.trim();
    map["prof_pic"] = '';
    map["status"] = _statusController.text.trim();
    map["email"] = _emailController.text.trim();
    map["password"] = _passwordController.text.trim();

    DocumentReference documentReference =
    Firestore.instance.collection(collection).document();
    Firestore.instance.runTransaction((transaction) async {
      await transaction.set(documentReference, map).catchError((e) {
        return false;
      }).whenComplete(() {
        print('SignedUp!');
        return true;
      });
    }).catchError((e) {
      print(e.toString());
      return false;
    });
    return true;
  }

  Widget _buildSignUpBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: RaisedButton(
        elevation: 5.0,
        splashColor: Colors.lightGreen,
        onPressed: () {
          print('SignUp Button Pressed');
          _loginRegisterBloc.add(SignUpWithEmailPressed(
              email: _emailController.text, password: _passwordController.text));
        },
        padding: EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.white,
        child: Text(
          'REGISTER',
          style: TextStyle(
            color: Colors.amber,
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginRegisterBloc,LoginRegisterState>(
        listener: (_, state) {
          if (state is SignUpSuccess) {
            afterSignUpSuccess(state.user);
          } else if (state is SignUpFailed) {
            afterSignUpFailed();
          }
        },
        builder: (_, state) {
          return Scaffold(
            key: _scaffoldKey,
            body: AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.light,
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: Stack(
                  children: <Widget>[
                    Container(
                      height: double.infinity,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.yellow[600],
                            Colors.amber,
                          ],
                          stops: [0.4, 0.9],
                        ),
                      ),
                    ),
                    Container(
                      height: double.infinity,
                      child: SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.only(
                            left: 40.0, right: 40.0, bottom: 110.0, top: 60.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 35.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 30.0),
                            _buildNameTF(),
                            SizedBox(height: 30.0),
                            _buildStatusTF(),
                            SizedBox(height: 30.0),
                            _buildEmailTF(),
                            SizedBox(
                              height: 30.0,
                            ),
                            _buildPasswordTF(),
                            SizedBox(
                              height: 24.0,
                            ),
                            _buildSignUpBtn(),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  afterSignUpSuccess(FirebaseUser user) {
    _authenticationBloc.add(LoggedIn());

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      backgroundColor: Colors.white,
      content: Text(
        'Signing Up! Please wait...',
        style: TextStyle(color: Colors.amber),
      ),
    ));
    createUser(user).then((value) {
      if (value)
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    HomeScreen(
                      user: user,
                    )),
                (Route<dynamic> route) => false);
      else
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          backgroundColor: Colors.white,
          content: Text(
            'Error! Please Try Again Later...',
            style: TextStyle(
                color: Colors.amber,
                fontFamily: GoogleFonts
                    .montserrat()
                    .fontFamily),
          ),
        ));
    });
  }

  afterSignUpFailed(){
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      backgroundColor: Colors.white,
      content: Text(
        'Error while Signing up!',
        style: TextStyle(
            color: Colors.amber,
            fontFamily: GoogleFonts.montserrat().fontFamily),
      ),
    ));
  }
}
