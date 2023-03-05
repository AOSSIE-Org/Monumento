import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:monumento/navigation/arguments.dart';
import 'package:monumento/resources/authentication/models/user_model.dart';
import 'package:monumento/resources/monuments/entities/bookmarked_monument_entity.dart';
import 'package:monumento/resources/monuments/models/bookmarked_monument_model.dart';

import '../monument_detail/detail_screen.dart';

class BookmarkScreen extends StatefulWidget {
  static final route = '/bookmarkScreen';
  final UserModel user;
  List<BookmarkedMonumentModel> monumentList;

  BookmarkScreen({this.user, this.monumentList});

  @override
  _BookmarkScreenState createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  Future<List<DocumentSnapshot>> getBookmarkedMonuments() async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('bookmarks')
        .where("uid", isEqualTo: widget.user.uid)
        .get();
    return query.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.0,
          title: Text(
            'Explore Bookmark Monuments',
            style: TextStyle(
                fontSize: 19.0,
                fontWeight: FontWeight.bold,
                color: Colors.amber),
          ),
        ),
        body: FutureBuilder<List<DocumentSnapshot>>(
            future: getBookmarkedMonuments(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return Center(child: CircularProgressIndicator());
              if (!snapshot.hasData || snapshot.data.length <= 0)
                return Container(
                  child: Center(
                      child: Text(
                    'No Bookmarks!',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 26.0),
                  )),
                );

              widget.monumentList = snapshot.data
                  .map((e) => BookmarkedMonumentModel.fromEntity(
                      BookmarkedMonumentEntity.fromSnapshot(e)))
                  .toList();
              return ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: widget.monumentList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, DetailScreen.route,
                              arguments: DetailScreenArguments(
                                monument:
                                    widget.monumentList[index].monumentModel,
                                user: widget.user,
                                isBookmarked: true,
                              ));
                        },
                        child: Card(
                            margin: EdgeInsets.all(15.0),
                            elevation: 10.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.2,
                                child: Row(children: <Widget>[
                                  Hero(
                                      tag: widget.monumentList[index]
                                              .monumentModel.wiki ??
                                          'monument-tag',
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.2,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        decoration: BoxDecoration(
                                            color: Colors.grey,
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(20.0),
                                                bottomLeft:
                                                    Radius.circular(20.0)),
                                            image: DecorationImage(
                                                image: NetworkImage(widget
                                                    .monumentList[index]
                                                    .monumentModel
                                                    .imageUrl),
                                                fit: BoxFit.cover)),
                                      )),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Expanded(
                                      child: Container(
                                          child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                        Text(
                                          widget.monumentList[index]
                                              .monumentModel.name,
                                          style: TextStyle(
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.w700),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.57,
                                          child: Text(
                                            widget.monumentList[index]
                                                    .monumentModel.city +
                                                ', ' +
                                                widget.monumentList[index]
                                                    .monumentModel.country,
                                            maxLines: 3,
                                            style: TextStyle(
                                              fontSize: 18.0,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Text(
                                              'Explore more',
                                              style: TextStyle(
                                                  color: Colors.amber,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(
                                              width: 6.0,
                                            ),
                                            Icon(
                                              Icons.chevron_right,
                                              color: Colors.amber,
                                            )
                                          ],
                                        ),
                                      ])))
                                ]))));
                  });
            }));
  }
}
