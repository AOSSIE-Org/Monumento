import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:monumento/application/authentication/authentication_bloc.dart';
import 'package:monumento/application/feed/new_post/new_post_bloc.dart';
import 'package:monumento/gen/assets.gen.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';
import 'package:monumento/utils/constants.dart';

class CreatePostCard extends StatefulWidget {
  const CreatePostCard({super.key});

  @override
  State<CreatePostCard> createState() => _CreatePostCardState();
}

class _CreatePostCardState extends State<CreatePostCard>
    with AutomaticKeepAliveClientMixin<CreatePostCard> {
  final TextEditingController _titleController = TextEditingController();
  File? _image;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      bloc: locator<AuthenticationBloc>(),
      builder: (context, state) {
        state as Authenticated;
        return BlocListener<NewPostBloc, NewPostState>(
          bloc: locator<NewPostBloc>(),
          listener: (context, state) {
            if (state is NewPostAdded) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Post added successfully"),
                ),
              );
              _titleController.clear();
              setState(() {
                _image = null;
              });
            }
            if (state is NewPostFailed) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: const Text(
                      'Failed to upload your post. Please try again later!'),
                ),
              );
            }
          },
          child: Card(
            child: Container(
              width: 520,
              margin: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColor.appWhite,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: CachedNetworkImageProvider(
                          state.user.profilePictureUrl ?? defaultProfilePicture,
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Column(
                    children: [
                      SizedBox(
                        width: 420,
                        child: TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            hintText: 'What\'s on your mind?',
                            hintStyle: AppTextStyles.s14(
                              color: AppColor.appSecondary,
                              fontType: FontType.REGULAR,
                              isDesktop: true,
                            ),
                            border: const UnderlineInputBorder(),
                          ),
                        ),
                      ),
                      if (_image != null)
                        const SizedBox(
                          height: 16,
                        ),
                      if (_image != null)
                        Container(
                          width: 420,
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: FileImage(_image!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      const SizedBox(
                        height: 16,
                      ),
                      SizedBox(
                        width: 420,
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                var img = await ImagePicker()
                                    .pickImage(source: ImageSource.gallery);
                                if (img != null) {
                                  setState(() {
                                    _image = File(img.path);
                                  });
                                }
                              },
                              child: Row(
                                children: [
                                  Assets.icons.icMedia.svg(
                                    height: 18,
                                    width: 18,
                                  ),
                                  const SizedBox(
                                    width: 4,
                                  ),
                                  Text(
                                    "Add Media",
                                    style: AppTextStyles.s14(
                                      color: AppColor.appSecondary,
                                      fontType: FontType.MEDIUM,
                                      isDesktop: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            BlocBuilder<NewPostBloc, NewPostState>(
                              bloc: locator<NewPostBloc>(),
                              builder: (context, state) {
                                if (state is AddingNewPost) {
                                  return const CircularProgressIndicator(
                                    color: AppColor.appPrimary,
                                  );
                                }
                                return ElevatedButton(
                                  onPressed: () {
                                    if (_image == null &&
                                        _titleController.text.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              "Please add a title or an image"),
                                        ),
                                      );
                                      return;
                                    }
                                    if (_image != null) {
                                      locator<NewPostBloc>().add(
                                        AddNewPost(
                                          title: _titleController.text,
                                          postType: 0,
                                          image: _image,
                                        ),
                                      );
                                    } else {
                                      locator<NewPostBloc>().add(
                                        AddNewPost(
                                          title: _titleController.text,
                                          postType: 1,
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColor.appPrimary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: Text(
                                    "Post",
                                    style: AppTextStyles.s14(
                                      color: AppColor.appSecondary,
                                      fontType: FontType.MEDIUM,
                                      isDesktop: true,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
