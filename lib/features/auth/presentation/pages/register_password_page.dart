import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors_new.dart';
import '../../../../core/theme/app_responsive.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_text_field_with_label.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/global_app_bar.dart';
import '../../data/models/register_request.dart';
import '../providers/register_controller.dart';
import '../providers/auth_providers.dart';

class RegisterPasswordPage extends ConsumerStatefulWidget {
  const RegisterPasswordPage({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.mobile,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String mobile;

  @override
  ConsumerState<RegisterPasswordPage> createState() =>
      _RegisterPasswordPageState();
}

class _RegisterPasswordPageState extends ConsumerState<RegisterPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController(text: "");
  final _confirmPasswordController = TextEditingController(text: "");
  final _otpController = TextEditingController();

  bool _isLoading = false;

  Timer? _otpTimer;
  int _remainingSeconds = 15;
  bool _canResend = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _startOtpTimer();
  }

  @override
  void dispose() {
    _otpTimer?.cancel();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _startOtpTimer() {
    setState(() {
      _remainingSeconds = 90;
      _canResend = false;
    });
    _otpTimer?.cancel();
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          _canResend = true;
        });
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _resendOtp() async {
    if (!_canResend || _isResending) return;

    setState(() => _isResending = true);

    try {
      final authRepo = await ref.read(authRepositoryProvider.future);
      await authRepo.registerOTP(widget.email);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP sent successfully!')),
        );
        _startOtpTimer();
      }
    } catch (e) {
      if (mounted) {
        AppDialogs.showError(
          context,
          message: 'Failed to resend OTP. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  void _onCreateAccount() async {
    final errors = <String>[];

    final password = _passwordController.text;
    if (password.isEmpty) {
      errors.add('Please enter a password');
    } else if (password.length < 8) {
      errors.add('Password must be at least 8 characters');
    }

    final confirmPassword = _confirmPasswordController.text;
    if (confirmPassword.isEmpty) {
      errors.add('Please confirm your password');
    } else if (password != confirmPassword) {
      errors.add('Passwords do not match');
    }

    final otp = _otpController.text;
    if (otp.isEmpty) {
      errors.add('Please enter the OTP');
    } else if (otp.length < 4) {
      errors.add('Please enter a valid OTP (at least 4 digits)');
    }

    if (errors.isNotEmpty) {
      AppDialogs.showValidationErrors(context, errors: errors);
      return;
    }

    setState(() => _isLoading = true);

    final controller = ref.read(registerControllerProvider.notifier);
    final request = RegisterRequest(
      firstName: widget.firstName,
      lastName: widget.lastName,
      email: widget.email,
      mobile: widget.mobile,
      password: password,
      otp: otp,
    );

    final success = await controller.register(request);

    if (mounted && success) {
      final authRepo = await ref.read(authRepositoryProvider.future);
      try {
        await authRepo.login(widget.email, password);

        final localStorage = LocalStorage.instance;
        await localStorage.setString('user_first_name', widget.firstName);
        await localStorage.setString('user_last_name', widget.lastName);
        await localStorage.setString('user_email', widget.email);
        await localStorage.setString('user_mobile', widget.mobile);

        await localStorage.setBool(
            AppConstants.keyRegistrationOnboardingPending, true,);

        if (!mounted) return;

        setState(() => _isLoading = false);

        await Navigator.of(context).pushNamedAndRemoveUntil(
          AppRouter.onboarding,
          (route) => false,
          arguments: {
            'firstName': widget.firstName,
            'lastName': widget.lastName,
            'email': widget.email,
            'mobile': widget.mobile,
          },
        );
      } catch (e) {
        setState(() => _isLoading = false);
        AppDialogs.showError(
          context,
          message:
              'Registration successful but auto-login failed. Please login manually.',
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } else {
      setState(() => _isLoading = false);

      if (mounted) {
        final state = ref.read(registerControllerProvider);
        if (state.errorMessage != null) {
          AppDialogs.showError(
            context,
            message: state.errorMessage!,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: AppResponsive.sh(context, 30)),
                      _buildHeader(context),
                      SizedBox(height: AppResponsive.sh(context, 32)),
                      _buildFormFields(context),
                      SizedBox(height: AppResponsive.sh(context, 28)),
                      _buildCreateAccountButton(context),
                      SizedBox(height: AppResponsive.sh(context, 32)),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
            color: AppColors.textPrimaryLight,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppResponsive.s(context, 8)),
        Text(
          'Create an account to save\nand let the games begin',
          style: TextStyle(
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
          controller: _passwordController,
          label: 'Password',
          hintText: 'Password',
          obscureText: true,
          textInputAction: TextInputAction.next,
          isRequired: true,
          autofillHints: const [AutofillHints.newPassword],
        ),
        SizedBox(height: AppResponsive.s(context, 16)),
        AppTextFieldWithLabel(
          controller: _confirmPasswordController,
          label: 'Confirm Password',
          hintText: 'Confirm Password',
          obscureText: true,
          textInputAction: TextInputAction.next,
          isRequired: true,
          autofillHints: const [AutofillHints.newPassword],
        ),
        SizedBox(height: AppResponsive.s(context, 16)),
        AppTextFieldWithLabel(
          controller: _otpController,
          label: 'Email OTP',
          hintText: 'Email OTP',
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          isRequired: true,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          onFieldSubmitted: (_) => _onCreateAccount(),
        ),
        SizedBox(height: AppResponsive.s(context, 8)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_canResend)
              GestureDetector(
                onTap: _isResending ? null : _resendOtp,
                child: Text(
                  _isResending ? 'Sending...' : 'Resend OTP',
                  style: TextStyle(
                    fontFamily: 'SFProRounded',
                    fontSize: AppResponsive.font(context, 14),
                    fontWeight: FontWeight.w600,
                    color: _isResending
                        ? AppColors.textMutedLight
                        : AppColors.accentBlue,
                  ),
                ),
              )
            else
              const SizedBox.shrink(),
            Text(
              _formatTime(_remainingSeconds),
              style: TextStyle(
                fontFamily: 'SFProRounded',
                fontSize: AppResponsive.font(context, 14),
                fontWeight: FontWeight.w500,
                color: AppColors.textMutedLight,
              ),
            ),
          ],
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
}
