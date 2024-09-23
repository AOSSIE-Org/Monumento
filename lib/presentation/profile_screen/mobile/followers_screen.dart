import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monumento/application/profile/follow/follow_bloc.dart';
import 'package:monumento/domain/entities/user_entity.dart';
import 'package:monumento/presentation/profile_screen/mobile/widgets/user_connections_tile.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';

class FollowersScreen extends StatefulWidget {
  final List<String> followers;
  const FollowersScreen({super.key, required this.followers});

  @override
  State<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {
  @override
  void initState() {
    locator<FollowBloc>().add(LoadUser(following: widget.followers));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<UserEntity> userFollowers = [];

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
            userFollowers = [];
            userFollowers.insertAll(userFollowers.length, state.userData);
          }
          return UserConnectionsTile(
            user: userFollowers,
          );
        },
      ),
    );
  }
}
