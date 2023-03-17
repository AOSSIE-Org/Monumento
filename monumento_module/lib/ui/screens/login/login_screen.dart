import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monumento/blocs/authentication/authentication_bloc.dart';
import 'package:monumento/blocs/login_register/login_register_bloc.dart';
import 'package:monumento/navigation/arguments.dart';
import 'package:monumento/resources/authentication/models/user_model.dart';
import 'package:monumento/ui/screens/home/home_screen.dart';
import 'package:monumento/ui/screens/signup/register_screen.dart';
import 'package:monumento/utilities/constants.dart';
import 'package:monumento/utilities/utils.dart';

import '../profile_form/profile_form_screen.dart';

class LoginScreen extends StatefulWidget {
  static String route = "/loginScreen";

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _rememberMe = false;
  var _emailController = TextEditingController();
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
            //TODO: Email Validation
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
            //TODO: Password Validation
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
                  !isseen ? Icons.visibility_off : Icons.visibility,
                  color: Theme.of(context).primaryColorDark,
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

  Widget _buildForgotPasswordBtn() {
    return Container(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        onPressed: () => print('Forgot Password Button Pressed'),
        child: Text(
          'Forgot Password?',
          style: kLabelStyleAmber,
        ),
      ),
    );
  }

  Widget _buildRememberMeCheckbox() {
    return Container(
      height: 20.0,
      child: Row(
        children: <Widget>[
          Theme(
            data: ThemeData(unselectedWidgetColor: Colors.amber),
            child: Checkbox(
              value: _rememberMe,
              checkColor: Colors.white,
              activeColor: Colors.amber,
              onChanged: (value) {
                setState(() {
                  _rememberMe = value;
                });
              },
            ),
          ),
          Text(
            'Remember me',
            style: kLabelStyleAmber,
          ),
        ],
      ),
    );
  }

  Widget _buildLoginBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          print('Login Button Pressed');
          _loginRegisterBloc.add(LoginWithEmailPressed(
              email: _emailController.text,
              password: _passwordController.text));
        },
        child: Text(
          'LOGIN',
          style: TextStyle(
            color: Colors.white,
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSignInWithText() {
    return Column(
      children: <Widget>[
        Text(
          '- OR -',
          style: TextStyle(
            color: Colors.amber,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }


  Widget _buildSocialBtn() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30.0),
      child: GestureDetector(
        onTap: () {}, // Image tapped
        child: Image.asset(
          'assets/google.png',
          fit: BoxFit.cover, // Fixes border issues
          width: 30.0,
          height: 30.0,
        ),
      )
    );
  }

  Widget _buildSignupBtn() {
    return GestureDetector(
      onTap: () {
        if (isseen)
          setState(() {
            isseen = !isseen;
          });
        print('Sign Up Button Pressed');
        Navigator.pushNamed(context, SignUpScreen.route);
      },
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Don\'t have an Account? ',
              style: TextStyle(
                color: Colors.amber,
                fontSize: 16.0,
                fontFamily: GoogleFonts.montserrat().fontFamily,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextSpan(
              text: 'Sign Up',
              style: TextStyle(
                color: Colors.amber,
                fontSize: 16.0,
                fontFamily: GoogleFonts.montserrat().fontFamily,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginRegisterBloc, LoginRegisterState>(
        listener: (context, state) {
      if (state is LoginSuccess) {
        afterSuccessfulLogin(state.user);
      } else if (state is LoginFailed) {
        afterLoginFailed();
      } else if (state is SigninWithGoogleSuccess) {
        afterSuccessfulGoogleSignin(state);
      }
    }, builder: (context, state) {
      return IgnorePointer(
        ignoring: state is LoginRegisterLoading,
        child: Scaffold(
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
                  ),
                  Center(
                      child: new Container(
                    height: double.infinity,
                    child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: 40.0,
                        vertical: 60.0,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(height: 30.0),
                          Image.asset(
                            'assets/monumento.png',
                            height: 110.0,
                            width: 110.0,
                          ),
                          SizedBox(height: 30.0),
                          Container(
                              width: double.infinity,
                              child: Text(
                                'Sign In',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontSize: 35.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              )),
                          SizedBox(height: 30.0),
                          _buildEmailTF(),
                          SizedBox(
                            height: 15.0,
                          ),
                          _buildPasswordTF(),
                          _buildForgotPasswordBtn(),
                          _buildRememberMeCheckbox(),
                          _buildLoginBtn(),
                          _buildSignInWithText(),
                          _buildSocialBtn(),
                          _buildSignupBtn(),
                        ],
                      ),
                    ),
                  )),
                  state is LoginRegisterLoading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  afterSuccessfulGoogleSignin(SigninWithGoogleSuccess state) {
    state.isNewUser
        ? Navigator.pushNamedAndRemoveUntil(
            context, ProfileFormScreen.route, (route) => false,
            arguments: ProfileFormScreenArguments(
                email: state.user.email,
                name: state.user.name,
                uid: state.user.uid))
        : Navigator.pushNamedAndRemoveUntil(
            context, HomeScreen.route, (Route<dynamic> route) => false,
            arguments: HomeScreenArguments(
              user: state.user,
            ));
  }

  afterSuccessfulLogin(UserModel user) {
    if (isseen)
      setState(() {
        isseen = !isseen;
      });
    showSnackBar(context: context, text: 'Signing in...Please wait!');

    Navigator.pushNamedAndRemoveUntil(
        context, HomeScreen.route, (Route<dynamic> route) => false,
        arguments: HomeScreenArguments(user: user));
  }

  afterLoginFailed() {
    if (isseen)
      setState(() {
        isseen = !isseen;
      });
    showSnackBar(
      context: context,
      text: 'Sign In Failed! Please try again later..',
    );
  }
}
