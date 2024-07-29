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

class PostImage extends StatefulWidget {
  const PostImage({super.key});

  @override
  State<PostImage> createState() => _PostImageState();
}

class _PostImageState extends State<PostImage> {
  final TextEditingController titleController = TextEditingController();
  File? image;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
        height: MediaQuery.of(context).size.height * 1.0,
        child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          bloc: locator<AuthenticationBloc>(),
          builder: (context, state) {
            state as Authenticated;
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close_rounded)),
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
                            if (image != null) {
                              locator<NewPostBloc>().add(
                                AddNewPost(
                                  title: titleController.text,
                                  postType: 0,
                                  image: image,
                                ),
                              );
                            } else {
                              locator<NewPostBloc>().add(
                                AddNewPost(
                                  title: titleController.text,
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
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const Divider(
                  thickness: BorderSide.strokeAlignOutside,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: CachedNetworkImageProvider(state.user.profilePictureUrl ??
                              defaultProfilePicture),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        maxLines: null,
                        controller: titleController,
                        decoration: InputDecoration(
                          hintText: 'Write a comment...',
                          hintStyle: AppTextStyles.s14(
                            color: AppColor.appSecondary,
                            fontType: FontType.REGULAR,
                          ),
                          border: const UnderlineInputBorder(),
                        ),
                      ),
                      if (image != null)
                        const SizedBox(
                          height: 16,
                        ),
                      if (image != null)
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: FileImage(image!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      const SizedBox(
                        height: 16,
                      )
                    ],
                  ),
                ),
                
                Row(mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        var img = await ImagePicker()
                            .pickImage(source: ImageSource.gallery);
                        if (img != null) {
                          setState(() {
                            image = File(img.path);
                          });
                        }
                      },
                      child: Column(
                        children: [
                          const CircleAvatar(
                            child: Icon(Icons.add_photo_alternate_outlined),
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(
                            "Media",
                            style: AppTextStyles.s14(
                              color: AppColor.appSecondary,
                              fontType: FontType.MEDIUM,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    GestureDetector(
                      onTap: () async {
                        var img = await ImagePicker()
                            .pickImage(source: ImageSource.camera);
                        if (img != null) {
                          setState(() {
                            image = File(img.path);
                          });
                        }
                      },
                      child: Column(
                        children: [
                          const CircleAvatar(
                            child: Icon(Icons.camera_alt_outlined),
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(
                            "Camera",
                            style: AppTextStyles.s14(
                              color: AppColor.appSecondary,
                              fontType: FontType.MEDIUM,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            );
          },
        ));
  }
}

class NewPostBottomSheet {
  newPostBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) {
          return const PostImage();
        });
  }
}
