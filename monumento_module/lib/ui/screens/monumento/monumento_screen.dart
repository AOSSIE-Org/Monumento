import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monumento/blocs/popular_monuments/popular_monuments_bloc.dart';
import 'package:monumento/resources/monuments/monument_repository.dart';
import 'package:monumento/ui/screens/monumento/components/popular_monuments_tile.dart';
import 'package:monumento/utilities/constants.dart';
import 'package:monumento/navigation/arguments.dart';
import 'package:monumento/resources/authentication/models/user_model.dart';
import 'package:monumento/resources/monuments/models/monument_model.dart';
import 'package:monumento/ui/screens/explore_monuments/explore_screen.dart';
import 'package:monumento/ui/widgets/custom_app_bar.dart';

class MonumentoScreen extends StatefulWidget {
  const MonumentoScreen({Key key, @required this.user}) : super(key: key);
  final UserModel user;

  @override
  _MonumentoScreenState createState() => _MonumentoScreenState();
}

class _MonumentoScreenState extends State<MonumentoScreen> {
  static const platform = const MethodChannel("monument_detector");
  List<Map<String, dynamic>> monumentMapList = new List();
  PopularMonumentsBloc _popularMonumentsBloc;

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
    _popularMonumentsBloc = PopularMonumentsBloc(
        firebaseMonumentRepository:
            RepositoryProvider.of<MonumentRepository>(context));
    _popularMonumentsBloc.add(GetPopularMonuments());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PopularMonumentsBloc, PopularMonumentsState>(
      bloc: _popularMonumentsBloc,
      builder: (context, state) {
        if (state is PopularMonumentsRetrieved) {
          print(state.toString());
          for (MonumentModel monument in state.popularMonuments) {
            monumentMapList.add(monument.toEntity().toMap());
          }
          return CustomScrollView(
            slivers: [
              SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  sliver: CustomAppBar(
                      title: 'Monumento',
                      textStyle: kStyle28W700.copyWith(
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
                      onPressed: _navToMonumentDetector,
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
                          onPressed: () {
                            Navigator.pushNamed(context, ExploreScreen.route,
                                arguments: ExploreScreenArguments(
                                    user: widget.user,
                                    monumentList: state.popularMonuments));
                          },
                          child: Text(
                            'See all',
                            style: kStyle14W600.copyWith(
                                color: Color.fromRGBO(90, 90, 90, 1)),
                          ))
                    ],
                  ),
                ),
              ),
              state.popularMonuments.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Text('No popular monuments to display'),
                      ),
                    )
                  : SliverList(
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
