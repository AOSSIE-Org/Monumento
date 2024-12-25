import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monumento/application/authentication/authentication_bloc.dart';
import 'package:monumento/presentation/profile_screen/mobile/followers_screen.dart';
import 'package:monumento/presentation/profile_screen/mobile/following_screen.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';

class UserConnectionsScreen extends StatefulWidget {
  final int index;
  const UserConnectionsScreen({super.key, required this.index});

  @override
  State<UserConnectionsScreen> createState() => _UserConnectionsScreenState();
}

class _UserConnectionsScreenState extends State<UserConnectionsScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        initialIndex: widget.index,
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: AppColor.appWhite,
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColor.appBlack,
                ),
              ),
              title: BlocBuilder<AuthenticationBloc, AuthenticationState>(
                bloc: locator<AuthenticationBloc>(),
                builder: (context, state) {
                  state as Authenticated;
                  return Text(
                    "@${state.user.username}",
                    style: AppTextStyles.s18(
                        color: AppColor.appBlack, fontType: FontType.BOLD),
                  );
                },
              ),
              bottom: const TabBar(
                  labelColor: AppColor.appBlack,
                  unselectedLabelColor: AppColor.appGrey,
                  tabs: [
                    Tab(
                      text: "Followers",
                    ),
                    Tab(
                      text: "Following",
                    )
                  ]),
            ),
            body: BlocBuilder<AuthenticationBloc, AuthenticationState>(
              bloc: locator<AuthenticationBloc>(),
              builder: (context, state) {
                state as Authenticated;
                return TabBarView(children: [
                  FollowersScreen(
                    followers: state.user.followers,
                  ),
                  FollowingScreen(
                    following: state.user.following,
                  )
                ]);
              },
            )));
  }
}
