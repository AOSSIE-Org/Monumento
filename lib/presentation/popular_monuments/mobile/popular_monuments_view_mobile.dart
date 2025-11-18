import 'package:flutter/material.dart';
import 'package:monumento/application/monument_review_hub/review_hub_screen.dart';
import 'package:monumento/application/popular_monuments/monument_3d_model/monument_3d_model_bloc.dart';
import 'package:monumento/data/models/story_model.dart';
import 'package:monumento/domain/repositories/social_repository.dart';
import 'package:monumento/gen/assets.gen.dart';
import 'package:monumento/presentation/notification/desktop/notification_view_desktop.dart';
import 'package:monumento/presentation/popular_monuments/mobile/create_story_view_mobile.dart';
import 'package:monumento/presentation/popular_monuments/mobile/story_full_view_mobile.dart';
import 'package:monumento/presentation/popular_monuments/mobile/widgets/populat_monuments_view_body_mobile.dart';
import 'package:monumento/presentation/popular_monuments/mobile/widgets/scan_monuments_screen.dart';
import 'package:monumento/presentation/popular_monuments/mobile/widgets/stories_section_mobile.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';
import 'package:monumento/utils/custom_mobile_appBar.dart';

class PopularMonumentsViewMobile extends StatefulWidget {
  const PopularMonumentsViewMobile({super.key});

  @override
  State<PopularMonumentsViewMobile> createState() =>
      _PopularMonumentsViewMobileState();
}

class _PopularMonumentsViewMobileState
    extends State<PopularMonumentsViewMobile> {
  late SocialRepository _socialRepository;
  List<StoryModel> _stories = [];
  bool _storiesLoading = true;
  @override
  void initState() {
    locator<Monument3dModelBloc>().add(const ViewMonument3DModel(
        monumentName: "Mount Rushmore National Memorial"));
    _socialRepository = locator<SocialRepository>();

    _loadStories();

    super.initState();
  }

  Future<void> _loadStories() async {
    try {
      final stories = await _socialRepository.fetchStories();
      if (!mounted) return;
      setState(() {
        _stories = stories;
        _storiesLoading = false;
      });
    } catch (e) {
      print('Error loading stories: $e');
      if (!mounted) return;
      setState(() {
        _storiesLoading = false;
      });
    }
  }

  Future<void> _navigateToCreateStory() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => const CreateStoryScreen(),
      ),
    );

    // Reload stories if a new story was created
    if (result == true) {
      await _loadStories();
    }
  }

  void _viewStory(StoryModel story) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (ctx) => StoryFullViewScreen(story: story),
      ),
    ).then((_) {
      // Reload stories in case view count changed
      _loadStories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomMobileAppBar(
        logoPath: Assets.desktop.logoDesktop.path,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
            ),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) {
                    return const NotificationViewDesktop();
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadStories();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Stories section
              if (_storiesLoading)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: SizedBox(
                    height: 130,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: 3,
                      itemBuilder: (_, __) => Container(
                        width: 90,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: AppColor.appGreyAccent,
                        ),
                      ),
                    ),
                  ),
                )
              else // Always show stories section (add button available)
                StoriesSection(
                  stories: _stories,
                  onAddStory: _navigateToCreateStory,
                  onStoryTap: _viewStory,
                ),

              SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: const PopularMonumentsViewMobileBodyBlocBuilder(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: "scanMonumentsFAB",
            onPressed: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ScanMonumentsScreen()));
            },
            label: Text(
              "Scan Monuments",
              style: AppTextStyles.textStyle(
                fontType: FontType.MEDIUM,
                size: 14,
                isBody: true,
              ),
            ),
            backgroundColor: AppColor.appPrimary,
            extendedPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: "reviewHubFAB",
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ReviewHubScreen(
                    userId: '',
                  ),
                ),
              );
            },
            label: Text(
              "Review Hub",
              style: AppTextStyles.textStyle(
                  fontType: FontType.MEDIUM, size: 14, isBody: true),
            ),
            backgroundColor: AppColor.appPrimary,
            extendedPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ],
      ),
    );
  }
}
