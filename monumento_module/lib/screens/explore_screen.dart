import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:monumento/screens/detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  final FirebaseUser user;
  final List<DocumentSnapshot> monumentList;

  ExploreScreen({this.user, this.monumentList});

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: Text(
          'Explore Popular Monuments',
          style: TextStyle(
              fontSize: 19.0, fontWeight: FontWeight.bold, color: Colors.amber),
        ),
      ),
      body: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: widget.monumentList.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => DetailScreen(
                              user: widget.user,
                              monument: widget.monumentList[index],
                              isBookMarked: false,
                            )));
              },
              child: Card(
                margin: EdgeInsets.all(15.0),
                elevation: 10.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.2,
                  child: Row(
                    children: <Widget>[
                      Hero(
                          tag: widget.monumentList[index].data['name'],
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.2,
                            width: MediaQuery.of(context).size.width * 0.3,
                            decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20.0),
                                    bottomLeft: Radius.circular(20.0)),
                                image: DecorationImage(
                                    image: NetworkImage(widget
                                        .monumentList[index].data['image']),
                                    fit: BoxFit.cover)),
                          )),
                      SizedBox(
                        width: 10.0,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              widget.monumentList[index].data['name'],
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Container(
                              child: Text(
                                widget.monumentList[index].data['city'] +
                                    ', ' +
                                    widget.monumentList[index].data['country'],
                                maxLines: 1,
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }
}
