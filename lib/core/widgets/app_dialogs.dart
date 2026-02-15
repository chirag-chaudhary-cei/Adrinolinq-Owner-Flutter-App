import 'package:flutter/material.dart';

import '../theme/app_colors_new.dart';
import '../theme/app_responsive.dart';
import 'app_loading.dart';

/// Global dialog system for the application
/// Provides consistent, reusable dialogs matching app theme
class AppDialogs {
  AppDialogs._();

  /// Show error dialog with a single message
  static Future<void> showError(
    BuildContext context, {
    required String message,
    String? title,
    VoidCallback? onDismiss,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _AppDialog(
        type: _DialogType.error,
        title: title ?? 'Error',
        message: message,
        onDismiss: onDismiss,
      ),
    );
  }

  /// Show multiple validation errors in a list
  static Future<void> showValidationErrors(
    BuildContext context, {
    required List<String> errors,
    String? title,
  }) async {
    if (errors.isEmpty) return;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _AppDialog(
        type: _DialogType.error,
        title: title ?? 'Please fix the following',
        message: errors.join('\n• '),
        isBulletList: true,
      ),
    );
  }

  /// Show success dialog
  static Future<void> showSuccess(
    BuildContext context, {
    required String message,
    String? title,
    VoidCallback? onDismiss,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _AppDialog(
        type: _DialogType.success,
        title: title ?? 'Success',
        message: message,
        onDismiss: onDismiss,
      ),
    );
  }

  /// Show info dialog
  static Future<void> showInfo(
    BuildContext context, {
    required String message,
    String? title,
    VoidCallback? onDismiss,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _AppDialog(
        type: _DialogType.info,
        title: title ?? 'Info',
        message: message,
        onDismiss: onDismiss,
      ),
    );
  }

  /// Show confirmation dialog with two buttons
  static Future<bool?> showConfirmation(
    BuildContext context, {
    required String message,
    String? title,
    String? confirmText,
    String? cancelText,
    String? customImagePath,
    String? customGifPath,
  }) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _AppDialog(
        type: _DialogType.info,
        title: title ?? 'Confirm',
        message: message,
        confirmText: confirmText ?? 'Yes',
        cancelText: cancelText ?? 'No',
        customImagePath: customImagePath,
        customGifPath: customGifPath,
      ),
    );
  }

  /// Show delete confirmation dialog with styled UI
  static Future<bool?> showDeleteConfirmation(
    BuildContext context, {
    String? message,
    String? title,
    String? confirmText,
    String? cancelText,
  }) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => _DeleteConfirmDialog(
        title: title ?? 'Are you want to Delete?',
        message: message,
        confirmText: confirmText ?? 'Yes',
        cancelText: cancelText ?? 'Cancel',
      ),
    );
  }

  /// Show loading dialog
  /// @deprecated Use AppLoading.showDialog() instead
  static void showLoading(
    BuildContext context, {
    String message = 'Loading...',
  }) {
    // Redirect to AppLoading for consistency
    AppLoading.showDialog(context, message: message);
  }

  /// Dismiss loading dialog
  /// @deprecated Use AppLoading.dismissDialog() instead
  static void dismissLoading(BuildContext context) {
    AppLoading.dismissDialog(context);
  }
}

enum _DialogType { error, success, info }

class _AppDialog extends StatelessWidget {
  const _AppDialog({
    required this.type,
    required this.title,
    required this.message,
    this.onDismiss,
    this.confirmText,
    this.cancelText,
    this.isBulletList = false,
    this.customImagePath,
    this.customGifPath,
  });

