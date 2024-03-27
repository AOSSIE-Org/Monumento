import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:monumento/blocs/bookmarked_monuments/bookmarked_monuments_bloc.dart';
import 'package:monumento/navigation/arguments.dart';
import 'package:monumento/resources/authentication/models/user_model.dart';
import 'package:monumento/ui/screens/feed/feed_screen.dart';
import 'package:monumento/ui/screens/monumento/monumento_screen.dart';
import 'package:monumento/ui/screens/new_post/new_post_screen.dart';
import 'package:monumento/ui/screens/profile/profile_screen.dart';
import 'package:monumento/ui/widgets/image_picker.dart';

import '../discover/discover_screen.dart';

class HomeScreen extends StatefulWidget {
  final UserModel user;
  final int navBarIndex;
  static final String route = '/homeScreen';

  HomeScreen({this.user, this.navBarIndex = 0});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _key = GlobalKey<ScaffoldState>();

  List<Map<String, dynamic>> monumentMapList = new List();
  BookmarkedMonumentsBloc _bookmarkedMonumentsBloc;

  @override
  void initState() {
    super.initState();
    _bookmarkedMonumentsBloc =
        BlocProvider.of<BookmarkedMonumentsBloc>(context);
    String uid = widget.user.uid;
    _bookmarkedMonumentsBloc.add(RetrieveBookmarkedMonuments(userId: uid));
    _currentIndex = widget.navBarIndex;
  }

  FocusNode discoverNode = FocusNode();
  int _currentIndex = 0;

  void onTabTapped(int newIndex) {
    if (newIndex == 2) {
      newPostBottomSheet();
    } else {
      discoverNode.unfocus();
      setState(() {
        _currentIndex = newIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.white,
          key: _key,
          body: IndexedStack(
            children: [
              MonumentoScreen(
                user: widget.user,
              ),
              FeedScreen(),
              Container(),
              SearchScreen(
                node: discoverNode,
              ),
              ProfileScreen(
                user: widget.user,
              ),
            ],
            index: _currentIndex,
          ),
          bottomNavigationBar: BottomNavigationBar(
            onTap: onTabTapped,
            backgroundColor: Color(0xfffcfcfd),
            showSelectedLabels: false,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  label: '',
                  activeIcon: SvgPicture.asset(
                    'assets/home_icon.svg',
                    color: Theme.of(context).primaryColor,
                  ),
                  icon: SvgPicture.asset(
                    'assets/home_icon.svg',
                  )),
              BottomNavigationBarItem(
                  label: '',
                  icon: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: SvgPicture.asset('assets/feed_icon.svg'),
                  ),
                  activeIcon: Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: SvgPicture.asset('assets/feed_icon.svg',
                          color: Theme.of(context).primaryColor))),
              BottomNavigationBarItem(
                label: '',
                icon: Container(
                  width: 70,
                  height: 40,
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.15),
                            offset: Offset(0, -3),
                            blurRadius: 36)
                      ],
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [
                            Color(0xffFFD600),
                            Color(0xffFF0000),
                          ])),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ),
              ),
              BottomNavigationBarItem(
                  label: '',
                  icon: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: SvgPicture.asset('assets/discover_icon.svg')),
                  activeIcon: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: SvgPicture.asset('assets/discover_icon.svg',
                          color: Theme.of(context).primaryColor))),
              BottomNavigationBarItem(
                  label: '',
                  icon: SvgPicture.asset('assets/profile_icon.svg'),
                  activeIcon: SvgPicture.asset('assets/profile_icon.svg',
                      color: Theme.of(context).primaryColor)),
            ],
            currentIndex: _currentIndex,
            selectedItemColor: Colors.amber[800],
          )),
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
