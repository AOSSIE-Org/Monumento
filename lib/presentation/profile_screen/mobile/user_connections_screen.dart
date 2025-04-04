import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monumento/application/authentication/authentication_bloc.dart';
import 'package:monumento/presentation/profile_screen/mobile/followers_screen.dart';
import 'package:monumento/presentation/profile_screen/mobile/following_screen.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';
import 'package:monumento/domain/entities/user_entity.dart';

class UserConnectionsScreen extends StatefulWidget {
  final int index;
  final UserEntity targetUser;
  const UserConnectionsScreen({
    super.key, 
    required this.index,
    required this.targetUser,
  });

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
              title: Text(
                "@${widget.targetUser.username}",
                style: AppTextStyles.s18(
                    color: AppColor.appBlack, fontType: FontType.BOLD),
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
            body: TabBarView(children: [
              FollowersScreen(
                followers: widget.targetUser.followers,
              ),
              FollowingScreen(
                following: widget.targetUser.following,
              )
            ])));
  }
}
