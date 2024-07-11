import 'dart:io';

import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:monumento/application/authentication/login_register/login_register_bloc.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';
import 'package:monumento/utils/constants.dart';

import 'widgets/sign_up_decider_widget.dart';

class SignUpViewDesktop extends StatefulWidget {
  const SignUpViewDesktop({super.key});

  @override
  State<SignUpViewDesktop> createState() => _SignUpViewDesktopState();
}

class _SignUpViewDesktopState extends State<SignUpViewDesktop>
    with AutomaticKeepAliveClientMixin<SignUpViewDesktop> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController nameController;
  late TextEditingController usernameController;
  late TextEditingController statusController;
  late PageController controller;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  XFile? image;
  bool isSeen = false;

  @override
  void initState() {
    emailController = TextEditingController();
    passwordController = TextEditingController();
    nameController = TextEditingController();
    usernameController = TextEditingController();
    statusController = TextEditingController();
    controller = PageController();
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    usernameController.dispose();
    statusController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColor.appBackground,
      body: Form(
        key: formKey,
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 64,
              ),
              SvgPicture.asset(
                'assets/desktop/logo_desktop.svg',
                width: 220,
              ),
              const Spacer(),
              Card(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 50),
                  width: 380,
                  child: BlocListener<LoginRegisterBloc, LoginRegisterState>(
                    bloc: locator<LoginRegisterBloc>(),
                    listener: (context, state) {
                      if (state is SignUpFailed) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                          ),
                        );
                      }
                      if (state is SigninWithGoogleFailed) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                          ),
                        );
                      }
                    },
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
                          SchedulerBinding.instance.addPostFrameCallback((_) {
                            context.go('/');
                          });
                        }
                        return ExpandablePageView(
                          pageSnapping: false,
                          physics: const NeverScrollableScrollPhysics(),
                          controller: controller,
                          children: [
                            SignUpDeciderWidget(
                              onSignUpWithEmailPressed: () {
                                controller.nextPage(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeIn,
                                );
                              },
                              onSignUpWithGooglePressed: () {
                                locator<LoginRegisterBloc>().add(
                                  LoginWithGooglePressed(),
                                );
                              },
                            ),
                            Column(
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
                                          backgroundImage:
                                              FileImage(File(image!.path)))
                                      : CircleAvatar(
                                          radius: 40,
                                          backgroundColor:
                                              AppColor.appGreyAccent,
                                          child: SvgPicture.asset(
                                            'assets/icons/ic_user.svg',
                                          ),
                                        ),
                                ),
                                const SizedBox(
                                  height: 22,
                                ),
                                CustomTextField(
                                    controller: nameController,
                                    text: 'Name',
                                    validateFunction: (value) {
                                      if (value!.isEmpty) {
                                        return 'Name cannot be empty';
                                      }
                                      return null;
                                    },
                                    autoValid:
                                        AutovalidateMode.onUserInteraction),
                                const SizedBox(
                                  height: 16,
                                ),
                                CustomTextField(
                                    controller: usernameController,
                                    text: 'Username',
                                    validateFunction: (value) {
                                      if (value!.isEmpty) {
                                        return 'Username cannot be empty';
                                      }
                                      return null;
                                    }),
                                const SizedBox(
                                  height: 16,
                                ),
                                CustomTextField(
                                    controller: statusController,
                                    text: 'Status',
                                    validateFunction: (value) {
                                      if (value!.isEmpty) {
                                        return 'Status cannot be empty';
                                      }
                                      return null;
                                    },
                                    autoValid:
                                        AutovalidateMode.onUserInteraction),
                                const SizedBox(
                                  height: 16,
                                ),
                                CustomTextField(
                                    controller: emailController,
                                    text: 'Email',
                                    validateFunction: (value) {
                                      if (value!.isEmpty) {
                                        return 'Email cannot be empty';
                                      } else if (!value.contains('@')) {
                                        return 'Invalid email';
                                      }
                                      return null;
                                    },
                                    autoValid:
                                        AutovalidateMode.onUserInteraction),
                                const SizedBox(
                                  height: 16,
                                ),
                                CustomTextField(
                                    controller: passwordController,
                                    text: 'Password',
                                    isSeen: isSeen,
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          isSeen = !isSeen;
                                        });
                                      },
                                      icon: Icon(!isSeen
                                          ? Icons.visibility_off
                                          : Icons.visibility),
                                    ),
                                    validateFunction: (value) {
                                      if (value!.isEmpty) {
                                        return 'Password cannot be empty';
                                      } else if (value.length < 6) {
                                        return 'Password must be at least 6 characters';
                                      }
                                      return null;
                                    },
                                    autoValid:
                                        AutovalidateMode.onUserInteraction),
                                const SizedBox(
                                  height: 48,
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: CustomElevatedButton(
                                      onPressed: () {
                                        if (formKey.currentState!.validate()) {
                                          locator<LoginRegisterBloc>().add(
                                            SignUpWithEmailPressed(
                                              email: emailController.text,
                                              password: passwordController.text,
                                              name: nameController.text,
                                              username: usernameController.text,
                                              status: statusController.text,
                                              profilePictureFile: image != null
                                                  ? File(image!.path)
                                                  : null,
                                            ),
                                          );
                                        }
                                      },
                                      text: 'Sign Up'),
                                ),
                                const SizedBox(
                                  height: 26,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Already have an account?',
                                      style: AppTextStyles.s14(
                                        color: AppColor.appSecondaryBlack,
                                        fontType: FontType.REGULAR,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        context.pop();
                                      },
                                      style: ButtonStyle(
                                        overlayColor: WidgetStateProperty.all(
                                          Colors.transparent,
                                        ),
                                      ),
                                      child: Text(
                                        'Login',
                                        style: AppTextStyles.s14(
                                          color: AppColor.appPrimary,
                                          fontType: FontType.MEDIUM,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
