import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:monumento/navigation/arguments.dart';
import 'package:monumento/resources/authentication/models/user_model.dart';
import 'package:monumento/resources/monuments/models/monument_model.dart';
import 'package:monumento/ui/screens/monument_detail/detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  final UserModel user;
  final List<MonumentModel> monumentList;
  static final route = '/exploreScreen';

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
                Navigator.pushNamed(context, DetailScreen.route,
                    arguments: DetailScreenArguments(
                      monument: widget.monumentList[index],
                      user: widget.user,
                      isBookmarked: false,
                    ));
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
                          tag: widget.monumentList[index].name,
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.2,
                            width: MediaQuery.of(context).size.width * 0.3,
                            decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20.0),
                                    bottomLeft: Radius.circular(20.0)),
                                image: DecorationImage(
                                    image: NetworkImage(
                                        widget.monumentList[index].image_1x1_),
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
                              widget.monumentList[index].name,
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Container(
                              child: Text(
                                widget.monumentList[index].city +
                                    ', ' +
                                    widget.monumentList[index].country,
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
