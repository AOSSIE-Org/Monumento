import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:monumento/blocs/authentication/authentication_bloc.dart';
import 'package:monumento/blocs/login_register/login_register_bloc.dart';
import 'package:monumento/navigation/arguments.dart';
import 'package:monumento/resources/authentication/models/user_model.dart';
import 'package:monumento/ui/widgets/image_picker.dart';
import 'package:monumento/utilities/constants.dart';
import 'package:monumento/utilities/utils.dart';

import '../home/home_screen.dart';

class SignUpScreen extends StatefulWidget {
  static String route = "/signupScreen";

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  var _emailController = TextEditingController();
  var _nameController = TextEditingController();
  var _statusController = TextEditingController();
  var _passwordController = TextEditingController();
  var _usernameController = TextEditingController();
  File _pickedImage;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isseen = false;

  AuthenticationBloc _authenticationBloc;
  LoginRegisterBloc _loginRegisterBloc;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    isseen = false;
    _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
    _loginRegisterBloc = BlocProvider.of<LoginRegisterBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginRegisterBloc, LoginRegisterState>(
        listener: (_, state) {
      if (state is SignUpSuccess) {
        afterSignUpSuccess(state.user);
      } else if (state is SignUpFailed) {
        afterSignUpFailed(message: state.message);
      }
    }, builder: (_, state) {
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
                      color: Colors.white,
                    ),
                    Container(
                      height: double.infinity,
                      child: SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.only(
                            left: 40.0, right: 40.0, bottom: 110.0, top: 60.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontSize: 35.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 16.0),
                              _buildProfilePictureWidget(),
                              SizedBox(height: 16.0),
                              _buildNameTF(),
                              SizedBox(height: 16.0),
                              _buildStatusTF(),
                              SizedBox(height: 16.0),
                              _buildUsernameTF(),
                              SizedBox(height: 16.0),
                              _buildEmailTF(),
                              SizedBox(
                                height: 16.0,
                              ),
                              _buildPasswordTF(),
                              SizedBox(
                                height: 24.0,
                              ),
                              _buildSignUpBtn(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    state is LoginRegisterLoading
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : Container(),
                  ],
                ),
              ),
            ),
          ));
    });
  }

  Widget _buildUsernameTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Username',
          style: kLabelStyleAmber,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextFormField(
            validator: (val) {
              if (val.isNotEmpty) {
                return null;
              }
              return "Enter a valid username";
            },
            keyboardType: TextInputType.emailAddress,
            controller: _usernameController,
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
              hintText: 'Enter your username',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Email',
          style: kLabelStyleAmber,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextFormField(
            validator: (val) {
              if (EmailValidator.validate(val)) {
                return null;
              }
              return "Enter a valid email";
            },
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
          style: kLabelStyleAmber,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextFormField(
            validator: (val) {
              if (val.isNotEmpty) {
                return null;
              }
              return "This field can't be empty";
            },
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
          style: kLabelStyleAmber,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextFormField(
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
          style: kLabelStyleAmber,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextFormField(
            validator: (val) {
              if (val.length >= 6) {
                return null;
              }
              return "Password should be at least 6 characters long";
            },
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

  Widget _buildSignUpBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState.validate()) {
            print('SignUp Button Pressed');
            _loginRegisterBloc.add(SignUpWithEmailPressed(
              profilePictureFile: _pickedImage,
              email: _emailController.text,
              password: _passwordController.text,
              name: _nameController.text,
              status: _statusController.text,
              username: _usernameController.text,
            ));
          }
        },
        child: Text(
          'REGISTER',
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

  afterSignUpSuccess(UserModel user) {
    showSnackBar(context: context, text: 'Signed up successfully');

    Navigator.pushNamedAndRemoveUntil(
        context, HomeScreen.route, (Route<dynamic> route) => false,
        arguments: HomeScreenArguments(user: user));
  }

  afterSignUpFailed({String message}) {
    showSnackBar(context: context, text: 'Sign up failed');
  }

  showImageSourceOptions() {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: EdgeInsets.zero,
              content: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                  Colors.amber,
                  Colors.amberAccent,
                ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                height: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    IconButton(
                      icon: FaIcon(
                        FontAwesomeIcons.camera,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        addImage(imageSource: ImageSource.camera);
                      },
                    ),
                    IconButton(
                      icon: FaIcon(
                        FontAwesomeIcons.image,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        addImage(imageSource: ImageSource.gallery);
                      },
                    )
                  ],
                ),
              ),
              elevation: 5,
            ));
  }

  addImage({ImageSource imageSource}) async {
    File image = await PickImage.takePicture(imageSource: imageSource);
    if (image != null) {
      File croppedImage =
          await PickImage.cropImage(image: image, ratioY: 1, ratioX: 1);
      if (croppedImage != null) {
        setState(() {
          imageCache.clear();
          imageCache.clearLiveImages();
          _pickedImage = croppedImage;
        });
      } else {
        showSnackBar(context: context, text: 'Something went wrong');
      }
    } else {
      showSnackBar(context: context, text: 'Something went wrong');
    }
  }

  Widget _buildProfilePictureWidget() {
    return _pickedImage != null
        ? Center(
            child: ClipOval(
              child: Image.file(
                _pickedImage,
                width: 70,
                height: 70,
                key: ValueKey(_pickedImage.lengthSync()),
              ),
            ),
          )
        : Center(
            child: GestureDetector(
              onTap: showImageSourceOptions,
              child: ClipOval(
                child: Icon(
                  Icons.linked_camera_outlined,
                  size: 70,
                  color: Colors.amber,
                ),
              ),
            ),
          );
  }
}
