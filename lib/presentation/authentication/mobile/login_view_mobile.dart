import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:go_router/go_router.dart';
import 'package:monumento/application/authentication/login_register/login_register_bloc.dart';
import 'package:monumento/gen/assets.gen.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';
import 'package:monumento/utils/constants.dart';

class LoginViewMobile extends StatefulWidget {
  const LoginViewMobile({super.key});

  @override
  State<LoginViewMobile> createState() => _LoginViewMobileState();
}

class _LoginViewMobileState extends State<LoginViewMobile> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isSeen = false;

  @override
  void initState() {
    emailController = TextEditingController();
    passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColor.appBackground,
        body: Center(
          child: SizedBox(
            width: 411,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Assets.logoAuth.image(
                    height: 105,
                    width: 136,
                  ),
                  const SizedBox(
                    width: 390,
                    height: 40,
                  ),
                  Form(
                    key: formKey,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        width: 380,
                        child:
                            BlocListener<LoginRegisterBloc, LoginRegisterState>(
                          bloc: locator<LoginRegisterBloc>(),
                          listener: (context, state) {
                            if (state is LoginFailed) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Invalid email or password, please try again.",
                                    style: AppTextStyles.s14(
                                      color: AppColor.appWhite,
                                      fontType: FontType.MEDIUM,
                                    ),
                                  ),
                                  backgroundColor: AppColor.appSecondary,
                                ),
                              );
                            }
                          },
                          child: BlocBuilder<LoginRegisterBloc,
                              LoginRegisterState>(
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
                              if (state is SigninWithGoogleSuccess) {
                                while (context.canPop() == true) {
                                  context.pop();
                                }
                                context.push('/');
                              }
                              return Column(
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: SignInButton(
                                      padding: const EdgeInsets.all(4),
                                      Buttons.Google,
                                      onPressed: () {
                                        locator<LoginRegisterBloc>().add(
                                          LoginWithGooglePressed(),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  const Text(
                                    'Or',
                                    style: TextStyle(
                                      color: AppColor.appSecondaryBlack,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
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
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter password.';
                                        } else if (value.length < 6) {
                                          return 'Password must be at least 6 characters.';
                                        }
                                        return null;
                                      },
                                      autoValid:
                                          AutovalidateMode.onUserInteraction),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: TextButton(
                                      onPressed: () {
                                        context.push('/reset-password');
                                      },
                                      style: ButtonStyle(
                                        overlayColor: WidgetStateProperty.all(
                                          Colors.transparent,
                                        ),
                                      ),
                                      child: Text(
                                        'Forgot Password?',
                                        style: AppTextStyles.s14(
                                          color: AppColor.appSecondary,
                                          fontType: FontType.MEDIUM,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  SizedBox(
                                      width: double.infinity,
                                      child: CustomElevatedButton(
                                          onPressed: () {
                                            if (formKey.currentState!
                                                .validate()) {
                                              locator<LoginRegisterBloc>().add(
                                                LoginWithEmailPressed(
                                                  email: emailController.text,
                                                  password:
                                                      passwordController.text,
                                                ),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Please enter valid email and password',
                                                    style: AppTextStyles.s14(
                                                      color: AppColor.appWhite,
                                                      fontType: FontType.MEDIUM,
                                                    ),
                                                  ),
                                                  backgroundColor:
                                                      AppColor.appSecondary,
                                                ),
                                              );
                                            }
                                          },
                                          text: 'Login')),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Don\'t have an account?',
                                        style: AppTextStyles.s14(
                                          color: AppColor.appSecondaryBlack,
                                          fontType: FontType.REGULAR,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          context.push('/register');
                                        },
                                        style: ButtonStyle(
                                          overlayColor: WidgetStateProperty.all(
                                            Colors.transparent,
                                          ),
                                        ),
                                        child: Text(
                                          'Sign Up',
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
                ]),
          ),
        ));
  }
}
