import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:monumento/application/authentication/login_register/login_register_bloc.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';

class LoginViewDesktop extends StatefulWidget {
  const LoginViewDesktop({super.key});

  @override
  State<LoginViewDesktop> createState() => _LoginViewDesktopState();
}

class _LoginViewDesktopState extends State<LoginViewDesktop> {
  late TextEditingController emailController;
  late TextEditingController passwordController;

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
      backgroundColor: AppColor.appBackground,
      body: Form(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Card(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 50),
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
                      return Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: SignInButton(
                              padding: const EdgeInsets.all(4),
                              Buttons.GoogleDark,
                              onPressed: () {},
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
                          TextFormField(
                            controller: emailController,
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
                            height: 16,
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: TextButton(
                              onPressed: () {},
                              style: ButtonStyle(
                                overlayColor: MaterialStateProperty.all(
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                              ),
                              onPressed: () {
                                locator<LoginRegisterBloc>().add(
                                  LoginWithEmailPressed(
                                    email: emailController.text,
                                    password: passwordController.text,
                                  ),
                                );
                              },
                              child: Text(
                                'Login',
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
                                'Don\'t have an account?',
                                style: AppTextStyles.s14(
                                  color: AppColor.appSecondaryBlack,
                                  fontType: FontType.REGULAR,
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                style: ButtonStyle(
                                  overlayColor: MaterialStateProperty.all(
                                    Colors.transparent,
                                  ),
                                ),
                                child: Text(
                                  'Sign Up',
                                  style: AppTextStyles.s14(
                                    color: AppColor.appSecondary,
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
            )
          ],
        ),
      ),
    );
  }
}
