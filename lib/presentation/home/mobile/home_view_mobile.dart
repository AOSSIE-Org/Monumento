import 'dart:io' as io;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:monumento/application/popular_monuments/popular_monuments_bloc.dart';
import 'package:monumento/data/repositories/appwrite_community_services_repository.dart';
import 'package:monumento/gen/assets.gen.dart';
import 'package:monumento/presentation/discover/mobile/discover_view_mobile.dart';
import 'package:monumento/presentation/feed/mobile/widgets/new_post_bottom_sheet.dart';
import 'package:monumento/presentation/feed/mobile/your_feed_view_mobile.dart';
import 'package:monumento/presentation/popular_monuments/mobile/popular_monuments_view_mobile.dart';
import 'package:monumento/presentation/profile_screen/mobile/profile_screen_mobile.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';

class HomeViewMobile extends StatefulWidget {
  const HomeViewMobile({super.key});

  @override
  State<HomeViewMobile> createState() => _HomeViewMobileState();
}

class _HomeViewMobileState extends State<HomeViewMobile> {
  int selectedIndex = 0;

  @override
  void initState() {
    locator<PopularMonumentsBloc>().add(GetPopularMonuments());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: [
          const PopularMonumentsViewMobile(),
          const YourFeedViewMobile(),
          Container(),
          const CommunitiesViewMobile(), // ADD THIS LINE

          const DiscoverViewMobile(),

          const ProfileScreenMobile(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          if (index == 2) {
            NewPostBottomSheet().newPostBottomSheet(context);
          } else {
            setState(() {
              selectedIndex = index;
            });
          }
        },
        backgroundColor: AppColor.appWhite,
        selectedItemColor: AppColor.appPrimary,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              label: 'Home',
              icon: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: SvgPicture.asset(
                  Assets.icons.icHomeSelected.path,
                ),
              ),
              activeIcon: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: SvgPicture.asset(
                  Assets.icons.icHomeSelected.path,
                  // ignore: deprecated_member_use
                  color: AppColor.appPrimary,
                ),
              )),
          BottomNavigationBarItem(
              label: 'Feed',
              icon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Assets.icons.icFeedSelected.svg(),
              ),
              activeIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SvgPicture.asset(
                    Assets.icons.icFeedSelected.path,
                    // ignore: deprecated_member_use
                    color: AppColor.appPrimary,
                  ))),
          BottomNavigationBarItem(
            label: 'Add Post',
            icon: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                boxShadow: const [
                  BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.15),
                      offset: Offset(0, -3),
                      blurRadius: 36)
                ],
                color: AppColor.appPrimary,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.add,
                color: AppColor.appBlack,
              ),
            ),
          ),
          // ADD THIS NEW COMMUNITIES TAB
          BottomNavigationBarItem(
            label: 'Communities',
            icon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.groups_outlined, color: Colors.grey[600])),
            activeIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Icon(
                Icons.groups,
                color: AppColor.appPrimary,
              ),
            ),
          ),

          BottomNavigationBarItem(
              label: 'Discover',
              icon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child:
                      SvgPicture.asset(Assets.icons.icDiscoverSelected.path)),
              activeIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SvgPicture.asset(Assets.icons.icDiscoverSelected.path,
                      // ignore: deprecated_member_use
                      color: AppColor.appPrimary))),
          BottomNavigationBarItem(
              label: 'Profile',
              icon: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: SvgPicture.asset(Assets.icons.icProfileSelected.path),
              ),
              activeIcon: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: SvgPicture.asset(Assets.icons.icProfileSelected.path,
                    // ignore: deprecated_member_use
                    color: AppColor.appPrimary),
              )),
        ],
        currentIndex: selectedIndex,
      ),
    );
  }
}

class CommunitiesViewMobile extends StatefulWidget {
  const CommunitiesViewMobile({super.key});

  @override
  State<CommunitiesViewMobile> createState() => _CommunitiesViewMobileState();
}

class _CommunitiesViewMobileState extends State<CommunitiesViewMobile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appWhite,
      appBar: AppBar(
        backgroundColor: AppColor.appWhite,
        elevation: 0,
        title: const Text(
          'Communities',
          style: TextStyle(
            color: AppColor.appBlack,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Create New Community Button
            Container(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateCommunityViewMobile(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.add,
                  color: AppColor.appWhite,
                ),
                label: const Text(
                  'Create New Community',
                  style: TextStyle(
                    color: AppColor.appWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.appPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // My Communities Section
            const Text(
              'My Communities',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColor.appBlack,
              ),
            ),

            const SizedBox(height: 16),

            // Communities List (placeholder for now)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.groups_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No communities yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your first community to get started!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CreateCommunityViewMobile extends StatefulWidget {
  const CreateCommunityViewMobile({super.key});

  @override
  State<CreateCommunityViewMobile> createState() =>
      _CreateCommunityViewMobileState();
}

class _CreateCommunityViewMobileState extends State<CreateCommunityViewMobile> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  io.File? _selectedImage; // Use the prefix
  bool _isLoading = false;

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _createCommunity() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final communityService = CommunityService();

      await communityService.createCommunity(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        coverImage: _selectedImage,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Community created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating community: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appWhite,
      appBar: AppBar(
        backgroundColor: AppColor.appWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColor.appBlack),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Community',
          style: TextStyle(
            color: AppColor.appBlack,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover Image Section
              const Text(
                'Cover Image',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColor.appBlack,
                ),
              ),
              const SizedBox(height: 12),

              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap to add cover image',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // Community Name
              const Text(
                'Community Name',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColor.appBlack,
                ),
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter community name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColor.appPrimary),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a community name';
                  }
                  if (value.trim().length < 3) {
                    return 'Community name must be at least 3 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Description
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColor.appBlack,
                ),
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Describe your community...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColor.appPrimary),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                validator: (value) {
                  if (value != null &&
                      value.trim().isNotEmpty &&
                      value.trim().length < 10) {
                    return 'Description must be at least 10 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Create Button
              Container(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createCommunity,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.appPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: AppColor.appWhite,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Create Community',
                          style: TextStyle(
                            color: AppColor.appWhite,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
