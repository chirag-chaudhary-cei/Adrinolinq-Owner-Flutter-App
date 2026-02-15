import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors_new.dart';
import '../../../../core/theme/app_responsive.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../core/widgets/app_text_field_with_label.dart';
import '../../../../core/widgets/global_app_bar.dart';
import '../../../../core/routing/app_router.dart';
import '../../domain/forgot_password_state.dart';
import '../providers/forgot_password_controller.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _hasReset = false;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      await AppDialogs.showError(
        context,
        title: 'Email Required',
        message: 'Please enter your email address',
      );
      return;
    }

    ref.read(forgotPasswordControllerProvider.notifier).sendOtp(email);
  }

  void _onVerifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty || otp.length < 4) {
      await AppDialogs.showError(
        context,
        title: 'Invalid OTP',
        message: 'Please enter a valid OTP',
      );
      return;
    }

    ref.read(forgotPasswordControllerProvider.notifier).verifyOtp(otp);
  }

  void _onResendOtp() {
    ref.read(forgotPasswordControllerProvider.notifier).resendOtp();
  }

  void _onResetPassword() async {
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    final errors = <String>[];

    if (newPassword.isEmpty) {
      errors.add('Please enter a new password');
    } else if (newPassword.length < 8) {
      errors.add('Password must be at least 8 characters');
    }

    if (confirmPassword.isEmpty) {
      errors.add('Please confirm your password');
    }

    if (newPassword != confirmPassword) {
      errors.add('Passwords do not match');
    }

    if (errors.isNotEmpty) {
      await AppDialogs.showValidationErrors(context, errors: errors);
      return;
    }

    final success = await ref
        .read(forgotPasswordControllerProvider.notifier)
        .resetPassword(newPassword, confirmPassword);

    if (success && mounted) {
      await AppDialogs.showSuccess(
        context,
        title: 'Password Reset Successful',
        message:
            'Your password has been reset. Please log in with your new password.',
      );
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRouter.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgotPasswordControllerProvider);

    if (!_hasReset) {
      _hasReset = true;
      if (state.currentStep != ForgotPasswordStep.emailInput) {
        Future(() {
          ref.read(forgotPasswordControllerProvider.notifier).reset();
        });
      }
    }

    ref.listen<ForgotPasswordState>(forgotPasswordControllerProvider,
        (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        AppDialogs.showError(
          context,
          title: 'Error',
          message: next.errorMessage!,
        );
        ref.read(forgotPasswordControllerProvider.notifier).clearError();
      }

      if (previous?.currentStep != next.currentStep &&
          next.currentStep == ForgotPasswordStep.passwordReset) {
        FocusScope.of(context).unfocus();
      }
    });

    return PopScope(
      canPop: state.currentStep == ForgotPasswordStep.emailInput,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        switch (state.currentStep) {
          case ForgotPasswordStep.passwordReset:
            ref.read(forgotPasswordControllerProvider.notifier).goToOtpStep();
            break;
          case ForgotPasswordStep.otpVerification:
            ref.read(forgotPasswordControllerProvider.notifier).goToEmailStep();
            break;
          case ForgotPasswordStep.emailInput:
            break;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              const GlobalAppBar(
                title: '',
                showBackButton: true,
                showDivider: false,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: AppResponsive.padding(context, horizontal: 50),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: AppResponsive.sh(context, 60)),
                      _buildHeader(context, state),
                      SizedBox(height: AppResponsive.sh(context, 32)),
                      _buildStepContent(context, state),
                      SizedBox(height: AppResponsive.sh(context, 28)),
                      _buildActionButton(context, state),
                      SizedBox(height: AppResponsive.sh(context, 32)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ForgotPasswordState state) {
    String title;
    String subtitle;

    switch (state.currentStep) {
      case ForgotPasswordStep.emailInput:
        title = "Let's Reset Password!";
        subtitle = 'Enter your email address and\nwe will send you an OTP';
        break;
      case ForgotPasswordStep.otpVerification:
        title = "Let's Reset Password!";
        subtitle = 'Enter the OTP sent to your email\nand verify your account';
        break;
      case ForgotPasswordStep.passwordReset:
        title = 'Create New Password';
        subtitle = 'Enter your new password\nand confirm it';
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
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
          subtitle,
          style: TextStyle(
            fontFamily: 'SFProRounded',
            fontSize: AppResponsive.font(context, 16),
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondaryLight,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStepContent(BuildContext context, ForgotPasswordState state) {
    switch (state.currentStep) {
      case ForgotPasswordStep.emailInput:
        return _buildEmailStep(context, state);
      case ForgotPasswordStep.otpVerification:
        return _buildOtpStep(context, state);
      case ForgotPasswordStep.passwordReset:
        return _buildPasswordStep(context, state);
    }
  }

  Widget _buildEmailStep(BuildContext context, ForgotPasswordState state) {
    return Column(
      children: [
        AppTextFieldWithLabel(
          controller: _emailController,
          label: 'Email Address',
          hintText: 'Enter your email',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.email],
          onFieldSubmitted: (_) => _onSendOtp(),
        ),
      ],
    );
  }

  Widget _buildOtpStep(BuildContext context, ForgotPasswordState state) {
    return Column(
      children: [
        AppTextFieldWithLabel(
          controller: _emailController,
          label: 'Email Address',
          hintText: 'Enter your email',
          keyboardType: TextInputType.emailAddress,
          readOnly: true,
          backgroundColor: const Color(0xFFEEEEEE),
        ),
        SizedBox(height: AppResponsive.s(context, 16)),
        AppTextFieldWithLabel(
          controller: _otpController,
          label: 'Email OTP',
          hintText: 'Enter the OTP',
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          onFieldSubmitted: (_) => _onVerifyOtp(),
        ),
        SizedBox(height: AppResponsive.s(context, 16)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Didn't receive the code? ",
              style: TextStyle(
                fontFamily: 'SFProRounded',
                fontSize: AppResponsive.font(context, 14),
                color: AppColors.textSecondaryLight,
              ),
            ),
            GestureDetector(
              onTap: state.canResendOtp ? _onResendOtp : null,
              child: Text(
                state.canResendOtp
                    ? 'Resend'
                    : 'Resend in ${state.resendCountdown}s',
                style: TextStyle(
                  fontFamily: 'SFProRounded',
                  fontSize: AppResponsive.font(context, 14),
                  fontWeight: FontWeight.w700,
                  color: state.canResendOtp
                      ? AppColors.accentBlue
                      : AppColors.textMutedLight,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPasswordStep(BuildContext context, ForgotPasswordState state) {
    return Column(
      children: [
        AppTextFieldWithLabel(
          controller: _newPasswordController,
          label: 'New Password',
          obscureText: true,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.newPassword],
          autofocus: false,
        ),
        SizedBox(height: AppResponsive.s(context, 16)),
        AppTextFieldWithLabel(
          controller: _confirmPasswordController,
          label: 'Confirm Password',
          obscureText: true,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.newPassword],
          autofocus: false,
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, ForgotPasswordState state) {
    late String buttonText;
    late VoidCallback onPressed;

    switch (state.currentStep) {
      case ForgotPasswordStep.emailInput:
        buttonText = 'Send OTP';
        onPressed = _onSendOtp;
        break;
      case ForgotPasswordStep.otpVerification:
        buttonText = 'Verify OTP';
        onPressed = _onVerifyOtp;
        break;
      case ForgotPasswordStep.passwordReset:
        buttonText = 'Reset Password';
        onPressed = _onResetPassword;
        break;
    }

    return AppButton(
      onPressed: onPressed,
      isLoading: state.isLoading,
      text: buttonText,
      width: double.infinity,
    );
  }
}
