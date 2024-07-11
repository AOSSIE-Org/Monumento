import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:monumento/application/authentication/login_register/login_register_bloc.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';
import 'package:monumento/utils/constants.dart';

class ResetPasswordViewDesktop extends StatefulWidget {
  const ResetPasswordViewDesktop({super.key});

  @override
  State<ResetPasswordViewDesktop> createState() =>
      _ResetPasswordViewDesktopState();
}

class _ResetPasswordViewDesktopState extends State<ResetPasswordViewDesktop> {
  late TextEditingController emailController;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  void initState() {
    emailController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appBackground,
      body: Form(
        key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 24,
            ),
            SvgPicture.asset(
              'assets/desktop/logo_desktop.svg',
              width: 220,
            ),
            const SizedBox(
              height: 24,
            ),
            Center(
              child: Card(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 50),
                  width: 380,
                  child: BlocListener<LoginRegisterBloc, LoginRegisterState>(
                    bloc: locator<LoginRegisterBloc>(),
                    listener: (context, state) {
                      if (state is ResetPasswordSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Password reset link has been sent to your email.',
                            ),
                          ),
                        );
                      } else if (state is ResetPasswordFailed) {
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
                        if (state is ResetPasswordSuccess) {
                          return Column(
                            children: [
                              Text(
                                  "Password rest link has been sent to your email ${emailController.text}."),
                              const SizedBox(
                                height: 38,
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: CustomElevatedButton(
                                    onPressed: () {
                                      context.pop();
                                    },
                                    text: 'Back to Login'),
                              ),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            CustomTextField(
                                controller: emailController,
                                text: 'Email',
                                validateFunction: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter email.';
                                  } else if (!value.contains('@')) {
                                    return 'Please enter a valid email.';
                                  }
                                  return null;
                                },
                                autoValid: AutovalidateMode.onUserInteraction),
                            const SizedBox(
                              height: 38,
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: CustomElevatedButton(
                                  onPressed: () {
                                    if (formKey.currentState!.validate()) {
                                      locator<LoginRegisterBloc>().add(
                                        ResetPasswordButtonPressed(
                                          email: emailController.text,
                                        ),
                                      );
                                    }
                                  },
                                  text: 'Reset Password'),
                            ),
                            const SizedBox(
                              height: 26,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Don\'t want to reset anymore?',
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
                                    'Go back',
                                    style: AppTextStyles.s14(
                                      color: AppColor.appPrimary,
                                      fontType: FontType.MEDIUM,
                                    ),
                                  ),
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
            )
          ],
        ),
      ),
    );
  }
}
