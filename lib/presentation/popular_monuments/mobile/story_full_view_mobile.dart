import 'dart:async';

import 'package:flutter/material.dart';
import 'package:monumento/data/models/story_model.dart';
import 'package:monumento/domain/repositories/authentication_repository.dart';
import 'package:monumento/domain/repositories/social_repository.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';

class StoryFullViewScreen extends StatefulWidget {
  final StoryModel story;

  const StoryFullViewScreen({
    Key? key,
    required this.story,
  }) : super(key: key);

  @override
  State<StoryFullViewScreen> createState() => _StoryFullViewScreenState();
}

class _StoryFullViewScreenState extends State<StoryFullViewScreen>
    with SingleTickerProviderStateMixin {
  late SocialRepository _socialRepository;
  late AuthenticationRepository _authenticationRepository;
  bool _viewRecorded = false;
  late AnimationController _progressController;
  late Timer _autoCloseTimer;
  bool _isOwner = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _socialRepository = locator<SocialRepository>();
    _authenticationRepository = locator<AuthenticationRepository>();

    // Initialize progress animation (5 second duration)
    _progressController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    _recordView();
    _checkIfOwner();
    _startAutoClose();
    _progressController.forward();
  }

  Future<void> _checkIfOwner() async {
    try {
      var (userLoggedIn, user) = await _authenticationRepository.getUser();
      if (userLoggedIn && user != null) {
        setState(() {
          _isOwner = user.uid == widget.story.userId;
        });
      }
    } catch (e) {
      print('Error checking ownership: $e');
    }
  }

  Future<void> _deleteStory() async {
    if (!_isOwner) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColor.appWhite,
        title: Text(
          'Delete Story?',
          style: AppTextStyles.textStyle(
            fontType: FontType.MEDIUM,
            size: 16,
            isBody: true,
            color: AppColor.appSecondaryBlack,
          ),
        ),
        content: Text(
          'This story will be permanently deleted.',
          style: AppTextStyles.textStyle(
            fontType: FontType.REGULAR,
            size: 14,
            isBody: true,
            color: AppColor.appTextGrey,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTextStyles.textStyle(
                fontType: FontType.MEDIUM,
                size: 14,
                isBody: true,
                color: AppColor.appSecondaryBlack,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: AppTextStyles.textStyle(
                fontType: FontType.MEDIUM,
                size: 14,
                isBody: true,
                color: AppColor.appWarningRed,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isDeleting = true;
      });

      try {
        await _socialRepository.deleteStory(storyId: widget.story.storyId);

        if (mounted) {
          Navigator.pop(context, true); // true indicates story was deleted
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isDeleting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to delete story'),
              backgroundColor: AppColor.appWarningRed,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    }
  }

  void _startAutoClose() {
    _autoCloseTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  Future<void> _recordView() async {
    if (_viewRecorded) return;

    try {
      var (userLoggedIn, user) = await _authenticationRepository.getUser();
      if (userLoggedIn && user != null) {
        await _socialRepository.addStoryView(
          storyId: widget.story.storyId,
          userId: user.uid,
        );
        _viewRecorded = true;
      }
    } catch (e) {
      print('Error recording view: $e');
    }
  }

  String _getTimeAgo(int timestamp) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final difference = now - timestamp;

    if (difference < 60000) {
      return 'just now';
    } else if (difference < 3600000) {
      return '${(difference / 60000).toStringAsFixed(0)}m ago';
    } else if (difference < 86400000) {
      return '${(difference / 3600000).toStringAsFixed(0)}h ago';
    } else {
      return '${(difference / 86400000).toStringAsFixed(0)}d ago';
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _autoCloseTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final author = widget.story.author;

    return Scaffold(
      backgroundColor: AppColor.appBlack,
      body: GestureDetector(
        onTap: () {
          // Pause/resume functionality - tapping dismisses the story
          Navigator.pop(context);
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            Image.network(
              widget.story.mediaUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColor.appGreyAccent,
                  child: const Center(
                    child: Icon(
                      Icons.broken_image,
                      color: AppColor.appTextGrey,
                      size: 48,
                    ),
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: AppColor.appGreyAccent,
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColor.appPrimary,
                      ),
                    ),
                  ),
                );
              },
            ),

            // Gradient overlay at top
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                  colors: [
                    AppColor.appBlack.withOpacity(0.6),
                    AppColor.appBlack.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            // Gradient overlay at bottom for caption
            if (widget.story.caption != null &&
                widget.story.caption!.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.center,
                    colors: [
                      AppColor.appBlack.withOpacity(0.8),
                      AppColor.appBlack.withOpacity(0.4),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

            // Top bar with progress and close button
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Column(
                    children: [
                      // Progress bar
                      AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, child) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(1),
                            child: LinearProgressIndicator(
                              value: _progressController.value,
                              minHeight: 2,
                              backgroundColor:
                                  AppColor.appWhite.withOpacity(0.3),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColor.appPrimary,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      // Header with user info and close button
                      Row(
                        children: [
                          // User info
                          if (author != null)
                            Expanded(
                              child: Row(
                                children: [
                                  // Avatar
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: AppColor.appPrimary,
                                    backgroundImage:
                                        author['profilePictureUrl'] != null
                                            ? NetworkImage(
                                                author['profilePictureUrl'])
                                            : null,
                                    child: author['profilePictureUrl'] == null
                                        ? const Icon(
                                            Icons.person,
                                            color: AppColor.appBlack,
                                            size: 16,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 10),
                                  // Username and time
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          author['username'] ?? 'Unknown',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyles.textStyle(
                                            fontType: FontType.MEDIUM,
                                            size: 13,
                                            isBody: true,
                                            color: AppColor.appWhite,
                                          ),
                                        ),
                                        Text(
                                          _getTimeAgo(
                                              widget.story.uploadTimestamp),
                                          style: AppTextStyles.textStyle(
                                            fontType: FontType.REGULAR,
                                            size: 11,
                                            isBody: true,
                                            color: AppColor.appWhite
                                                .withOpacity(0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(width: 8),
                          // Delete button (only for owner)
                          if (_isOwner)
                            GestureDetector(
                              onTap: _isDeleting ? null : _deleteStory,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                child: _isDeleting
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            AppColor.appWarningRed,
                                          ),
                                        ),
                                      )
                                    : Icon(
                                        Icons.delete_outline,
                                        color: AppColor.appWarningRed
                                            .withOpacity(0.8),
                                        size: 24,
                                      ),
                              ),
                            ),
                          const SizedBox(width: 8),
                          // Close button
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                Icons.close,
                                color: AppColor.appWhite.withOpacity(0.8),
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Caption at bottom
            if (widget.story.caption != null &&
                widget.story.caption!.isNotEmpty)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.story.caption!,
                          style: AppTextStyles.textStyle(
                            fontType: FontType.REGULAR,
                            size: 14,
                            isBody: true,
                            color: AppColor.appWhite,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Views counter
                        Row(
                          children: [
                            Icon(
                              Icons.visibility,
                              color: AppColor.appWhite.withOpacity(0.8),
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${widget.story.views} ${widget.story.views == 1 ? 'view' : 'views'}',
                              style: AppTextStyles.textStyle(
                                fontType: FontType.REGULAR,
                                size: 12,
                                isBody: true,
                                color: AppColor.appWhite.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // No caption - show views in center bottom
            if (widget.story.caption == null || widget.story.caption!.isEmpty)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.appBlack.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColor.appWhite.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.visibility,
                          color: AppColor.appWhite.withOpacity(0.9),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${widget.story.views} ${widget.story.views == 1 ? 'view' : 'views'}',
                          style: AppTextStyles.textStyle(
                            fontType: FontType.REGULAR,
                            size: 12,
                            isBody: true,
                            color: AppColor.appWhite,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Tap hint text in center (fades out)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.45,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                opacity: _progressController.value > 0.3 ? 0 : 1,
                duration: const Duration(milliseconds: 300),
                child: Center(
                  child: Text(
                    'Tap to close',
                    style: AppTextStyles.textStyle(
                      fontType: FontType.REGULAR,
                      size: 12,
                      isBody: true,
                      color: AppColor.appWhite.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
