import 'package:flutter/material.dart';

import '../theme/app_colors_new.dart';
import '../theme/app_responsive.dart';
import 'app_loading.dart';

/// Global App Button Widget
/// Highly customizable button with support for colors, sizes, icons, and styles
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.leadingIcon,
    this.trailingIcon,
    this.width,
    this.height,
    this.enabled = true,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.fontWeight,
    this.borderColor,
    this.borderRadius,
    this.horizontalPadding,
    this.elevation,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final double? width;
  final double? height;
  final bool enabled;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? borderColor;
  final double? borderRadius;
  final double? horizontalPadding;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    final buttonHeight = height ?? AppResponsive.s(context, 50);
    final buttonBorderRadius = borderRadius ?? 28;
    final buttonPadding = horizontalPadding ?? 20;

    if (isOutlined) {
      final outlinedBgColor = backgroundColor ?? Colors.white;
      final outlinedTextColor = textColor ?? AppColors.textPrimaryLight;
      final outlinedBorderColor = borderColor ?? Colors.grey.shade300;

      return SizedBox(
        width: width,
        height: buttonHeight,
        child: OutlinedButton(
          onPressed: enabled && !isLoading ? onPressed : null,
          style: OutlinedButton.styleFrom(
            backgroundColor: outlinedBgColor,
            disabledBackgroundColor: outlinedBgColor.withOpacity(0.6),
            side: BorderSide(
              color: outlinedBorderColor,
              width: 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius:
                  AppResponsive.borderRadius(context, buttonBorderRadius),
            ),
            // elevation: buttonElevation,
            padding: AppResponsive.padding(context, horizontal: buttonPadding),
            overlayColor: Colors.transparent,
          ),
          child: _buildChild(context, textColor: outlinedTextColor),
        ),
      );
    }

    final filledBgColor = backgroundColor ?? AppColors.primary;
    final filledTextColor = textColor ?? Colors.black;

    return SizedBox(
      width: width,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: enabled && !isLoading ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: filledBgColor,
          foregroundColor: filledTextColor,
          disabledBackgroundColor: filledBgColor.withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius:
                AppResponsive.borderRadius(context, buttonBorderRadius),
          ),
          // elevation: buttonElevation,
          padding: AppResponsive.padding(context, horizontal: buttonPadding),
          // overlayColor: Colors.transparent,
        ),
        child: _buildChild(context, textColor: filledTextColor),
      ),
    );
  }

  Widget _buildChild(BuildContext context, {required Color textColor}) {
    if (isLoading) {
      return AppLoading.button(
        size: AppResponsive.s(context, 20),
        color: textColor,
      );
    }

    final buttonFontSize = fontSize ?? AppResponsive.font(context, 17);
    final buttonFontWeight = fontWeight ?? FontWeight.w600;
    final iconSize = AppResponsive.icon(context, 20);

    // If we have both leading and trailing icons, or just one, use expanded layout
    if (leadingIcon != null || trailingIcon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Leading icon or spacer for balance
          if (leadingIcon != null)
            Icon(
              leadingIcon,
              size: iconSize,
              color: textColor,
            )
          else if (trailingIcon != null)
            SizedBox(width: iconSize), // Balance spacer
          // Flexible center text
          Text(
            text,
            style: TextStyle(
              fontSize: buttonFontSize,
              fontWeight: buttonFontWeight,
              color: textColor,
            ),
          ),
          // Trailing icon or spacer for balance
          if (trailingIcon != null)
            Icon(
              trailingIcon,
              size: iconSize,
              color: textColor,
            )
          else if (leadingIcon != null)
            SizedBox(width: iconSize), // Balance spacer
        ],
      );
    }

    // Simple text only button
    return Text(
      text,
      style: TextStyle(
        fontSize: buttonFontSize,
        fontWeight: buttonFontWeight,
        color: textColor,
      ),
    );
  }
}

/// Back and Next button pair commonly used in wizards
class AppButtonPair extends StatelessWidget {
  const AppButtonPair({
    super.key,
    required this.onBack,
    required this.onNext,
    this.backText = 'Back',
    this.nextText = 'Next',
    this.showBack = true,
    this.isLoading = false,
    this.nextEnabled = true,
  });

  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final String backText;
  final String nextText;
  final bool showBack;
  final bool isLoading;
  final bool nextEnabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          AppResponsive.padding(context, horizontal: 24, top: 8, bottom: 16),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (showBack) ...[
              Expanded(
                child: AppButton(
                  text: backText,
                  onPressed: onBack,
                  isOutlined: true,
                  leadingIcon: Icons.chevron_left,
                  backgroundColor: const Color(0xFFE5E5E5),
                  textColor: Colors.black,
                  borderColor: Colors.transparent,
                ),
              ),
              SizedBox(width: AppResponsive.s(context, 16)),
            ],
            Expanded(
              child: AppButton(
                text: nextText,
                onPressed: onNext,
                isLoading: isLoading,
                trailingIcon: Icons.chevron_right,
                enabled: nextEnabled,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
