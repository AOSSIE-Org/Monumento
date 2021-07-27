import 'dart:io';

import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:monumento/blocs/bookmarked_monuments/bookmarked_monuments_bloc.dart';
import 'package:monumento/blocs/profile/profile_bloc.dart';
import 'package:monumento/navigation/arguments.dart';
import 'package:monumento/resources/authentication/models/user_model.dart';
import 'package:monumento/screens/feed/feed_screen.dart';
import 'package:monumento/screens/monumento/monumento_screen.dart';
import 'package:monumento/screens/new_post/new_post_screen.dart';
import 'package:monumento/screens/profile/profile_screen.dart';
import 'package:monumento/utils/image_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'discover/discover_screen.dart';

class HomeScreen extends StatefulWidget {
  final UserModel user;

  HomeScreen({this.user});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _key = GlobalKey<ScaffoldState>();

  List<Map<String, dynamic>> monumentMapList = new List();
  ProfileBloc _profileBloc;
  BookmarkedMonumentsBloc _bookmarkedMonumentsBloc;

  @override
  void initState() {
    super.initState();
    _profileBloc = BlocProvider.of<ProfileBloc>(context);
    _bookmarkedMonumentsBloc =
        BlocProvider.of<BookmarkedMonumentsBloc>(context);
    String uid = widget.user.uid;
    _bookmarkedMonumentsBloc.add(RetrieveBookmarkedMonuments(userId: uid));
    _profileBloc.add(GetProfileData(userId: uid));
  }

  int _currentIndex = 0;

  void onTabTapped(int newIndex) {
    if (newIndex == 2) {
      newPostBottomSheet();
    } else {
      setState(() {
        _currentIndex = newIndex;
      });
    }
  }

  List<Widget> screens = [
    FeedScreen(),
    SearchScreen(),
    ProfileScreen(),
    ProfileScreen(),
    ProfileScreen()
  ];
  static const platform = const MethodChannel("monument_detector");

  _navToMonumentDetector() async {
    try {
      await platform.invokeMethod(
          "navMonumentDetector", {"monumentsList": monumentMapList});
    } on PlatformException catch (e) {
      print("Failed to navigate to Monument Detector: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        key: _key,
        body: [
          MonumentoScreen(
            user: widget.user,
          ),
          SearchScreen(),
          FeedScreen(),
          ProfileScreen(
            user: widget.user,
          ),
        ][_currentIndex],
        bottomNavigationBar: ConvexAppBar(
          onTap: onTabTapped,
          initialActiveIndex: _currentIndex,
          backgroundColor: Color(0xfffcfcfd),
          style: TabStyle.fixedCircle,
          color: Theme.of(context).primaryColor,
          activeColor: Theme.of(context).primaryColor,
          items: [
            TabItem(
              activeIcon: Icon(
                Icons.home,
                color: Theme.of(context).primaryColor,
              ),
              icon: Icon(
                Icons.home,
                color: Colors.grey,
              ),
            ),
            TabItem(
                icon: Icon(
                  Icons.search,
                  color: Colors.grey,
                ),
                activeIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).primaryColor,
                )),
            TabItem(
              icon: Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
            TabItem(
                icon: Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.grey,
                ),
                activeIcon: Icon(
                  Icons.chat_bubble_outline,
                  color: Theme.of(context).primaryColor,
                )),
            TabItem(
                icon: FaIcon(
                  FontAwesomeIcons.bell,
                  color: Colors.grey,
                ),
                activeIcon: FaIcon(
                  FontAwesomeIcons.bell,
                  color: Theme.of(context).primaryColor,
                )),
          ],
        ),
      ),
    );
  }

  newPostBottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (_) {
          return Container(
            padding: EdgeInsets.all(16),
            height: 150,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "New Post",
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Column(
                      children: [
                        IconButton(
                            iconSize: 60,
                            icon: FaIcon(
                              FontAwesomeIcons.camera,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              Navigator.pop(context);

                              newPostPickImage(ImageSource.camera);
                            }),
                        Text("Camera")
                      ],
                    ),
                    Column(
                      children: [
                        IconButton(
                            iconSize: 60,
                            icon: FaIcon(
                              FontAwesomeIcons.image,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              newPostPickImage(ImageSource.gallery);
                            }),
                        Text("Gallery")
                      ],
                    )
                  ],
                ),
              ],
            ),
          );
        });
  }

  Future newPostPickImage(ImageSource source) async {
    File image = await PickImage.takePicture(imageSource: source);
    File croppedImage =
        await PickImage.cropImage(image: image, ratioX: 1, ratioY: 1);
    Navigator.of(context).pushNamed(NewPostScreen.route,
        arguments: NewPostScreenArguments(pickedImage: croppedImage));
  }

  Widget _buildCenterLoadingIndicator() {
    return Center(
      child: Container(
        height: 50.0,
        width: 50.0,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
        ),
      ),
    );
  }
}
