import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monumento/application/authentication/authentication_bloc.dart';
import 'package:monumento/application/profile/follow/follow_bloc.dart';
import 'package:monumento/domain/entities/user_entity.dart';
import 'package:monumento/presentation/discover/mobile/discover_profile_view_mobile.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/constants.dart';

class UserConnectionsTile extends StatefulWidget {
  final List<UserEntity> user;
  const UserConnectionsTile({super.key, required this.user});

  @override
  State<UserConnectionsTile> createState() => _UserConnectionsTileState();
}

class _UserConnectionsTileState extends State<UserConnectionsTile> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.user.length,
      itemBuilder: (context, i) {
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => DiscoverProfileViewMobile(
                        user: widget.user[i],
                      )),
            );
          },
          child: ListTile(
              leading: CircleAvatar(
                radius: 20,
                backgroundImage: CachedNetworkImageProvider(
                    widget.user[i].profilePictureUrl ?? defaultProfilePicture),
              ),
              title: Text(widget.user[i].name),
              subtitle: Text(widget.user[i].username!),
              trailing: BlocBuilder<AuthenticationBloc, AuthenticationState>(
                bloc: locator<AuthenticationBloc>(),
                builder: (context, state) {
                  state as Authenticated;
                  return CustomElevatedButton(
                    onPressed: () {
                      if (widget.user[i].followers.contains(state.user.uid)) {
                        locator<FollowBloc>().add(
                          UnfollowUser(
                            targetUser: widget.user[i],
                          ),
                        );
                      } else {
                        locator<FollowBloc>().add(
                          FollowUser(
                            targetUser: widget.user[i],
                          ),
                        );
                      }
                    },
                    text: widget.user[i].followers.contains(state.user.uid)
                        ? 'Following'
                        : ' Follow ',
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      backgroundColor: AppColor.appPrimary,
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 20),
                    ),
                  );
                },
              )),
        );
      },
    );
  }
}
