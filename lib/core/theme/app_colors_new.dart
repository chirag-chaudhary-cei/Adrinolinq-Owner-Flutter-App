import 'package:flutter/material.dart';

/// Application color palette extracted from reference design
/// Supports both dark and light themes with Material Design 3
class AppColors {
  AppColors._();

  // ============================================================
  // PRIMARY COLORS (Lime/Neon Green from reference UI)
  // ============================================================
  static const Color primary = Color(0xFFCDFE00);
  static const Color primaryLight = Color(0xFFE0FF33);
  static const Color primaryDark = Color(0xFFB8E600);
  static const Color onPrimary = Color(0xFF1A1A1A);

  // ============================================================
  // SECONDARY COLORS (Purple accent)
  // ============================================================
  static const Color secondary = Color(0xFF7C3AED);
  static const Color secondaryLight = Color(0xFF9F67FF);
  static const Color secondaryDark = Color(0xFF5B21B6);
  static const Color onSecondary = Color(0xFFFFFFFF);

  // ============================================================
  // TERTIARY COLORS (Teal/Cyan)
  // ============================================================
  static const Color tertiary = Color(0xFF14B8A6);
  static const Color tertiaryLight = Color(0xFF2DD4BF);
  static const Color tertiaryDark = Color(0xFF0D9488);
  static const Color onTertiary = Color(0xFF1A1A1A);

  // ============================================================
  // BACKGROUND COLORS
  // ============================================================
  static const Color backgroundDark = Color(0xFF030107);
  static const Color backgroundDarkSecondary = Color(0xFF13131A);
  static const Color surfaceDark = Color(0xFF1A1A24);
  static const Color surfaceDarkVariant = Color(0xFF252535);

  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundLightSecondary = Color(0xFFF5F5F5);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceLightVariant = Color(0xFFF0F0F0);

  // ============================================================
  // CARD COLORS (Glassmorphism)
  // ============================================================
  static const Color cardBackgroundDark = Color(0xFF1E1E2E);
  static const Color cardBackgroundDarkLight = Color(0xFF252535);
  static const Color cardBorderDark = Color(0xFF2A2A3E);

  static const Color cardBackgroundLight = Color(0xFFFFFFFF);
  static const Color cardBackgroundLightVariant = Color(0xFFF8F8F8);
  static const Color cardBorderLight = Color(0xFFE0E0E0);

  // Glass effects
  static const Color glassBorder = Color(0x1AFFFFFF);
  static const Color glassBackground = Color(0x1A1E1E2E);
  static const Color glassHighlight = Color(0x0DFFFFFF);

  // ============================================================
  // CARD BORDER TINTS (from reference UI)
  // ============================================================
  static const Color cardBorderCyan = Color(0xFF14B8A6);
  static const Color cardBorderBrown = Color(0xFF8B5A2B);
  static const Color cardBorderPurple = Color(0xFF7C3AED);
  static const Color cardBorderPink = Color(0xFFEC4899);
  static const Color cardBorderOrange = Color(0xFFF59E0B);
  static const Color cardBorderBlue = Color(0xFF3B82F6);

