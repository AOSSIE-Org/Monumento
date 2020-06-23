import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:monumento/explore_screen.dart';
import 'package:monumento/utils/popular_carousel.dart';

class HomeScreen extends StatefulWidget {
  final FirebaseUser user;
  HomeScreen({this.user});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int _currentTab = 0;
  final _key = GlobalKey<ScaffoldState>();
  List<IconData> _icons = [
    Icons.airplanemode_active,
    Icons.hotel,
    Icons.directions_walk,
    Icons.directions_bike,
  ];

  Widget _buildIcon(int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        height: 60.0,
        width: 60.0,
        decoration: BoxDecoration(
          color: _selectedIndex == index ? Colors.amber : Colors.white,
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Icon(_icons[index],
            size: 25.0,
            color: _selectedIndex == index ? Colors.white : Colors.amber),
      ),
    );
  }

  List<DocumentSnapshot> popMonumentDocs = new List();

  Future getPopularMonuments() async {
    await Firestore.instance
        .collection('popular_monuments')
        .getDocuments()
        .then((docs) {
      popMonumentDocs = docs.documents;
    });
  }

  @override
  void initState() {
    super.initState();
    getPopularMonuments().whenComplete(() {
      setState(() {
        print('Popular Monuments Received!');
      });
    });
  }

  void changeScreen(int tabIndex){
    setState(() {
      _currentTab = tabIndex;
    });
  }

  static const platform = const MethodChannel("monument_detector");

  _navToMonumentDetector() async {
    try {
      await platform.invokeMethod("navMonumentDetector");
    } on PlatformException catch (e) {
      print("Failed to navigate to Monument Detector: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      body: _currentTab == 1?
          ExploreScreen(monumentList: popMonumentDocs,)
      :
      SafeArea(
        child: Stack(
          children: <Widget>[
            ListView(
              padding: EdgeInsets.symmetric(vertical: 30.0),
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 20.0, right: 120.0),
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
                  popMonumentDocs: popMonumentDocs,
                  changeTab: changeScreen,
                ),
                SizedBox(height: 20.0),
                PopularMonumentsCarousel(
                  popMonumentDocs: popMonumentDocs,
                ),
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
                    child: Icon(Icons.account_balance, color: Colors.white),
                  )),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
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
            title: Text('Home', style: TextStyle(color: Colors.amber)),
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
            title: Text('Popular', style: TextStyle(color: Colors.amber)),
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
            title: Text('Bookmarks', style: TextStyle(color: Colors.amber)),
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
            title: Text('Profile', style: TextStyle(color: Colors.amber)),
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
}
