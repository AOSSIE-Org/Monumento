import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:monumento/application/authentication/authentication_bloc.dart';
import 'package:monumento/application/profile/update_profile/update_profile_bloc.dart';
import 'package:monumento/gen/assets.gen.dart';
import 'package:monumento/presentation/settings/mobile/settings_view_mobile.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/constants.dart';
import 'package:monumento/utils/custom_mobile_appBar.dart';

class UpdateProfileScreenMobile extends StatefulWidget {
  const UpdateProfileScreenMobile({super.key});

  @override
  State<UpdateProfileScreenMobile> createState() =>
      _UpdateProfileScreenMobileState();
}

class _UpdateProfileScreenMobileState extends State<UpdateProfileScreenMobile> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController nameController;
  late TextEditingController usernameController;
  late TextEditingController statusController;
  bool isSeen = false;
  Uint8List? image;

  @override
  void initState() {
    emailController = TextEditingController();
    passwordController = TextEditingController();
    nameController = TextEditingController();
    usernameController = TextEditingController();
    statusController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    usernameController.dispose();
    statusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: CustomMobileAppBar(
          logoPath: Assets.mobile.logoUpdateProfile.path,
          actions: [
            IconButton(
              onPressed: () {
                SettingsBottomSheet().settingsBottomSheet(context);
              },
              icon: const Icon(
                Icons.settings_outlined,
                color: AppColor.appBlack,
              ),
            ),
          ],
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: AppColor.appBlack,
            ),
          ),
        ),
        body: BlocListener<UpdateProfileBloc, UpdateProfileState>(
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.toString()),
                  ),
                );
                context.pop();
              }
            },
            child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
              bloc: locator<AuthenticationBloc>(),
              builder: (context, authState) {
                authState as Authenticated;
                return Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final ImagePicker picker = ImagePicker();
                            final img = await picker
                                .pickImage(
                                  source: ImageSource.gallery,
                                )
                                .then((value) => value!.readAsBytes());
                            setState(() {
                              image = img;
                            });
                            image != null
                                ? showDialogAlertProfileImage(
                                    // ignore: use_build_context_synchronously
                                    context,
                                    "Update ProfilePic",
                                    image != null
                                        ? CircleAvatar(
                                            radius: 100,
                                            backgroundImage:
                                                MemoryImage(image!))
                                        : CircleAvatar(
                                            radius: 100,
                                            backgroundImage:
                                                CachedNetworkImageProvider(
                                              authState
                                                      .user.profilePictureUrl ??
                                                  defaultProfilePicture,
                                            ),
                                          ),
                                    image!,
                                  )
                                // File(image!.path))
                                : null;
                          },
                          child: Stack(children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: CachedNetworkImageProvider(
                                authState.user.profilePictureUrl ??
                                    defaultProfilePicture,
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                height: 25,
                                width: 25,
                                decoration: BoxDecoration(
                                    border:
                                        Border.all(color: AppColor.appWhite),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(15)),
                                    color: AppColor.appPrimary),
                                child: const Icon(
                                  Icons.photo_camera_outlined,
                                  size: 15,
                                ),
                              ),
                            )
                          ]),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        CustomListTile(
                          onClick: () {
                            showDialogAlert(
                              context,
                              "Update Name",
                              "Name",
                              nameController,
                              (value) {
                                if (value!.isEmpty) {
                                  return 'Name cannot be empty';
                                }
                                return null;
                              },
                            );
                          },
                          leadingIcon: CircleAvatar(
                              radius: 25,
                              backgroundImage: CachedNetworkImageProvider(
                                authState.user.profilePictureUrl ??
                                    defaultProfilePicture,
                              )),
                          title: "Name",
                          subtitle: authState.user.name,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        CustomListTile(
                          onClick: () {
                            showDialogAlert(context, "Update Username",
                                "Username", usernameController, (value) {
                              if (value!.isEmpty) {
                                return 'Username cannot be empty';
                              }
                              return null;
                            });
                          },
                          leadingIcon: const Icon(
                            Icons.person_outline_rounded,
                            size: 35,
                          ),
                          title: "Username",
                          subtitle: "@${authState.user.username!}",
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        CustomListTile(
                          onClick: () {
                            showDialogAlert(context, "Update Status", "Status",
                                statusController, (value) {
                              if (value!.isEmpty) {
                                return 'Status cannot be empty';
                              }
                              return null;
                            });
                          },
                          leadingIcon:
                              const Icon(Icons.badge_outlined, size: 35),
                          title: "Status",
                          subtitle: authState.user.status,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        CustomListTile(
                          onClick: () {
                            showDialogAlert(context, "Update Email", "Email",
                                emailController, (value) {
                              if (value!.isEmpty) {
                                return 'Email cannot be empty';
                              } else if (!value.contains('@')) {
                                return 'Invalid email';
                              }
                              return null;
                            });
                          },
                          leadingIcon: const Icon(Icons.mail_outline, size: 35),
                          title: "Email",
                          subtitle: authState.user.email,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        CustomListTile(
                          onClick: () {
                            showDialogAlert(
                              context,
                              "Update Password",
                              "Password",
                              passwordController,
                              (value) {
                                if (value!.isEmpty) {
                                  return 'Password cannot be empty';
                                } else if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            );
                          },
                          leadingIcon: const Icon(Icons.password, size: 35),
                          title: "Password",
                        ),
                      ],
                    ));
              },
            )));
  }
}

Future<void> showDialogAlert(
    BuildContext context,
    String heading,
    String placeholder,
    TextEditingController controller,
    String? Function(String?)? validateFunction) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(child: Text(heading)),
          content: CustomTextField(
            controller: controller,
            text: placeholder,
            validateFunction: validateFunction,
            autoValid: AutovalidateMode.onUserInteraction,
          ),
          actions: [
            CustomElevatedButton(
                onPressed: () {
                  context.pop();
                },
                text: "Cancel"),
            CustomElevatedButton(
                onPressed: () {
                  locator<UpdateProfileBloc>().add(UpdateUserDetails(
                      userInfo: {placeholder.toLowerCase(): controller.text}));
                  context.pop();
                },
                text: "Update")
          ],
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.only(bottom: 20),
        );
      });
}

Future<void> showDialogAlertProfileImage(BuildContext context, String heading,
    Widget profileImage, Uint8List image) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(child: Text(heading)),
          content: profileImage,
          actions: [
            CustomElevatedButton(
                onPressed: () {
                  context.pop();
                },
                text: "Cancel"),
            CustomElevatedButton(
                onPressed: () {
                  locator<UpdateProfileBloc>().add(UpdateUserDetails(
                      userInfo: {'profilePictureUrl': image}));
                  context.pop();
                },
                text: "Upload")
          ],
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.only(bottom: 20),
        );
      });
}
