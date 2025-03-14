import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:monumento/application/popular_monuments/popular_monuments_bloc.dart';
import 'package:monumento/domain/entities/monument_entity.dart';
import 'package:monumento/presentation/popular_monuments/desktop/widgets/monument_details_card.dart';
import 'package:monumento/presentation/popular_monuments/mobile/monument_details_view_mobile.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';

class PopularMonumentsViewMobileBodyBlocBuilder extends StatelessWidget {
  const PopularMonumentsViewMobileBodyBlocBuilder({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PopularMonumentsBloc, PopularMonumentsState>(
      bloc: locator<PopularMonumentsBloc>(),
      buildWhen: (previous, current) {
        return current != previous;
      },
      builder: (context, state) {
        //TODO: handle it later using shimmer  effect instead
        if (state is LoadingPopularMonuments) {
          return const Center(
            child: CircularProgressIndicator(
              backgroundColor: AppColor.appPrimary,
            ),
          );
        } else if (state is PopularMonumentsRetrieved) {
          return PopularMonumentsGridViewWidget(
            monuments: state.popularMonuments,
          );
        } else {
          //TODO: add custom error widget for all app later
          return Center(
            child: Text(
              state.toString(),
            ),
          );
        }
      },
    );
  }
}

class PopularMonumentsGridViewWidget extends StatelessWidget {
  final List<MonumentEntity> monuments;

  const PopularMonumentsGridViewWidget({Key? key, required this.monuments})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.symmetric(
        vertical: 20.h,
        horizontal: 10.w,
      ),
      itemCount: monuments.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        childAspectRatio: 600.w / 350.h,
      ),
      itemBuilder: (BuildContext context, int index) {
        return MonumentDetailsCard(
          monument: monuments[index],
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MonumentDetailsViewMobile(
                  monument: monuments[index],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
