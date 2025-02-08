import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:monumento/application/profile/update_profile/update_profile_bloc.dart';
import 'package:monumento/domain/entities/user_entity.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/constants.dart';

class EditProfileWidget extends StatefulWidget {
  final UserEntity user;
  const EditProfileWidget({super.key, required this.user});

  @override
  State<EditProfileWidget> createState() => _EditProfileWidgetState();
}

class _EditProfileWidgetState extends State<EditProfileWidget> {
  late TextEditingController nameController;
  late TextEditingController usernameController;
  late TextEditingController statusController;
  Uint8List? image;

  @override
  void initState() {
    nameController = TextEditingController(text: widget.user.name);
    usernameController = TextEditingController(text: widget.user.username);
    statusController = TextEditingController(text: widget.user.status);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    var height = MediaQuery.sizeOf(context).height;
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: BlocConsumer<UpdateProfileBloc, UpdateProfileState>(
        bloc: locator<UpdateProfileBloc>(),
        listener: (context, state) {
          if (state is UpdateProfileLoading) {
            showDialog(
                context: context,
                builder: (context) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColor.appPrimary,
                      ),
                    ),
                  );
                });
          }
          if (state is UpdateProfileSuccess) {
            // dismiss the loading dialog
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.toString()),
              ),
            );
          }
          if (state is UpdateProfileFailure) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: height * 0.1),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    foregroundImage: image != null
                        ? MemoryImage(image!) as ImageProvider
                        : CachedNetworkImageProvider(widget.user.profilePictureUrl ??
                            defaultProfilePicture),
                  ),
                  const SizedBox(width: 50),
                  OutlinedButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final img = await picker
                          .pickImage(
                            source: ImageSource.gallery,
                          )
                          .then((value) => value!.readAsBytes());
                      setState(() {
                        image = img;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(
                          color: AppColor.appPrimary, width: 1),
                    ),
                    child: const Text(
                      'Change Profile Picture',
                      style: TextStyle(color: AppColor.appPrimary),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: width * 0.32,
                child: CustomTextField(
                  controller: nameController,
                  text: 'Name',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: width * 0.32,
                child: CustomTextField(
                  controller: usernameController,
                  text: 'Username',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: width * 0.32,
                child: CustomTextField(
                  controller: statusController,
                  text: 'Status',
                ),
              ),
              const SizedBox(height: 20),
              CustomElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty ||
                      usernameController.text.isNotEmpty ||
                      statusController.text.isNotEmpty ||
                      image != null) {
                    locator<UpdateProfileBloc>().add(UpdateUserDetailsDesktop(
                      userInfo: {
                        'name': nameController.text,
                        'username': usernameController.text,
                        'status': statusController.text,
                        'image': image != null ? image : null,
                        'shouldUpdateUsername':
                            usernameController.text != widget.user.username,
                      },
                    ));
                  }
                },
                text: 'Save Changes',
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  backgroundColor: AppColor.appPrimary,
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
