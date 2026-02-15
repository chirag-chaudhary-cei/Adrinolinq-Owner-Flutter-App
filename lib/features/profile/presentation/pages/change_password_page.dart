import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors_new.dart';
import '../../../../core/theme/app_responsive.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field_with_label.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/global_app_bar.dart';
import '../providers/profile_providers.dart';

/// Change Password Page
class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final _oldPasswordController = TextEditingController(text: '');
  final _newPasswordController = TextEditingController(text: '');
  final _confirmPasswordController = TextEditingController(text: '');

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateOldPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your current password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a new password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (value == _oldPasswordController.text) {
      return 'New password must be different from old password';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your new password';
    }
    if (value != _newPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (mounted) {
      AppLoading.showDialog(context, message: 'Changing password...');
    }

    try {
      final profileRepo = ref.read(profileRepositoryProvider);
      final response = await profileRepo.changePassword(
        _oldPasswordController.text,
        _newPasswordController.text,
      );

      if (!mounted) return;

      AppLoading.dismissDialog(context);

      if (response.success) {
        await AppDialogs.showSuccess(
          context,
          title: 'Success',
          message: response.message ?? 'Password changed successfully',
        );

        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        AppDialogs.showError(
          context,
          message: response.message ?? 'Failed to change password',
        );
      }
    } catch (e) {
      if (!mounted) return;

      Navigator.of(context).pop();

      AppDialogs.showError(
        context,
        message: e.toString().replaceFirst('Exception: ', ''),
      );
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
                      SizedBox(height: AppResponsive.sh(context, 60)),
                      _buildHeader(context),
                      SizedBox(height: AppResponsive.sh(context, 32)),
                      _buildFormFields(context),
                      SizedBox(height: AppResponsive.sh(context, 28)),
                      _buildActionButton(context),
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
          "Let's Change Password!",
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
          'Your new password must be different from\npreviously used passwords.',
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

  Widget _buildFormFields(BuildContext context) {
    return Column(
      children: [
        AppTextFieldWithLabel(
          controller: _oldPasswordController,
          label: 'Old Password',
          hintText: 'Enter your old password',
          obscureText: true,
          textInputAction: TextInputAction.next,
          validator: _validateOldPassword,
          autofillHints: const [AutofillHints.password],
        ),
        SizedBox(height: AppResponsive.s(context, 16)),
        AppTextFieldWithLabel(
          controller: _newPasswordController,
          label: 'New Password',
          hintText: 'Enter new password',
          obscureText: true,
          textInputAction: TextInputAction.next,
          validator: _validateNewPassword,
          autofillHints: const [AutofillHints.newPassword],
        ),
        SizedBox(height: AppResponsive.s(context, 16)),
        AppTextFieldWithLabel(
          controller: _confirmPasswordController,
          label: 'Confirm New Password',
          hintText: 'Confirm new password',
          obscureText: true,
          textInputAction: TextInputAction.done,
          validator: _validateConfirmPassword,
          autofillHints: const [AutofillHints.newPassword],
          onFieldSubmitted: (_) => _changePassword(),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return AppButton(
      onPressed: _changePassword,
      text: 'Change Password',
      width: double.infinity,
    );
  }
}
