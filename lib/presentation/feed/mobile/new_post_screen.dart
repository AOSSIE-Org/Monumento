import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:monumento/application/authentication/authentication_bloc.dart';
import 'package:monumento/application/feed/new_post/new_post_bloc.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';
import 'package:monumento/utils/constants.dart';

class NewPostScreen extends StatefulWidget {
  const NewPostScreen({super.key});

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  final TextEditingController titleController = TextEditingController();
  File? image;

  Future<void> _pickImage(ImageSource source) async {
    var img = await ImagePicker().pickImage(source: source);
    if (img != null) {
      setState(() {
        image = File(img.path);
      });
    }
  }

  void _submitPost() {
    if (image == null && titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please add a title or an image"),
        ),
      );
      return;
    }
    if (image != null) {
      locator<NewPostBloc>().add(
        AddNewPost(
          title: titleController.text.trim(),
          postType: 0, // Image post
          image: image,
        ),
      );
    } else {
      locator<NewPostBloc>().add(
        AddNewPost(
          title: titleController.text.trim(),
          postType: 1, // Text post
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = locator<AuthenticationBloc>().state;

    if (authState is! Authenticated) {
      return const Scaffold(body: Center(child: Text("User not authenticated")));
    }

    final authenticatedUser = authState.user;

    return Scaffold(
      backgroundColor: AppColor.appBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColor.appTextPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "New Post",
          style: AppTextStyles.s16(
              fontType: FontType.MEDIUM, color: AppColor.appTextPrimary),
        ),
        actions: [
          BlocConsumer<NewPostBloc, NewPostState>(
            bloc: locator<NewPostBloc>(),
            listener: (context, state) {
              if (state is NewPostAdded) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Post created successfully!")),
                );
              } else if (state is NewPostFailed) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text("Error creating post: ${state.message}")),
                );
              }
            },
            builder: (context, state) {
              if (state is AddingNewPost) {
                return const Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColor.appPrimary,
                      ),
                    ),
                  ),
                );
              }
              return TextButton(
                onPressed: _submitPost,
                child: Text(
                  "Post",
                  style: AppTextStyles.s16(
                      color: AppColor.appPrimary, fontType: FontType.MEDIUM),
                ),
              );
            },
          ),
        ],
        backgroundColor: AppColor.appBackground,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            image!,
                            height: 500,
                            width: 250,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(
                          height: 500,
                          width: 250,
                          decoration: BoxDecoration(
                            color: AppColor.appPrimary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColor.appPrimary,
                              width: 1.5,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_search,
                                size: 60,
                                color: AppColor.appPrimary,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Select Monument Image",
                                style: AppTextStyles.s16(
                                    color: AppColor.appSecondary,
                                    fontType: FontType.MEDIUM),
                              ),
                            ],
                          ),
                        ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          Padding(
             padding: EdgeInsets.only(
               bottom: MediaQuery.of(context).viewInsets.bottom,
               left: 16.0,
               right: 16.0,
               top: 8.0,
             ),
            child: Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: CachedNetworkImageProvider(
                          authenticatedUser.profilePictureUrl ??
                              defaultProfilePicture),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 60.0),
                        child: TextFormField(
                          controller: titleController,
                          maxLines: null,
                          minLines: 1,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            hintText: "Write a caption...",
                            border: InputBorder.none,
                            hintStyle: AppTextStyles.s14(
                              color: AppColor.appSecondary,
                              fontType: FontType.REGULAR,
                            ),
                          ),
                          style: AppTextStyles.s14(
                              color: AppColor.appTextPrimary,
                              fontType: FontType.REGULAR),
                        ),
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: FloatingActionButton(
                    onPressed: () {
                      // TODO: Implement FAB action (e.g., open additional options?)
                    },
                    mini: true,
                    backgroundColor: Colors.amber,
                    child: const Icon(Icons.add, color: AppColor.appTextPrimary),
                    elevation: 4.0,
                  ),
                )
              ]
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: AppColor.appBackground,
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildMediaButton(
                icon: Icons.photo_library_outlined,
                label: "Gallery",
                onTap: () => _pickImage(ImageSource.gallery),
              ),
              const SizedBox(width: 12),
              _buildMediaButton(
                icon: Icons.camera_alt_outlined,
                label: "Camera",
                onTap: () => _pickImage(ImageSource.camera),
              ),
              const SizedBox(width: 12),
              _buildMediaButton(
                  icon: Icons.videocam_outlined,
                  label: "Video",
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text("Video selection not implemented yet.")),
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
           color: AppColor.appPrimary.withOpacity(0.1),
           borderRadius: BorderRadius.circular(20),
           border: Border.all(color: AppColor.appPrimary.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColor.appPrimary),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.s12(
                color: AppColor.appPrimary,
                fontType: FontType.MEDIUM,
              ),
            ),
          ],
        ),
      ),
    );
  }
}