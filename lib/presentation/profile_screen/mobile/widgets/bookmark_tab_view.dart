import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:monumento/application/popular_monuments/bookmark_monuments/bookmark_monuments_bloc.dart';
import 'package:monumento/presentation/popular_monuments/mobile/monument_details_view_mobile.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';

class BookmarkTabView extends StatefulWidget {
  const BookmarkTabView({super.key});

  @override
  State<BookmarkTabView> createState() => _BookmarkTabViewState();
}

class _BookmarkTabViewState extends State<BookmarkTabView> {
  @override
  void initState() {
    locator<BookmarkMonumentsBloc>().add(const GetBookmarkedMonuments());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookmarkMonumentsBloc, BookmarkMonumentsState>(
      bloc: locator<BookmarkMonumentsBloc>(),
      builder: (context, state) {
        if (state is BookmarkedMonumentsLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColor.appPrimary,
              ),
            ),
          );
        } else if (state is BookmarkedMonumentsLoaded) {
          return GridView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: state.bookmarkedMonuments.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  childAspectRatio: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8),
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MonumentDetailsViewMobile(
                          isBookmarked: true,
                          monument: state.bookmarkedMonuments[index],
                        ),
                      ),
                    );
                  },
                  child: CachedNetworkImage(
                      imageUrl: state.bookmarkedMonuments[index].imageUrl,
                      imageBuilder: (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.sp),
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ))),
                );
              });
        } else {
          return const Center(
            child: Text("No bookmarks to display"),
          );
        }
      },
    );
  }
}
