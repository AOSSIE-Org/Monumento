import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monumento/application/profile/follow/follow_bloc.dart';
import 'package:monumento/domain/entities/user_entity.dart';
import 'package:monumento/presentation/profile_screen/mobile/widgets/user_connections_tile.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';

class FollowingScreen extends StatefulWidget {
  final List<String> following;
  const FollowingScreen({super.key, required this.following});

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  @override
  void initState() {
    locator<FollowBloc>().add(LoadUser(following: widget.following));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<UserEntity> userFollowing = [];

    return Scaffold(
      body: BlocBuilder<FollowBloc, FollowState>(
        bloc: locator<FollowBloc>(),
        builder: (context, state) {
          if (state is LoadingFollowUserListState) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColor.appPrimary,
                ),
              ),
            );
          } else if (state is LoadedFollowUserListState) {
            userFollowing = [];
            userFollowing.insertAll(userFollowing.length, state.userData);
          }
          return UserConnectionsTile(
            user: userFollowing,
          );
        },
      ),
    );
  }
}
