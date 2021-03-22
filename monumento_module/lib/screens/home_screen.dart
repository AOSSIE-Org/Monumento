import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monumento/blocs/bookmarked_monuments/bookmarked_monuments_bloc.dart';
import 'package:monumento/blocs/popular_monuments/popular_monuments_bloc.dart';
import 'package:monumento/blocs/profile/profile_bloc.dart';
import 'package:monumento/screens/bookmark_screen.dart';
import 'package:monumento/screens/explore_screen.dart';
import 'package:monumento/screens/profile_screen.dart';
import 'package:monumento/utils/bookmark_carousel.dart';
import 'package:monumento/utils/popular_carousel.dart';

class HomeScreen extends StatefulWidget {
  final FirebaseUser user;

  HomeScreen({this.user});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0;
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

  void changeScreen(int tabIndex) {
    setState(() {
      _currentTab = tabIndex;
    });
  }

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
    return Scaffold(
      key: _key,
      body: _currentTab == 1
          ? BlocBuilder<PopularMonumentsBloc, PopularMonumentsState>(
              builder: (context, state) {
              if (state is PopularMonumentsRetrieved) {
                return ExploreScreen(
                  user: widget.user,
                  monumentList: state.popularMonuments,
                );
              }
              return _buildCenterLoadingIndicator();
            })
          : _currentTab == 2
              ? BlocBuilder<BookmarkedMonumentsBloc, BookmarkedMonumentsState>(
                  builder: (context, state) {
                  if (state is BookmarkedMonumentsRetrieved) {
                    return BookmarkScreen(
                      user: widget.user,
                      monumentList: state.bookmarkedMonuments,
                    );
                  }
                  return _buildCenterLoadingIndicator();
                })
              : _currentTab == 3
                  ? BlocBuilder<ProfileBloc, ProfileState>(
                      builder: (context, profileState) {
                      return BlocBuilder<BookmarkedMonumentsBloc,
                              BookmarkedMonumentsState>(
                          builder: (context, bookmarkState) {
                        if (profileState is ProfileDataRetrieved &&
                            bookmarkState is BookmarkedMonumentsRetrieved) {
                          return UserProfilePage(
                            user: widget.user,
                            profileSnapshot: profileState.profileDoc,
                            bookmarkedMonuments:
                                bookmarkState.bookmarkedMonuments,
                          );
                        }
                        return _buildCenterLoadingIndicator();
                      });
                    })
                  : BlocBuilder<PopularMonumentsBloc, PopularMonumentsState>(
                      builder: (context, popularMonumentsState) {
                      if (popularMonumentsState is PopularMonumentsRetrieved) {
                        for (DocumentSnapshot doc
                            in popularMonumentsState.popularMonuments) {
                          monumentMapList.add(doc.data);
                        }
                      }

                      return SafeArea(
                        child: (popularMonumentsState
                                is! PopularMonumentsRetrieved)
                            ? _buildCenterLoadingIndicator()
                            : Stack(
                                children: <Widget>[
                                  ListView(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 30.0),
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 20.0, right: 120.0),
                                        child: Text(
                                          'Monumento',
                                          style: TextStyle(
                                            fontSize: 28.0,
                                            color: Colors.amber,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 20.0),
                                      PopularMonumentsCarousel(
                                        popMonumentDocs: (popularMonumentsState
                                                as PopularMonumentsRetrieved)
                                            .popularMonuments,
                                        user: widget.user,
                                        changeTab: changeScreen,
                                      ),
                                      SizedBox(height: 20.0),
                                      BlocBuilder<BookmarkedMonumentsBloc,
                                              BookmarkedMonumentsState>(
                                          builder: (context, state) {
                                        if (state
                                            is BookmarkedMonumentsRetrieved) {
                                          print("bookmarksrec");
                                          return BookmarkCarousel(
                                            bookmarkedMonumentDocs:
                                                state.bookmarkedMonuments,
                                            changeTab: changeScreen,
                                          );
                                        }

                                        return SizedBox.shrink();
                                      })
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Align(
                                        alignment: Alignment.bottomRight,
                                        child: FloatingActionButton(
                                          onPressed: () async {
                                            _navToMonumentDetector();
                                          },
                                          backgroundColor: Colors.amber,
                                          child: Icon(Icons.account_balance,
                                              color: Colors.white),
                                        )),
                                  )
                                ],
                              ),
                      );
                    }),
      bottomNavigationBar: BottomNavigationBar(
        selectedLabelStyle: TextStyle(color: Colors.amber),
        currentIndex: _currentTab,
        elevation: 10.0,
        selectedItemColor: Colors.amber,
        onTap: (int value) {
          setState(() {
            _currentTab = value;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              size: 30.0,
              color: Colors.grey,
            ),
            label: 'Home',
            activeIcon: Icon(
              Icons.home,
              size: 35.0,
              color: Colors.amber,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.apps,
              size: 30.0,
              color: Colors.grey,
            ),
            label: 'Popular',
            activeIcon: Icon(
              Icons.apps,
              size: 35.0,
              color: Colors.amber,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.bookmark,
              size: 30.0,
              color: Colors.grey,
            ),
            label: 'Bookmarks',
            activeIcon: Icon(
              Icons.bookmark,
              size: 35.0,
              color: Colors.amber,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person_outline,
              size: 30.0,
              color: Colors.grey,
            ),
            label: 'Profile',
            activeIcon: Icon(
              Icons.person_outline,
              size: 35.0,
              color: Colors.amber,
            ),
          ),
        ],
      ),
    );
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