  final _DialogType type;
  final String title;
  final String message;
  final VoidCallback? onDismiss;
  final String? confirmText;
  final String? cancelText;
  final bool isBulletList;
  final String? customImagePath;
  final String? customGifPath;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: AppResponsive.padding(
          context,
          horizontal: 24,
          vertical: 28,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppResponsive.borderRadius(context, 20),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              _buildIcon(context),
              SizedBox(height: AppResponsive.s(context, 16)),
              // Title
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'SFProRounded',
                  fontSize: AppResponsive.font(context, 20),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppResponsive.s(context, 12)),
              // Message
              Text(
                isBulletList ? '• $message' : message,
                style: TextStyle(
                  fontFamily: 'SFProRounded',
                  fontSize: AppResponsive.font(context, 15),
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondaryLight,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppResponsive.s(context, 24)),
              // Buttons
              _buildButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    // If custom image/gif is provided, show that instead
    if (customGifPath != null || customImagePath != null) {
      return SizedBox(
        width: AppResponsive.s(context, 120),
        height: AppResponsive.s(context, 120),
        child: Image.asset(
          customGifPath ?? customImagePath!,
          fit: BoxFit.contain,
        ),
      );
    }

    // Default icon behavior
    IconData iconData;
    Color iconColor;

    switch (type) {
      case _DialogType.error:
        iconData = Icons.error_outline_rounded;
        iconColor = AppColors.error;
        break;
      case _DialogType.success:
        iconData = Icons.check_circle_outline_rounded;
        iconColor = AppColors.success;
        break;
      case _DialogType.info:
        iconData = Icons.info_outline_rounded;
        iconColor = AppColors.accentBlue;
        break;
    }

    return Container(
      width: AppResponsive.s(context, 56),
      height: AppResponsive.s(context, 56),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        size: AppResponsive.icon(context, 32),
        color: iconColor,
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    // Two-button layout (confirmation dialog)
    if (confirmText != null && cancelText != null) {
      return Row(
        children: [
          Expanded(
            child: _buildButton(
              context,
              text: cancelText!,
              isPrimary: false,
              onTap: () => Navigator.of(context).pop(false),
            ),
          ),
          SizedBox(width: AppResponsive.s(context, 12)),
          Expanded(
            child: _buildButton(
              context,
              text: confirmText!,
              isPrimary: true,
              onTap: () {
                Navigator.of(context).pop(true);
                onDismiss?.call();
              },
            ),
          ),
        ],
      );
    }

    // Single button layout
    return _buildButton(
      context,
      text: 'OK',
      isPrimary: true,
      onTap: () {
        Navigator.of(context).pop();
        onDismiss?.call();
      },
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required String text,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: AppResponsive.s(context, 48),
      child: Material(
        color: isPrimary ? AppColors.primary : Colors.white,
        borderRadius: AppResponsive.borderRadius(context, 24),
        child: InkWell(
          onTap: onTap,
          borderRadius: AppResponsive.borderRadius(context, 24),
          child: Container(
            decoration: BoxDecoration(
              border: isPrimary
                  ? null
                  : Border.all(
                      color: const Color(0xFFE0E0E0),
                      width: AppResponsive.thickness(context, 1),
                    ),
              borderRadius: AppResponsive.borderRadius(context, 24),
            ),
            alignment: Alignment.center,
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'SFProRounded',
                fontSize: AppResponsive.font(context, 16),
                fontWeight: FontWeight.w600,
                color: isPrimary
                    ? AppColors.onPrimary
                    : AppColors.textPrimaryLight,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Delete confirmation dialog with red icon and styled buttons
class _DeleteConfirmDialog extends StatelessWidget {
  const _DeleteConfirmDialog({
    required this.title,
    this.message,
    required this.confirmText,
    required this.cancelText,
  });

  final String title;
  final String? message;
  final String confirmText;
  final String cancelText;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: AppResponsive.padding(
          context,
          horizontal: 24,
          vertical: 28,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppResponsive.borderRadius(context, 24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Red exclamation icon with circle background
            Container(
              width: AppResponsive.s(context, 64),
              height: AppResponsive.s(context, 64),
              decoration: const BoxDecoration(
                color: Color(0xFFFF4D6A),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.priority_high_rounded,
                size: AppResponsive.icon(context, 36),
                color: Colors.white,
              ),
            ),
            SizedBox(height: AppResponsive.s(context, 20)),
            // Title
            Text(
              title,
              style: TextStyle(
                fontFamily: 'SFProRounded',
                fontSize: AppResponsive.font(context, 18),
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              SizedBox(height: AppResponsive.s(context, 8)),
              Text(
                message!,
                style: TextStyle(
                  fontFamily: 'SFProRounded',
                  fontSize: AppResponsive.font(context, 14),
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            SizedBox(height: AppResponsive.s(context, 24)),
            // Buttons
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: AppResponsive.s(context, 48),
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(
                          color: Color(0xFFE0E0E0),
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppResponsive.borderRadius(context, 24),
                        ),
                      ),
                      child: Text(
                        cancelText,
                        style: TextStyle(
                          fontFamily: 'SFProRounded',
                          fontSize: AppResponsive.font(context, 16),
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppResponsive.s(context, 12)),
                Expanded(
                  child: SizedBox(
                    height: AppResponsive.s(context, 48),
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppResponsive.borderRadius(context, 24),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        confirmText,
                        style: TextStyle(
                          fontFamily: 'SFProRounded',
                          fontSize: AppResponsive.font(context, 16),
                          fontWeight: FontWeight.w600,
                          color: AppColors.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
