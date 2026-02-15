import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors_new.dart';
import '../../../../core/theme/app_responsive.dart';
import '../../../../core/widgets/app_text_field_with_label.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/routing/app_router.dart';
import '../providers/auth_providers.dart';
import 'register_personal_info_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailOrMobileController = TextEditingController(text: '');
  final _passwordController = TextEditingController(text: '');

  bool _isLoading = false;

  @override
  void dispose() {
    _emailOrMobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSignIn() async {
    final errors = <String>[];

    final emailOrMobile = _emailOrMobileController.text.trim();
    if (emailOrMobile.isEmpty) {
      errors.add('Please enter your email or mobile number');
    }

    final password = _passwordController.text;
    if (password.isEmpty) {
      errors.add('Please enter your password');
    }

    if (errors.isNotEmpty) {
      AppDialogs.showValidationErrors(context, errors: errors);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authRepo = await ref.read(authRepositoryProvider.future);
      await authRepo.login(emailOrMobile, password);

      setState(() => _isLoading = false);

      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRouter.home,
          (route) => false,
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);

      if (mounted) {
        AppDialogs.showError(
          context,
          message: e.toString().replaceFirst('Exception: ', ''),
          title: 'Login Failed',
        );
      }
    }
  }

  void _onGoogleSignIn() {
    // TODO: Implement Google Sign-In
  }

  void _onSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RegisterPersonalInfoPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppResponsive.padding(context, horizontal: 50),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: AppResponsive.sh(context, 100)),
                _buildHeader(context),
                SizedBox(height: AppResponsive.sh(context, 32)),
                _buildFormFields(context),
                SizedBox(height: AppResponsive.sh(context, 28)),
                _buildSignInButton(context),
                SizedBox(height: AppResponsive.sh(context, 10)),
                _buildOrDivider(context),
                SizedBox(height: AppResponsive.sh(context, 10)),
                // _buildGoogleButton(context),
                // SizedBox(height: AppResponsive.sh(context, 20)),
                _buildSignUpLink(context),
                SizedBox(height: AppResponsive.sh(context, 20)),
                _buildPrivacyPolicy(context),
                SizedBox(height: AppResponsive.sh(context, 24)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Let's get you set up!",
          style: TextStyle(
            fontFamily: 'SFProRounded',
            fontSize: AppResponsive.font(context, 25),
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryLight,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppResponsive.s(context, 8)),
        Text(
          'Create an account to save\nand let the games begin',
          style: TextStyle(
            fontFamily: 'SFProRounded',
            fontSize: AppResponsive.font(context, 16),
            fontWeight: FontWeight.w400,
            color: Colors.black,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFormFields(BuildContext context) {
    return Column(
      children: [
        AppTextFieldWithLabel(
          controller: _emailOrMobileController,
          label: 'Email/Mobile No.',
          hintText: 'Email/Mobile No.',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          isRequired: true,
          autofillHints: const [
            AutofillHints.email,
            AutofillHints.telephoneNumber,
          ],
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9@.a-zA-Z_-]')),
            LengthLimitingTextInputFormatter(50),
          ],
        ),
        SizedBox(height: AppResponsive.s(context, 16)),
        AppTextFieldWithLabel(
          controller: _passwordController,
          label: 'Password',
          hintText: 'Password',
          obscureText: true,
          textInputAction: TextInputAction.done,
          isRequired: true,
          autofillHints: const [AutofillHints.password],
          onFieldSubmitted: (_) => _onSignIn(),
        ),
        SizedBox(height: AppResponsive.s(context, 12)),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRouter.forgotPassword),
            child: Text(
              'Forgot Password?',
              style: TextStyle(
                fontFamily: 'SFProRounded',
                fontSize: AppResponsive.font(context, 14),
                fontWeight: FontWeight.w600,
                color: AppColors.accentBlue,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignInButton(BuildContext context) {
    return AppButton(
      text: 'Sign in',
      onPressed: _onSignIn,
      isLoading: _isLoading,
      width: double.infinity,
    );
  }

  Widget _buildOrDivider(BuildContext context) {
    return Center(
      child: Text(
        'Or',
        style: TextStyle(
          fontFamily: 'SFProRounded',
          fontSize: AppResponsive.font(context, 16),
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryLight,
        ),
      ),
    );
  }

  Widget _buildGoogleButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppResponsive.s(context, 50),
      child: OutlinedButton(
        onPressed: _onGoogleSignIn,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide(
            color: const Color(0xFF000000),
            width: AppResponsive.thickness(context, 2),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppResponsive.borderRadius(context, 28),
          ),
          overlayColor: Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildGoogleLogo(context),
            SizedBox(width: AppResponsive.s(context, 12)),
            Text(
              'continue with google',
              style: TextStyle(
                fontSize: AppResponsive.font(context, 16),
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleLogo(BuildContext context) {
    final size = AppResponsive.s(context, 20);
    return SizedBox(
      width: size,
      height: size,
      child: SvgPicture.asset(
        'assets/icons/google-icon.svg',
        width: size,
        height: size,
      ),
    );
  }

  Widget _buildSignUpLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(
            fontFamily: 'SFProRounded',
            fontSize: AppResponsive.font(context, 16),
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondaryLight,
          ),
        ),
        GestureDetector(
          onTap: _onSignUp,
          child: Text(
            'Sign up',
            style: TextStyle(
              fontFamily: 'SFProRounded',
              fontSize: AppResponsive.font(context, 16),
              fontWeight: FontWeight.w900,
              color: AppColors.accentBlue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacyPolicy(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: 'Be continuing, you agree to our\n',
        style: TextStyle(
          fontFamily: 'SFProRounded',
          fontSize: AppResponsive.font(context, 13),
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimaryLight,
        ),
        children: [
          TextSpan(
            text: 'Privacy Policy',
            style: TextStyle(
              fontFamily: 'SFProRounded',
              fontSize: AppResponsive.font(context, 13),
              fontWeight: FontWeight.w500,
              color: AppColors.accentBlue,
            ),
          ),
          TextSpan(
            text: ' and ',
            style: TextStyle(
              fontFamily: 'SFProRounded',
              fontSize: AppResponsive.font(context, 13),
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimaryLight,
            ),
          ),
          TextSpan(
            text: 'Terms of Use',
            style: TextStyle(
              fontFamily: 'SFProRounded',
              fontSize: AppResponsive.font(context, 13),
              fontWeight: FontWeight.w500,
              color: AppColors.accentBlue,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
