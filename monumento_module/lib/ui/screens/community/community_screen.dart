import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monumento/blocs/community/communities_state.dart';
import 'package:monumento/resources/communities/community_repository.dart';
import 'package:monumento/resources/communities/models/community_model.dart';
import 'package:monumento/ui/screens/community/components/community_tile.dart';

import '../../../blocs/community/communities_bloc.dart';
import '../../../blocs/community/communities_event.dart';
import '../../../resources/authentication/models/user_model.dart';
import '../../../utilities/constants.dart';
import '../../widgets/custom_app_bar.dart';

class CommunityScreen extends StatefulWidget{

  const CommunityScreen({Key key, @required this.user}) : super(key: key);
  final UserModel user;

  @override
  _CommunityScreenState createState() => _CommunityScreenState();

}


class _CommunityScreenState extends State<CommunityScreen>{
  CommunitiesBloc _communitiesBloc;
  List<Map<String, dynamic>> communitiesMapList = new List();

  @override
  void initState(){
    super.initState();
    _communitiesBloc = CommunitiesBloc(
      communityRepository: RepositoryProvider.of<CommunityRepository>(context)
    );
    _communitiesBloc.add(LoadInitialCommunities());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommunitiesBloc, CommunitiesState>(
      bloc: _communitiesBloc,
      builder: (context, state){
        if(state is InitialCommunitiesLoaded){
          print(state.toString());
          for(CommunityModel communityModel in state.initialCommunities){
            communitiesMapList.add(communityModel.toEntity().toMap());
          }
          return CustomScrollView(
            slivers: [
              SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  sliver: CustomAppBar(
                      title: 'Communities',
                      textStyle: kStyle28W700.copyWith(
                          color: Color.fromRGBO(255, 214, 0, 1)))),
              state.initialCommunities.isEmpty
                  ? SliverFillRemaining(
                child: Center(
                  child: Text('No communities to display'),
                ),
              )
                  : SliverList(
                  delegate: SliverChildBuilderDelegate((_, index) {
                    return CommunityTile(
                      community: state.initialCommunities[index],
                      user: widget.user,
                    );
                  }, childCount: state.initialCommunities.length))
            ],
          );
        }
        if (state is LoadingInitialCommunities) {
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
