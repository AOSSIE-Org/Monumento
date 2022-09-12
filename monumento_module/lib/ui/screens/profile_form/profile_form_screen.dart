import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:monumento/blocs/authentication/authentication_bloc.dart';
import 'package:monumento/blocs/profile_form/profile_form_bloc.dart';
import 'package:monumento/navigation/arguments.dart';
import 'package:monumento/resources/authentication/authentication_repository.dart';
import 'package:monumento/resources/authentication/models/user_model.dart';
import 'package:monumento/resources/social/social_repository.dart';
import 'package:monumento/ui/screens/home/home_screen.dart';
import 'package:monumento/ui/widgets/image_picker.dart';
import 'package:monumento/utilities/constants.dart';
import 'package:monumento/utilities/utils.dart';

class ProfileFormScreen extends StatefulWidget {
  static final String route = "/profileFormScreen";

  final String email;
  final String name;
  final String uid;

  @override
  _ProfileFormScreenState createState() => _ProfileFormScreenState();

  const ProfileFormScreen(
      {@required this.email, @required this.name, @required this.uid});
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  var _emailController = TextEditingController();
  var _nameController = TextEditingController();
  var _statusController = TextEditingController();
  var _usernameController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  File _pickedImage;
  final _formKey = GlobalKey<FormState>();
  ProfileFormBloc _profileFormBloc;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email;
    _nameController.text = widget.name;
    _profileFormBloc = ProfileFormBloc(
        authenticationBloc: BlocProvider.of<AuthenticationBloc>(context),
        authenticationRepository:
            RepositoryProvider.of<AuthenticationRepository>(context),
        socialRepository: RepositoryProvider.of<SocialRepository>(context));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileFormBloc, ProfileFormState>(
        bloc: _profileFormBloc,
        listener: (_, state) {
          if (state is ProfileCreated) {
            afterProfileCreationSuccess((state).user);
          } else if (state is ProfileFormError) {
            print("listener called");
            afterProfileCreationFailed(state.message);
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
                              left: 40.0,
                              right: 40.0,
                              bottom: 110.0,
                              top: 60.0),
                          child: Form(
                            key: _formKey,
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
                                _buildProfilePictureWidget(),
                                SizedBox(height: 30.0),
                                _buildNameTF(),
                                SizedBox(height: 30.0),
                                _buildStatusTF(),
                                SizedBox(height: 30.0),
                                _buildEmailTF(),
                                SizedBox(
                                  height: 30.0,
                                ),
                                _buildUsernameTF(),
                                SizedBox(
                                  height: 24.0,
                                ),
                                _buildCreateProfileBtn(),
                              ],
                            ),
                          )),
                    ),
                    state is ProfileFormLoading
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : Container()
                  ],
                ),
              ),
            ),
          );
        });
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
            enabled: false,
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
                  color: Colors.white,
                ),
              ),
            ),
          );
  }

  Widget _buildUsernameTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Username',
          style: kLabelStyle,
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

  Widget _buildCreateProfileBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child:ElevatedButton  (
        onPressed: () {
          if (_formKey.currentState.validate()) {
            showSnackBar(
                context: context, text: 'Creating profile. Please Wait.');

            _profileFormBloc.add(CreateUserDoc(
              profilePictureFile: _pickedImage,
              email: _emailController.text,
              username: _usernameController.text,
              status: _statusController.text,
              name: _nameController.text,
              uid: widget.uid,
            ));
          }
        },
        child: Text(
          'Create Profile',
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

  afterProfileCreationSuccess(UserModel user) {
    showSnackBar(
      context: context,
      text: 'Signing Up! Please wait...',
    );

    Navigator.pushNamedAndRemoveUntil(
        context, HomeScreen.route, (route) => false,
        arguments: HomeScreenArguments(user: user));
  }

  afterProfileCreationFailed(String message) {
    showSnackBar(context: context, text: message);
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
}
