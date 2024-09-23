import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monumento/application/authentication/authentication_bloc.dart';
import 'package:monumento/application/profile/follow/follow_bloc.dart';
import 'package:monumento/domain/entities/user_entity.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/constants.dart';

class FollowButton extends StatelessWidget {
  final bool isAccountOwner;
  final UserEntity targetUser;
  const FollowButton(
      {super.key, required this.isAccountOwner, required this.targetUser});

  @override
  Widget build(BuildContext context) {
    return isAccountOwner
        ? const SizedBox()
        : BlocBuilder<AuthenticationBloc, AuthenticationState>(
            bloc: locator<AuthenticationBloc>(),
            builder: (context, state) {
              state as Authenticated;
              return Center(
                child: CustomElevatedButton(
                  onPressed: () {
                    if (targetUser.followers.contains(state.user.uid)) {
                      locator<FollowBloc>().add(
                        UnfollowUser(
                          targetUser: targetUser,
                        ),
                      );
                    } else {
                      locator<FollowBloc>().add(
                        FollowUser(
                          targetUser: targetUser,
                        ),
                      );
                    }
                  },
                  text: targetUser.followers.contains(state.user.uid)
                      ? 'Following'
                      : ' Follow ',
                  style: ElevatedButton.styleFrom(
                    minimumSize:Size(MediaQuery.sizeOf(context).width*2/3, 20),
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
  }
}
