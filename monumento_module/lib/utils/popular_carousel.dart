import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:monumento/detail_screen.dart';
import 'package:carousel_slider/carousel_slider.dart';

class PopularMonumentsCarousel extends StatelessWidget {
  final List<DocumentSnapshot> popMonumentDocs;
  final FirebaseUser user;
  final Function changeTab;
  PopularMonumentsCarousel({this.popMonumentDocs, this.user, this.changeTab});

  @override
  Widget build(BuildContext context) {
    final List<Widget> imageSliders = popMonumentDocs
        .map((item) => GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => DetailScreen(
                              monument: item,
                              user: user,
                              isBookMarked: false,
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
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: Text(
                                  item.data['name'] ?? 'Monument',
                                  style: TextStyle(
                                    fontSize: 21.0,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.2,
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
                            tag: item.data['name'] ?? 'monument',
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20.0),
                              child: Image(
                                height: 180.0,
                                width: 180.0,
                                image: NetworkImage(item.data['image']),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 10.0,
                            bottom: 10.0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  item.data['city'] ?? 'City',
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
                                      item.data['country'] ?? 'Country',
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
            ))
        .toList();
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Popular Monuments',
                style: TextStyle(
                  fontSize: 19.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () {
                  print('See All');
                  changeTab(1);
                },
                child: Text(
                  'See All',
          child: Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Popular Monuments',
                  style: TextStyle(
                    fontSize: 19.0,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                GestureDetector(
                  onTap: () {
                    print('See All');
                    changeTab(1);
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
        ),
        Container(
          height: 300.0,
          child: CarouselSlider(
            options: CarouselOptions(
                autoPlay: true,
                autoPlayCurve: Curves.easeIn,
                aspectRatio: 1.2,
                viewportFraction: .6,
                enlargeCenterPage: true,
                enlargeStrategy: CenterPageEnlargeStrategy.height),
            items: imageSliders,
          ),
        ),
      ],
    );
  }
}
