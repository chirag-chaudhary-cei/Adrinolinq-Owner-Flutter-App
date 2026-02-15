import 'package:flutter/material.dart';
import 'app_colors_new.dart';
import 'app_responsive.dart';

/// Application typography system with responsive sizing
/// Only includes commonly used text styles across multiple screens
class AppTypography {
  AppTypography._();

  // fontFamily is provided globally via ThemeData.fontFamily

  // ==================== HEADING STYLES ====================

  static TextStyle h1(BuildContext context, {Color? color}) => TextStyle(
        fontSize: AppResponsive.font(context, 32),
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle h2(BuildContext context, {Color? color}) => TextStyle(
        fontSize: AppResponsive.font(context, 24),
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle h3(BuildContext context, {Color? color}) => TextStyle(
        fontSize: AppResponsive.font(context, 20),
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle h4(BuildContext context, {Color? color}) => TextStyle(
        fontSize: AppResponsive.font(context, 18),
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.textPrimary,
      );

  // ==================== BODY STYLES ====================

  static TextStyle bodyLarge(BuildContext context, {Color? color}) => TextStyle(
        fontSize: AppResponsive.font(context, 16),
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle bodyMedium(BuildContext context, {Color? color}) =>
      TextStyle(
        fontSize: AppResponsive.font(context, 14),
        fontWeight: FontWeight.w400,
        color: color ?? AppColors.textSecondary,
      );

  static TextStyle bodySmall(BuildContext context, {Color? color}) => TextStyle(
        fontSize: AppResponsive.font(context, 12),
        fontWeight: FontWeight.w400,
        color: color ?? AppColors.textTertiary,
      );

  // ==================== LABEL STYLES ====================

  static TextStyle labelLarge(BuildContext context, {Color? color}) =>
      TextStyle(
        fontSize: AppResponsive.font(context, 14),
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle labelMedium(BuildContext context, {Color? color}) =>
      TextStyle(
        fontSize: AppResponsive.font(context, 12),
        fontWeight: FontWeight.w500,
        color: color ?? AppColors.textSecondary,
      );

  static TextStyle labelSmall(BuildContext context, {Color? color}) =>
      TextStyle(
        fontSize: AppResponsive.font(context, 10),
        fontWeight: FontWeight.w500,
        color: color ?? AppColors.textTertiary,
      );

  // ==================== BUTTON STYLES ====================

  static TextStyle buttonLarge(BuildContext context, {Color? color}) =>
      TextStyle(
        fontSize: AppResponsive.font(context, 16),
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle buttonMedium(BuildContext context, {Color? color}) =>
      TextStyle(
        fontSize: AppResponsive.font(context, 14),
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle buttonSmall(BuildContext context, {Color? color}) =>
      TextStyle(
        fontSize: AppResponsive.font(context, 12),
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.textPrimary,
      );

  // ==================== CAPTION STYLE ====================

  static TextStyle caption(BuildContext context, {Color? color}) => TextStyle(
        fontSize: AppResponsive.font(context, 11),
        fontWeight: FontWeight.w400,
        color: color ?? AppColors.textMuted,
      );
}

/// Common widget-specific text styles (used across multiple widgets)
class AppWidgetTypography {
  AppWidgetTypography._();

  // User Header
  static TextStyle username(BuildContext context, {Color? color}) => TextStyle(
        fontSize: AppResponsive.font(context, 15),
        fontWeight: FontWeight.w700,
        color: color ?? const Color(0xFF1A1A1A),
      );

  static TextStyle weatherBadge(BuildContext context, {Color? color}) =>
      TextStyle(
        fontSize: AppResponsive.font(context, 12),
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: color ?? const Color(0xFFB8B8B8),
      );

  // Section Headers
  static TextStyle sectionTitle(BuildContext context, {Color? color}) =>
      TextStyle(
        fontSize: AppResponsive.font(context, 22),
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.textPrimaryLight,
      );

  static TextStyle sectionAction(BuildContext context, {Color? color}) =>
      TextStyle(
        fontSize: AppResponsive.font(context, 16),
        fontWeight: FontWeight.w700,
        color: color ?? Colors.white,
      );

  // Search Bar
  static TextStyle searchInput(BuildContext context, {Color? color}) =>
      TextStyle(
        fontSize: AppResponsive.font(context, 14),
        fontWeight: FontWeight.w400,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle searchHint(BuildContext context, {Color? color}) =>
      TextStyle(
        fontSize: AppResponsive.font(context, 14),
        fontWeight: FontWeight.w400,
        color: color ?? AppColors.searchHint,
      );

  // Common Widget Elements
  static TextStyle viewDetailsButton(BuildContext context, {Color? color}) =>
      TextStyle(
        fontSize: AppResponsive.font(context, 12),
        fontWeight: FontWeight.w600,
        color: color ?? Colors.white,
      );

  static TextStyle eventTag(BuildContext context, {Color? color}) => TextStyle(
        fontSize: AppResponsive.font(context, 11),
        fontWeight: FontWeight.w500,
        color: color ?? Colors.white.withValues(alpha: 0.63),
      );
}

/// Common color definitions used in widgets
class AppWidgetColors {
  AppWidgetColors._();

  // Event card colors
  static const Color tealBorder = Color(0xFF14B8A6);
  static const Color glassPanelTop = Color(0xFF1E0446);
  static const Color glassPanelBottom = Color(0xFFDCDCDC);
  static const Color eventDateTime = Color(0xFFDFDFDF);
  static const Color tagBackground = Color(0xFF3A3A5A);
  static const Color categoryBackground = Color(0xFF1A1A2E);

  // Button colors
  static const Color purpleButtonStart = Color(0xFF9333EA);
  static const Color purpleButtonEnd = Color(0xFF7C3AED);

  // Action gradient colors
  static const Color purpleActionStart = Color(0xFF7F2BFF);
  static const Color purpleActionEnd = Color(0xFFA259FF);
}

/// TextTheme for Material theming
TextTheme appTextTheme() {
  // Note: These are fallback values. Prefer using AppTypography with context for responsive sizing.
  return const TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    displaySmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    titleLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
  );
}
