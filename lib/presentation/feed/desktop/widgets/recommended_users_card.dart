import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:monumento/application/feed/recommended_users/recommended_users_bloc.dart';
import 'package:monumento/presentation/feed/desktop/widgets/user_card.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';

class RecommendedUsersCard extends StatefulWidget {
  const RecommendedUsersCard({super.key});

  @override
  State<RecommendedUsersCard> createState() => _RecommendedUsersCardState();
}

class _RecommendedUsersCardState extends State<RecommendedUsersCard> {
  @override
  void initState() {
    locator<RecommendedUsersBloc>().add(const GetRecommendedUsers());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: SizedBox(
          width: 300,
          height: 360,
          child: BlocBuilder<RecommendedUsersBloc, RecommendedUsersState>(
            bloc: locator<RecommendedUsersBloc>(),
            builder: (context, state) {
              if (state is RecommendedUsersLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColor.appPrimary,
                  ),
                );
              }
              if (state is RecommendedUsersLoaded) {
                return ListView.separated(
                  itemCount: state.recommendedUsers.length,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Column(
                        children: [
                          ListTile(
                            title: Text(
                              'Recommended Users',
                              style: AppTextStyles.s16(
                                color: AppColor.appSecondary,
                                fontType: FontType.MEDIUM,
                              ),
                            ),
                          ),
                          Divider(
                            color: AppColor.appGreyAccent,
                            indent: 10.w,
                            endIndent: 10.w,
                          )
                        ],
                      );
                    }
                    return UserCard(
                      user: state.recommendedUsers[index],
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return SizedBox(
                      height: 10.h,
                    );
                  },
                );
              }
              return Container();
            },
          ),
        ),
      ),
    );
  }
}
