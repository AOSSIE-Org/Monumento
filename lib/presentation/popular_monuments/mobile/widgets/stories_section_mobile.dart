import 'package:flutter/material.dart';
import 'package:monumento/data/models/story_model.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';

class StoriesSection extends StatefulWidget {
  final List<StoryModel> stories;
  final VoidCallback onAddStory;
  final Function(StoryModel) onStoryTap;

  const StoriesSection({
    Key? key,
    required this.stories,
    required this.onAddStory,
    required this.onStoryTap,
  }) : super(key: key);

  @override
  State<StoriesSection> createState() => _StoriesSectionState();
}

class _StoriesSectionState extends State<StoriesSection> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.appWhite,
        border: Border(
          bottom: BorderSide(
            color: AppColor.appGreyAccent.withOpacity(0.3),
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 140,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              itemCount: widget.stories.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildAddStoryButton();
                }

                final story = widget.stories[index - 1];
                return _buildStoryThumbnail(story);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddStoryButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: widget.onAddStory,
        child: Column(
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColor.appPrimary.withOpacity(0.15),
                    AppColor.appPrimary.withOpacity(0.05),
                  ],
                ),
                border: Border.all(
                  color: AppColor.appPrimary.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColor.appPrimary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: AppColor.appBlack,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Add',
                    style: AppTextStyles.textStyle(
                      fontType: FontType.MEDIUM,
                      size: 11,
                      isBody: true,
                      color: AppColor.appPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 86,
              child: Text(
                'Your Story',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyles.textStyle(
                  fontType: FontType.REGULAR,
                  size: 11,
                  isBody: true,
                  color: AppColor.appSecondaryBlack,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryThumbnail(StoryModel story) {
    final hasViewed = story.viewedBy.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: () => widget.onStoryTap(story),
        child: Column(
          children: [
            Stack(
              children: [
                // Story image with rounded corners
                Container(
                  width: 86,
                  height: 86,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: hasViewed
                          ? AppColor.appLightGrey.withOpacity(0.4)
                          : AppColor.appPrimary,
                      width: hasViewed ? 1 : 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.appBlack.withOpacity(0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      story.mediaUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColor.appGreyAccent,
                          child: const Icon(
                            Icons.broken_image,
                            color: AppColor.appTextGrey,
                            size: 28,
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: AppColor.appGreyAccent,
                          child: const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Viewed indicator overlay
                if (hasViewed)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: AppColor.appBlack.withOpacity(0.25),
                      ),
                    ),
                  ),

                // User avatar in bottom-left
                if (story.author != null)
                  Positioned(
                    bottom: 4,
                    left: 4,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColor.appWhite,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.appBlack.withOpacity(0.15),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        backgroundColor: AppColor.appPrimary,
                        backgroundImage: story.author!['profilePictureUrl'] !=
                                null
                            ? NetworkImage(story.author!['profilePictureUrl'])
                            : null,
                        child: story.author!['profilePictureUrl'] == null
                            ? const Icon(
                                Icons.person,
                                color: AppColor.appBlack,
                                size: 12,
                              )
                            : null,
                      ),
                    ),
                  ),

                // Remaining time badge in top-right
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.appBlack.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColor.appWhite.withOpacity(0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      '${story.remainingHours.toStringAsFixed(1)}h',
                      style: AppTextStyles.textStyle(
                        fontType: FontType.REGULAR,
                        size: 9,
                        isBody: true,
                        color: AppColor.appWhite,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Username
            SizedBox(
              width: 86,
              child: Text(
                story.author?['username'] ?? 'Unknown',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyles.textStyle(
                  fontType: FontType.REGULAR,
                  size: 11,
                  isBody: true,
                  color: hasViewed
                      ? AppColor.appLightGrey
                      : AppColor.appSecondaryBlack,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
