import 'dart:io';

import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:monumento/application/authentication/login_register/login_register_bloc.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';

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
                          context.go('/');
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
                                  child: CircleAvatar(
                                    radius: 40,
                                    backgroundColor: AppColor.appGreyAccent,
                                    child: image != null
                                        ? Image.file(File(image!.path))
                                        : SvgPicture.asset(
                                            'assets/icons/ic_user.svg',
                                          ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 22,
                                ),
                                TextFormField(
                                  controller: nameController,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Name cannot be empty';
                                    }
                                    return null;
                                  },
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  decoration: InputDecoration(
                                    labelText: 'Name',
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: AppColor.appSecondary,
                                      ),
                                    ),
                                    floatingLabelStyle: AppTextStyles.s14(
                                      color: AppColor.appSecondary,
                                      fontType: FontType.MEDIUM,
                                    ),
                                    border: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: AppColor.appSecondaryBlack,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                TextFormField(
                                  controller: usernameController,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Username cannot be empty';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Username',
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: AppColor.appSecondary,
                                      ),
                                    ),
                                    floatingLabelStyle: AppTextStyles.s14(
                                      color: AppColor.appSecondary,
                                      fontType: FontType.MEDIUM,
                                    ),
                                    border: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: AppColor.appSecondaryBlack,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                TextFormField(
                                  controller: statusController,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Status cannot be empty';
                                    }
                                    return null;
                                  },
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  decoration: InputDecoration(
                                    labelText: 'Status',
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: AppColor.appSecondary,
                                      ),
                                    ),
                                    floatingLabelStyle: AppTextStyles.s14(
                                      color: AppColor.appSecondary,
                                      fontType: FontType.MEDIUM,
                                    ),
                                    border: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: AppColor.appSecondaryBlack,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                TextFormField(
                                  controller: emailController,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Email cannot be empty';
                                    } else if (!value.contains('@')) {
                                      return 'Invalid email';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: AppColor.appSecondary,
                                      ),
                                    ),
                                    floatingLabelStyle: AppTextStyles.s14(
                                      color: AppColor.appSecondary,
                                      fontType: FontType.MEDIUM,
                                    ),
                                    border: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: AppColor.appSecondaryBlack,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                TextFormField(
                                  controller: passwordController,
                                  obscureText: true,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Password cannot be empty';
                                    } else if (value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: AppColor.appSecondary,
                                      ),
                                    ),
                                    floatingLabelStyle: AppTextStyles.s14(
                                      color: AppColor.appSecondary,
                                      fontType: FontType.MEDIUM,
                                    ),
                                    border: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: AppColor.appSecondaryBlack,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 48,
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      backgroundColor: AppColor.appPrimary,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 20),
                                    ),
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
                                    child: Text(
                                      'Sign Up',
                                      style: AppTextStyles.s14(
                                        color: AppColor.appSecondary,
                                        fontType: FontType.MEDIUM,
                                      ),
                                    ),
                                  ),
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
