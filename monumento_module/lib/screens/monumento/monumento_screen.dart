import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monumento/blocs/popular_monuments/popular_monuments_bloc.dart';
import 'package:monumento/constants.dart';
import 'package:monumento/navigation/arguments.dart';
import 'package:monumento/resources/authentication/models/user_model.dart';
import 'package:monumento/resources/monuments/models/monument_model.dart';
import 'package:monumento/screens/detail_screen.dart';
import 'package:monumento/utils/custom_app_bar.dart';

class MonumentoScreen extends StatefulWidget {
  const MonumentoScreen({Key key, @required this.user}) : super(key: key);
  final UserModel user;

  @override
  _MonumentoScreenState createState() => _MonumentoScreenState();
}

class _MonumentoScreenState extends State<MonumentoScreen> {
  static const platform = const MethodChannel("monument_detector");
  List<Map<String, dynamic>> monumentMapList = new List();

  _navToMonumentDetector() async {
    try {
      await platform.invokeMethod(
          "navMonumentDetector", {"monumentsList": monumentMapList});
    } on PlatformException catch (e) {
      print("Failed to navigate to Monument Detector: '${e.message}'.");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PopularMonumentsBloc, PopularMonumentsState>(
      builder: (context, state) {
        if (state is PopularMonumentsRetrieved) {
          print(state.toString() + 'asdasd');
          for (MonumentModel monument in state.popularMonuments) {
            monumentMapList.add(monument.toEntity().toMap());
          }
          return CustomScrollView(
            slivers: [
              SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  sliver: CustomAppBar(
                      title: 'Monumento',
                      textStyle: kStyle28W600.copyWith(
                          color: Color.fromRGBO(255, 214, 0, 1)))),
              SliverToBoxAdapter(
                child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    width: MediaQuery.of(context).size.width,
                    child: TextButton.icon(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            side: BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                      label: Text(
                        'Detect Monuments',
                        style: kStyle16W500.copyWith(color: Colors.black),
                      ),
                      icon: Icon(
                        Icons.map,
                        color: Colors.black,
                      ),
                      onPressed: () {},
                    )),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Text(
                        'Popular Monuments',
                        style: kStyle20W600,
                      ),
                      Spacer(),
                      TextButton(
                          onPressed: () {},
                          child: Text(
                            'See all',
                            style: kStyle14W600.copyWith(
                                color: Color.fromRGBO(90, 90, 90, 1)),
                          ))
                    ],
                  ),
                ),
              ),
              SliverList(
                  delegate: SliverChildBuilderDelegate((_, index) {
                return PopularMonumentTile(
                  monument: state.popularMonuments[index],
                  user: widget.user,
                );
              }, childCount: state.popularMonuments.length))
            ],
          );
        }
        if (state is LoadingPopularMonuments) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

class PopularMonumentTile extends StatelessWidget {
  const PopularMonumentTile(
      {Key key, @required this.monument, @required this.user})
      : super(key: key);
  final MonumentModel monument;
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, DetailScreen.route,
          arguments: DetailScreenArguments(
              monument: monument, user: user, isBookmarked: false)),
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CachedNetworkImage(
            imageUrl: monument.imageUrl,
            imageBuilder: (context, imageProvider) => Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  image:
                      DecorationImage(image: imageProvider, fit: BoxFit.fill)),
              height: 120,
              width: MediaQuery.of(context).size.width,
              child: Align(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    monument.name,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                alignment: Alignment.bottomLeft,
              ),
            ),
            placeholder: (context, url) => Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.blueGrey,
              ),
              height: 120,
            ),
            errorWidget: (context, url, error) => Icon(Icons.error),
          )),
    );
  }
}