  // ============================================================
  // TEXT COLORS
  // ============================================================
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB4B4C0);
  static const Color textTertiaryDark = Color(0xFF8E8E9A);
  static const Color textMutedDark = Color(0xFF6B6B7A);

  static const Color textPrimaryLight = Color(0xFF1A1A1A);
  static const Color textSecondaryLight = Color(0xFF4A4A5A);
  static const Color textTertiaryLight = Color(0xFF6B6B7A);
  static const Color textMutedLight = Color(0xFF9E9E9E);

  // ============================================================
  // ACCENT COLORS
  // ============================================================
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentBlue = Color(0xFF3E8EE9);
  static const Color accentOrange = Color(0xFFF59E0B);
  static const Color accentPink = Color(0xFFEC4899);
  static const Color accentTeal = Color(0xFF14B8A6);
  static const Color accentRed = Color(0xFFEF4444);

  // ============================================================
  // STATUS COLORS
  // ============================================================
  static const Color success = Color(0xFFB9DAFF);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ============================================================
  // PRICE TAG COLORS (Lime/Neon from reference)
  // ============================================================
  static const Color priceTag = Color(0xFFD4FF00);
  static const Color priceTagGradientStart = Color(0xFFE5FF00);
  static const Color priceTagGradientEnd = Color(0xFFD4FF00);

  // ============================================================
  // CATEGORY CHIP COLORS
  // ============================================================
  static const Color chipBackgroundDark = Color(0x4D1A1A24);
  static const Color chipTextDark = Color(0xFFFFFFFF);
  static const Color chipBackgroundLight = Color(0xFFF0F0F0);
  static const Color chipTextLight = Color(0xFF1A1A1A);

  // ============================================================
  // SEARCH BAR
  // ============================================================
  static const Color searchBackgroundDark = Color(0xFFFFFFFF);
  static const Color searchBorderDark = Color(0xFFE0E0E0);
  static const Color searchHintDark = Color(0xFF878688);
  static const Color searchIconDark = Color(0xFF878688);

  static const Color searchBackgroundLight = Color(0xFFFFFFFF);
  static const Color searchBorderLight = Color(0xFFE0E0E0);
  static const Color searchHintLight = Color(0xFF878688);
  static const Color searchIconLight = Color(0xFF6B6B7A);

  // ============================================================
  // DIVIDER COLORS
  // ============================================================
  static const Color dividerDark = Color(0xFF2A2A3E);
  static const Color dividerLight = Color(0xFFE0E0E0);

  // ============================================================
  // SHADOW COLORS
  // ============================================================
  static const Color shadowDark = Color(0x40000000);
  static const Color shadowPurple = Color(0x407C3AED);
  static const Color shadowCyan = Color(0x4014B8A6);
  static const Color shadowLime = Color(0x40D4FF00);

  // ============================================================
  // GRADIENT DEFINITIONS
  // ============================================================
  static const List<Color> limeGradient = [
    Color(0xFFE5FF00),
    Color(0xFFD4FF00),
  ];

  static const List<Color> purpleGradient = [
    Color(0xFF9333EA),
    Color(0xFF7C3AED),
  ];

  static const List<Color> cyanGradient = [
    Color(0xFF2DD4BF),
    Color(0xFF14B8A6),
  ];

  static const List<Color> cardGradientDark = [
    Color(0xFF1E1E2E),
    Color(0xFF151520),
  ];

  static const List<Color> glassGradient = [
    Color(0x1AFFFFFF),
    Color(0x0DFFFFFF),
  ];

  // ============================================================
  // BUTTON COLORS
  // ============================================================
  static const Color buttonPrimaryDark = Color(0xFFD4FF00);
  static const Color buttonSecondaryDark = Color(0xFF2A2A3E);
  static const Color buttonDisabledDark = Color(0xFF4A4A5A);

  static const Color buttonPrimaryLight = Color(0xFFD4FF00);
  static const Color buttonSecondaryLight = Color(0xFFE0E0E0);
  static const Color buttonDisabledLight = Color(0xFFBDBDBD);

  // ============================================================
  // ICON COLORS
  // ============================================================
  static const Color iconPrimaryDark = Color(0xFFFFFFFF);
  static const Color iconSecondaryDark = Color(0xFFB4B4C0);
  static const Color iconMutedDark = Color(0xFF6B6B7A);

  static const Color iconPrimaryLight = Color(0xFF1A1A1A);
  static const Color iconSecondaryLight = Color(0xFF4A4A5A);
  static const Color iconMutedLight = Color(0xFF9E9E9E);

  // ============================================================
  // SPORT CARD COLORS
  // ============================================================
  static const Color sportCardSelected = Color(0xFF9D4EFF);
  static const Color sportCardSelectedGlow = Color(0xFF7B2FD9);
  static const Color sportCardUnselected = Color(0xFF2A2640);
  static const Color sportCardBorder = Color(0xFF3D3656);
  static const Color sportCardSelectedBorder = Color(0xFF9D4EFF);

  // ============================================================
  // NOTIFICATION BADGE
  // ============================================================
  static const Color notificationBadge = Color(0xFFEF4444);

  // ============================================================
  // LEGACY SUPPORT (for backward compatibility)
  // ============================================================
  static const Color textPrimary = textPrimaryDark;
  static const Color textSecondary = textSecondaryDark;
  static const Color textTertiary = textTertiaryDark;
  static const Color textMuted = textMutedDark;
  static const Color cardBackground = cardBackgroundDark;
  static const Color cardBorder = cardBorderDark;
  static const Color searchBackground = searchBackgroundDark;
  static const Color searchBorder = searchBorderDark;
  static const Color searchHint = searchHintDark;
  static const Color searchIcon = searchIconDark;
  static const Color divider = dividerDark;
  static const Color buttonPrimary = buttonPrimaryDark;
  static const Color buttonSecondary = buttonSecondaryDark;
  static const Color buttonDisabled = buttonDisabledDark;
  static const Color iconPrimary = iconPrimaryDark;
  static const Color iconSecondary = iconSecondaryDark;
  static const Color iconMuted = iconMutedDark;
  static const Color chipBackground = chipBackgroundDark;
  static const Color chipText = chipTextDark;
  static const Color backgroundSecondary = backgroundDarkSecondary;
  static const Color accent = secondary;
}

