// Popular Monuments Section with Bloc Builder
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:monumento/application/popular_monuments/popular_monuments_bloc.dart';
import 'package:monumento/presentation/discover/mobile/widgets/discover_generic_grid_section.dart';
import 'package:monumento/presentation/popular_monuments/mobile/monument_details_view_mobile.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';

class PopularMonumentsSectionBodyBlocBuilder extends StatelessWidget {
  const PopularMonumentsSectionBodyBlocBuilder({Key? key}) : super(key: key);

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
          return GenericGridSection(
            items: state.popularMonuments,
            itemWidth: 60.w,
            itemHeight: 100.h,
            itemBuilder: (monument) => GenericGridItemWidget(
              onTapBuilder: (monument) => () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MonumentDetailsViewMobile(
                      monument: monument,
                    ),
                  ),
                );
              },
              item: monument,
              getTitle: (monument) => monument.name,
              getImage: (monument) => monument.imageUrl,
            ),
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
