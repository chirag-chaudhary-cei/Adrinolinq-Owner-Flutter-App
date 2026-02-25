import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors_new.dart';
import '../../../../core/theme/app_responsive.dart';
import '../../../../core/widgets/app_text_field_with_label.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../core/widgets/app_button.dart';
import 'register_password_page.dart';
import 'login_page.dart';
import '../providers/register_controller.dart';

class RegisterPersonalInfoPage extends ConsumerStatefulWidget {
  const RegisterPersonalInfoPage({super.key});

  @override
  ConsumerState<RegisterPersonalInfoPage> createState() =>
      _RegisterPersonalInfoPageState();
}

class _RegisterPersonalInfoPageState
    extends ConsumerState<RegisterPersonalInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController(text: "");
  final _lastNameController = TextEditingController(text: "");
  final _mobileController = TextEditingController(text: "");

  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  void _onCreateAccount() async {
    final errors = <String>[];

    final firstName = _firstNameController.text.trim();
    if (firstName.isEmpty) {
      errors.add('Please enter your first name');
    }

    final lastName = _lastNameController.text.trim();
    if (lastName.isEmpty) {
      errors.add('Please enter your last name');
    }

    final mobile = _mobileController.text.trim();
    if (mobile.isEmpty) {
      errors.add('Please enter your mobile number');
    } else if (mobile.length != 10) {
      errors.add('Mobile number must be exactly 10 digits');
    }

    if (errors.isNotEmpty) {
      AppDialogs.showValidationErrors(context, errors: errors);
      return;
    }

    setState(() => _isLoading = true);

    // Email/password are kept internally for backend contract, but registration is mobile+OTP driven.
    final controller = ref.read(registerControllerProvider.notifier);
    final success = await controller.generateOTP(mobile);

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RegisterPasswordPage(
              firstName: firstName,
              lastName: lastName,
              mobile: mobile,
            ),
          ),
        );
      } else {
        final state = ref.read(registerControllerProvider);
        if (state.errorMessage != null) {
          AppDialogs.showError(
            context,
            message: state.errorMessage!,
          );
        } else {
          AppDialogs.showError(
            context,
            message: 'Failed to send OTP. Please try again.',
          );
        }
      }
    }
  }

  void _onLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
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
                SizedBox(height: AppResponsive.sh(context, 85)),
                _buildHeader(context),
                SizedBox(height: AppResponsive.sh(context, 32)),
                _buildFormFields(context),
                SizedBox(height: AppResponsive.sh(context, 28)),
                _buildCreateAccountButton(context),
                SizedBox(height: AppResponsive.sh(context, 10)),
                _buildOrDivider(context),
                SizedBox(height: AppResponsive.sh(context, 10)),
                // _buildGoogleButton(context),
                // SizedBox(height: AppResponsive.sh(context, 10)),
                _buildLoginLink(context),
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
            fontSize: AppResponsive.font(context, 25),
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppResponsive.s(context, 8)),
        Text(
          'Create an account to save\nand let the games begin',
          style: TextStyle(
            fontSize: AppResponsive.font(context, 16),
            fontWeight: FontWeight.w500,
            color: Colors.black,
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
          controller: _firstNameController,
          label: 'First Name',
          hintText: 'First Name',
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          isRequired: true,
          autofillHints: const [AutofillHints.givenName],
        ),
        SizedBox(height: AppResponsive.s(context, 16)),
        AppTextFieldWithLabel(
          controller: _lastNameController,
          label: 'Last Name',
          hintText: 'Last Name',
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          isRequired: true,
          autofillHints: const [AutofillHints.familyName],
        ),
        SizedBox(height: AppResponsive.s(context, 16)),
        AppTextFieldWithLabel(
          controller: _mobileController,
          label: 'Mobile No.',
          hintText: 'Mobile No.',
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          isRequired: true,
          autofillHints: const [AutofillHints.telephoneNumber],
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          maxLength: 10,
          counterText: '',
          onFieldSubmitted: (_) => _onCreateAccount(),
        ),
      ],
    );
  }

  Widget _buildCreateAccountButton(BuildContext context) {
    return AppButton(
      text: 'Create an account',
      onPressed: _onCreateAccount,
      isLoading: _isLoading,
      width: double.infinity,
    );
  }

  Widget _buildOrDivider(BuildContext context) {
    return Center(
      child: Text(
        'Or',
        style: TextStyle(
          fontSize: AppResponsive.font(context, 16),
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: TextStyle(
            fontSize: AppResponsive.font(context, 16),
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        GestureDetector(
          onTap: _onLogin,
          child: Text(
            'Log in',
            style: TextStyle(
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
        text: 'By continuing, you agree to our\n',
        style: TextStyle(
          fontSize: AppResponsive.font(context, 12),
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
        children: [
          TextSpan(
            text: 'Privacy Policy',
            style: TextStyle(
              fontFamily: 'SFProRounded',
              fontSize: AppResponsive.font(context, 12),
              fontWeight: FontWeight.w500,
              color: AppColors.accentBlue,
            ),
          ),
          TextSpan(
            text: ' and ',
            style: TextStyle(
              fontSize: AppResponsive.font(context, 12),
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          TextSpan(
            text: 'Terms of Use',
            style: TextStyle(
              fontFamily: 'SFProRounded',
              fontSize: AppResponsive.font(context, 12),
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
