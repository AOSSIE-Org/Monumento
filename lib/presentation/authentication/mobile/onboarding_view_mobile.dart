import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:monumento/application/authentication/login_register/login_register_bloc.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/constants.dart';

class OnboardingViewMobile extends StatefulWidget {
  const OnboardingViewMobile({super.key});

  @override
  State<OnboardingViewMobile> createState() => _OnboardingViewMobileState();
}

class _OnboardingViewMobileState extends State<OnboardingViewMobile> {
  late TextEditingController nameController;
  late TextEditingController usernameController;
  late TextEditingController statusController;
  late PageController controller;
  XFile? image;

  @override
  void initState() {
    nameController = TextEditingController();
    usernameController = TextEditingController();
    statusController = TextEditingController();
    controller = PageController();
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    statusController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColor.appBackground,
      body: Form(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Spacer(),
              SvgPicture.asset(
                'assets/desktop/logo_desktop.svg',
                width: 220,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 80),
                width: 380,
                child: BlocBuilder<LoginRegisterBloc, LoginRegisterState>(
                  bloc: locator<LoginRegisterBloc>(),
                  builder: (context, state) {
                    if (state is LoginRegisterLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColor.appPrimary,
                          ),
                        ),
                      );
                    }
                    if (state is SignUpSuccess) {
                      context.go('/');
                    }
                    return Column(
                      children: [
                        InkWell(
                          onTap: () async {
                            final ImagePicker picker = ImagePicker();
                            final img = await picker.pickImage(
                              source: ImageSource.gallery,
                            );
                            setState(() {
                              image = img;
                            });
                          },
                          child: image != null
                              ? CircleAvatar(
                                  radius: 40,
                                  backgroundImage: FileImage(File(image!.path)))
                              : CircleAvatar(
                                  radius: 40,
                                  backgroundColor: AppColor.appGreyAccent,
                                  child: SvgPicture.asset(
                                    'assets/icons/ic_user.svg',
                                  ),
                                ),
                        ),
                        const SizedBox(
                          height: 22,
                        ),
                        CustomTextField(
                            controller: nameController, text: 'Name'),
                        const SizedBox(
                          height: 16,
                        ),
                        CustomTextField(
                            controller: usernameController, text: 'Username'),
                        const SizedBox(
                          height: 16,
                        ),
                        CustomTextField(
                            controller: statusController, text: 'Status'),
                        const SizedBox(
                          height: 48,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: CustomElevatedButton(
                              onPressed: () {
                                locator<LoginRegisterBloc>().add(
                                  SaveOnboardingDetails(
                                    name: nameController.text,
                                    status: statusController.text,
                                    username: usernameController.text,
                                  ),
                                );
                              },
                              text: 'Continue'),
                        ),
                        const SizedBox(
                          height: 26,
                        ),
                      ],
                    );
                  },
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
