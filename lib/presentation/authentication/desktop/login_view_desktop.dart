import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:go_router/go_router.dart';
import 'package:monumento/application/authentication/login_register/login_register_bloc.dart';
import 'package:monumento/gen/assets.gen.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';
import 'package:monumento/utils/constants.dart';

class LoginViewDesktop extends StatefulWidget {
  const LoginViewDesktop({super.key});

  @override
  State<LoginViewDesktop> createState() => _LoginViewDesktopState();
}

class _LoginViewDesktopState extends State<LoginViewDesktop> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isObscure = true;

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
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 500,
              ),
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    Assets.desktop.logoDesktop.svg(width: 220),
                    const SizedBox(
                      height: 24,
                    ),
                    Center(
                      child: Card(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 50),
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
                                        isDesktop: true,
                                      ),
                                    ),
                                    backgroundColor: AppColor.appWarningRed,
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
                                  if (mounted) {
                                    context.pushReplacement('/');
                                  }
                                }
                                return Column(
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      child: SignInButton(
                                        padding: const EdgeInsets.all(4),
                                        Buttons.GoogleDark,
                                        onPressed: () {
                                          locator<LoginRegisterBloc>().add(
                                            LoginWithGooglePressed(),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 22,
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
                                      height: 22,
                                    ),
                                    CustomTextField(
                                        controller: emailController,
                                        text: 'Email',
                                        isDesktop: true,
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
                                      isDesktop: true,
                                      isSeen: isObscure,
                                      validateFunction: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter password.';
                                        } else if (value.length < 6) {
                                          return 'Password must be at least 6 characters.';
                                        }
                                        return null;
                                      },
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            isObscure = !isObscure;
                                          });
                                        },
                                        icon: Icon(isObscure
                                            ? Icons.visibility_off
                                            : Icons.visibility),
                                      ),
                                      autoValid:
                                          AutovalidateMode.onUserInteraction,
                                    ),
                                    const SizedBox(
                                      height: 16,
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
                                            isDesktop: true,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 48,
                                    ),
                                    SizedBox(
                                      width: double.infinity,
                                      child: CustomElevatedButton(
                                        isDesktop: true,
                                        onPressed: () {
                                          if (formKey.currentState!.validate()) {
                                            locator<LoginRegisterBloc>().add(
                                              LoginWithEmailPressed(
                                                email: emailController.text,
                                                password: passwordController.text,
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
                                                    isDesktop: true,
                                                  ),
                                                ),
                                                backgroundColor:
                                                    AppColor.appSecondary,
                                              ),
                                            );
                                          }
                                        },
                                        text: 'Login',
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 26,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Don\'t have an account?',
                                          style: AppTextStyles.s14(
                                            color: AppColor.appSecondaryBlack,
                                            fontType: FontType.REGULAR,
                                            isDesktop: true,
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
                                              isDesktop: true,
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
            ),
          ),
        ),
      ),
    );
  }
}
