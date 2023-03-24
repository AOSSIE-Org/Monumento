import 'package:flutter/material.dart';
import 'package:monumento/resources/monuments/models/bookmarked_monument_model.dart';

import '../screens/monument_detail/detail_screen.dart';

class BookmarkCarousel extends StatelessWidget {
  final List<BookmarkedMonumentModel> bookmarkedMonumentDocs;
  final Function changeTab;
  BookmarkCarousel({this.bookmarkedMonumentDocs, this.changeTab});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Text(
                  'Bookmarked Monuments',
                  style: TextStyle(
                    fontSize: 19.0,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: () {
                  print('See All');
                  changeTab(2);
                },
                child: Text(
                  'See All',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ),
        bookmarkedMonumentDocs.length == 0
            ? Container(
                child: Center(
                    child: Container(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.1),
                  child: Text(
                    'No Bookmarks!',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 26.0),
                  ),
                )),
              )
            : Container(
                height: 300.0,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: bookmarkedMonumentDocs.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => DetailScreen(
                                      monument: bookmarkedMonumentDocs[index]
                                          .monumentModel,
                                      isBookMarked: true,
                                    )));
                      },
                      child: Container(
                        margin: EdgeInsets.all(10.0),
                        width: 210.0,
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: <Widget>[
                            Positioned(
                              bottom: 15.0,
                              child: Container(
                                height: 120.0,
                                width: 200.0,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      offset: Offset(0.0, 2.0),
                                      blurRadius: 6.0,
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 20.0),
                                        child: FittedBox(
                                          child: Text(
                                            bookmarkedMonumentDocs[index]
                                                    .monumentModel
                                                    .name ??
                                                'Monument',
                                            style: TextStyle(
                                              fontSize: 21.0,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 1.2,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'Tap to Explore',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.amber,
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    offset: Offset(0.0, 2.0),
                                    blurRadius: 6.0,
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: <Widget>[
                                  Hero(
                                    tag: bookmarkedMonumentDocs[index]
                                            .monumentModel
                                            .wiki ??
                                        'monument-tag',
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20.0),
                                      child: Image(
                                        height: 180.0,
                                        width: 180.0,
                                        image: NetworkImage(
                                            bookmarkedMonumentDocs[index]
                                                .monumentModel
                                                .imageUrl),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 10.0,
                                    bottom: 10.0,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          bookmarkedMonumentDocs[index]
                                                  .monumentModel
                                                  .city ??
                                              'City',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 24.0,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Icon(
                                              Icons.location_on,
                                              size: 10.0,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 5.0),
                                            Text(
                                              bookmarkedMonumentDocs[index]
                                                      .monumentModel
                                                      .country ??
                                                  'Country',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }
}