/// Card border tint variants for different card styles
enum CardBorderTint {
  none,
  cyan,
  brown,
  purple,
  pink,
  orange,
  blue,
}

extension CardBorderTintExtension on CardBorderTint {
  Color get color {
    switch (this) {
      case CardBorderTint.none:
        return Colors.transparent;
      case CardBorderTint.cyan:
        return AppColors.cardBorderCyan;
      case CardBorderTint.brown:
        return AppColors.cardBorderBrown;
      case CardBorderTint.purple:
        return AppColors.cardBorderPurple;
      case CardBorderTint.pink:
        return AppColors.cardBorderPink;
      case CardBorderTint.orange:
        return AppColors.cardBorderOrange;
      case CardBorderTint.blue:
        return AppColors.cardBorderBlue;
    }
  }

  Color get glowColor {
    switch (this) {
      case CardBorderTint.none:
        return Colors.transparent;
      case CardBorderTint.cyan:
        return AppColors.cardBorderCyan.withValues(alpha: 0.3);
      case CardBorderTint.brown:
        return AppColors.cardBorderBrown.withValues(alpha: 0.3);
      case CardBorderTint.purple:
        return AppColors.cardBorderPurple.withValues(alpha: 0.3);
      case CardBorderTint.pink:
        return AppColors.cardBorderPink.withValues(alpha: 0.3);
      case CardBorderTint.orange:
        return AppColors.cardBorderOrange.withValues(alpha: 0.3);
      case CardBorderTint.blue:
        return AppColors.cardBorderBlue.withValues(alpha: 0.3);
    }
  }
}

/// Dark theme color scheme for Material Design 3
class AppDarkColors {
  AppDarkColors._();

  static ColorScheme get colorScheme => const ColorScheme.dark(
        brightness: Brightness.dark,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryDark,
        onPrimaryContainer: AppColors.textPrimaryDark,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryDark,
        onSecondaryContainer: AppColors.textPrimaryDark,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.tertiaryDark,
        onTertiaryContainer: AppColors.textPrimaryDark,
        error: AppColors.error,
        onError: AppColors.textPrimaryDark,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textPrimaryDark,
        surfaceContainerHighest: AppColors.surfaceDarkVariant,
        onSurfaceVariant: AppColors.textSecondaryDark,
        outline: AppColors.cardBorderDark,
        outlineVariant: AppColors.dividerDark,
        shadow: AppColors.shadowDark,
      );
}

/// Light theme color scheme for Material Design 3
class AppLightColors {
  AppLightColors._();

  static ColorScheme get colorScheme => const ColorScheme.light(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryLight,
        onPrimaryContainer: AppColors.textPrimaryLight,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryLight,
        onSecondaryContainer: AppColors.textPrimaryLight,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.tertiaryLight,
        onTertiaryContainer: AppColors.textPrimaryLight,
        error: AppColors.error,
        onError: AppColors.textPrimaryDark,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.textPrimaryLight,
        surfaceContainerHighest: AppColors.surfaceLightVariant,
        onSurfaceVariant: AppColors.textSecondaryLight,
        outline: AppColors.cardBorderLight,
        outlineVariant: AppColors.dividerLight,
        shadow: AppColors.shadowDark,
      );
}
