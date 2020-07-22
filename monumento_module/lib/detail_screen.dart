import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DetailScreen extends StatefulWidget {
  final DocumentSnapshot monument;

  DetailScreen({this.monument});

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final _key = GlobalKey<ScaffoldState>();

  Text _buildRatingStars(int rating) {
    String stars = '';
    for (int i = 0; i < rating; i++) {
      stars += '⭐ ';
    }
    stars.trim();
    return Text(stars);
  }

  static const platform = const MethodChannel("ar_fragment");

  _navToARFragment() async {
    List<Map<String, dynamic>> monumentMapList = new List();
    monumentMapList.add(widget.monument.data);
    try {
      await platform.invokeMethod("navArFragment",
      {"monumentListMap":monumentMapList});
    } on PlatformException catch (e) {
      print("Failed to navigate to AR Fragment: '${e.message}'.");
    }
  }

  void _bookmark() async {
    String document = "user_id";
    String collection = "bookmarks";
    Map<String, dynamic> map = new Map();
    map["auth_id"] = "user_id";
    map["name"] = widget.monument.data['name'];
    map["image"] = widget.monument.data['image'];
    map["wiki"] = widget.monument.data['wiki'];
    map["country"] = widget.monument.data['country'];
    map["city"] = widget.monument.data['city'];

    DocumentReference documentReference = Firestore.instance.collection(collection).document();
    Firestore.instance.runTransaction((transaction) async {
      await transaction
          .set(documentReference, map)
          .catchError((e) {})
          .whenComplete(() {
            print('Bookmarked!');
            _key.currentState.showSnackBar(SnackBar(
              backgroundColor: Colors.amber,
              content: Text('Monument Bookmarked!',
              style: TextStyle(color: Colors.white),
              ),
            ));
      });
    }).catchError((e) {
      print(e.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      body: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0.0, 2.0),
                      blurRadius: 6.0,
                    ),
                  ],
                ),
                child: Hero(
                  tag: widget.monument.data['name'],
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30.0),
                    child: Image(
                      image: NetworkImage(widget.monument.data['image']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      iconSize: 30.0,
                      color: Colors.white,
                      onPressed: () => Navigator.pop(context),
                    ),
                    Row(
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.bookmark),
                          padding: EdgeInsets.only(right: 5.0),
                          iconSize: 30.0,
                          color: Colors.white,
                          tooltip: 'Bookmark',
                          onPressed: () {
                            _bookmark();
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.account_balance),
                          iconSize: 30.0,
                          color: Colors.amber,
                          tooltip: 'Visit in 3D AR',
                          onPressed: () async{
                            _navToARFragment();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 20.0,
                bottom: 20.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.monument.data['name'],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 35.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.location_city,
                          size: 15.0,
                          color: Colors.white,
                        ),
                        SizedBox(width: 5.0),
                        Text(
                          widget.monument.data['city'],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                          ),
                        ),
                        _buildRatingStars(5)
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 20.0,
                bottom: 20.0,
                child: Icon(
                  Icons.location_on,
                  color: Colors.white70,
                  size: 25.0,
                ),
              ),
            ],
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.5,
          child: WebView(
            initialUrl: widget.monument.data['wiki'],
            gestureNavigationEnabled: true,
          ),
          ),
        ],
      ),
    );
  }
}