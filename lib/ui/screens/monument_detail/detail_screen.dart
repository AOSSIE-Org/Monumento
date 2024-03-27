import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:monumento/resources/authentication/models/user_model.dart';
import 'package:monumento/resources/monuments/models/monument_model.dart';
import 'package:monumento/ui/screens/map/GoogleMap.dart';
import 'package:monumento/ui/widgets/feed_image_loading.dart';
import 'package:monumento/utilities/utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DetailScreen extends StatefulWidget {
  final MonumentModel monument;
  final UserModel user;
  bool isBookMarked;
  static final String route = '/detailScreen';
  DetailScreen({this.monument, this.user, this.isBookMarked});

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final _key = GlobalKey<ScaffoldState>();
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  Text _buildRatingStars(int rating) {
    String stars = '';
    for (int i = 0; i < rating; i++) {
      stars += '⭐ ';
    }
    stars.trim();
    return Text(stars);
  }

  num _stackToView;
  @override
  void initState() {
    super.initState();
    getBookMarkStatus();
    _stackToView = 1;
  }

  Future<bool> getBookMarkStatus() async {
    String collection = "bookmarks";
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection(collection)
        .where("uid", isEqualTo: widget.user.uid)
        .get();
    query.docs.forEach((element) {
      Map<String, dynamic> data = element.data();

      if (data['name'] == widget.monument.name &&
          data['country'] == widget.monument.country &&
          data['city'] == widget.monument.city)
        setState(() {
          widget.isBookMarked = true;
        });
      return true;
    });
    return false;
  }

  Future<void> _removeBookmark() async {
    String collection = "bookmarks";
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection(collection)
        .where("uid", isEqualTo: widget.user.uid)
        .get();
    query.docs.forEach((element) {
      Map<String, dynamic> data = element.data();

      if (data['name'] == widget.monument.name &&
          data['country'] == widget.monument.country &&
          data['city'] == widget.monument.city) {
        element.reference.delete();
      }
    });
    setState(() {
      widget.isBookMarked = false;
    });
  }

  void _handleLoad(String value) {
    setState(() {
      _stackToView = 0;
    });
  }

  static const platform = const MethodChannel("ar_fragment");

  _navToARFragment() async {
    List<Map<String, dynamic>> monumentMapList = new List();
    monumentMapList.add(widget.monument.toEntity().toMap());
    try {
      await platform
          .invokeMethod("navArFragment", {"monumentListMap": monumentMapList});
    } on PlatformException catch (e) {
      print("Failed to navigate to AR Fragment: '${e.message}'.");
    }
  }

  void _bookmark() async {
    await getBookMarkStatus();
    if (widget.isBookMarked) {
      String collection = "bookmarks";
      Map<String, dynamic> map = new Map();
      map["uid"] = widget.user.uid;
      map["name"] = widget.monument.name;
      map["image"] = widget.monument.imageUrl;
      map["wiki"] = widget.monument.wiki;
      map["country"] = widget.monument.country;
      map["city"] = widget.monument.city;

      DocumentReference documentReference =
          FirebaseFirestore.instance.collection(collection).doc();
      FirebaseFirestore.instance.runTransaction((transaction) async {
        await transaction.set(documentReference, map);
        // .catchError((e) {})
        setState(() {
          widget.isBookMarked = true;
        });
        print('Bookmarked!');
        showSnackBar(context: context, text: 'Monument Bookmarked!');
      }).catchError((e) {
        print(e.toString());
      });
    }
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
                  tag: widget.isBookMarked
                      ? widget.monument.wiki ?? 'monument-tag'
                      : widget.monument.name ?? 'monument',
                  child: ClipRRect(
                    // borderRadius: BorderRadius.only(
                    //     bottomLeft: Radius.circular(30),
                    //     bottomRight: Radius.circular(30)),
                    child: CachedNetworkImage(
                      imageUrl: widget.monument.image_1x1_,
                      fit: BoxFit.cover,
                      placeholder: (_, __) {
                        return FeedImageLoading();
                      },
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
                          color:
                              widget.isBookMarked ? Colors.amber : Colors.white,
                          tooltip: 'Bookmark',
                          onPressed: () async {
                            if (!widget.isBookMarked) {
                              await _bookmark();
                            } else
                              await _removeBookmark();
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.account_balance),
                          iconSize: 30.0,
                          color: Colors.amber,
                          tooltip: 'Visit in 3D AR',
                          onPressed: () async {
                            _navToARFragment();
                            // Navigator.of(context).push(
                            //   new MaterialPageRoute(
                            //     builder: (context) => DemoArScreen(),
                            //   ),
                            // );
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
                    Container(
                      width: MediaQuery.of(context).size.width * 0.75,
                      child: Text(
                        widget.monument.name,
                        maxLines: 3,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
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
                          widget.monument.city,
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
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(new MaterialPageRoute(
                        builder: (context) =>
                            GoogleMapPage(address: widget.monument.name)));
                  },
                  child: Icon(
                    Icons.location_on,
                    color: Colors.white70,
                    size: 25.0,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
              child: IndexedStack(
            index: _stackToView,
            children: [
              Column(
                children: <Widget>[
                  Expanded(
                      child: WebView(
                    javascriptMode: JavascriptMode.unrestricted,
                    initialUrl: widget.monument.wiki,
                    gestureNavigationEnabled: true,
                    onWebViewCreated: (WebViewController webViewController) {
                      _controller.complete(webViewController);
                    },
                    onPageFinished: _handleLoad,
                  )),
                ],
              ),
              Container(
                color: Colors.white,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }
}
