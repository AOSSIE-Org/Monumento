import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monumento/application/authentication/authentication_bloc.dart';
import 'package:monumento/application/profile/follow/follow_bloc.dart';
import 'package:monumento/domain/entities/user_entity.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/constants.dart';

class FollowButton extends StatefulWidget {
  final bool isAccountOwner;
  final UserEntity targetUser;
  const FollowButton(
      {super.key, required this.isAccountOwner, required this.targetUser});

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    // Initialize follow status
    locator<FollowBloc>().add(GetFollowStatus(targetUser: widget.targetUser));
  }

  @override
  Widget build(BuildContext context) {
    return widget.isAccountOwner
        ? const SizedBox()
        : BlocBuilder<AuthenticationBloc, AuthenticationState>(
            bloc: locator<AuthenticationBloc>(),
            builder: (context, state) {
              state as Authenticated;
              return BlocBuilder<FollowBloc, FollowState>(
                bloc: locator<FollowBloc>(),
                builder: (context, followState) {
                  if (followState is FollowStatusRetrieved) {
                    _isFollowing = followState.following;
                  } else if (followState is LoadingFollowState) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColor.appPrimary,
                        ),
                      ),
                    );
                  }

                  return Center(
                    child: CustomElevatedButton(
                      onPressed: () {
                        if (_isFollowing) {
                          locator<FollowBloc>().add(
                            UnfollowUser(
                              targetUser: widget.targetUser,
                            ),
                          );
                        } else {
                          locator<FollowBloc>().add(
                            FollowUser(
                              targetUser: widget.targetUser,
                            ),
                          );
                        }
                      },
                      text: _isFollowing ? 'Following' : ' Follow ',
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(MediaQuery.sizeOf(context).width*2/3, 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        backgroundColor: AppColor.appPrimary,
                        padding:
                            const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      ),
                    ),
                  );
                },
              );
            },
          );
  }
}
