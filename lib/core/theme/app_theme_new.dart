import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors_new.dart';
import 'app_typography.dart';
import 'app_spacing.dart';

/// Main application theme with Material Design 3 support
/// Supports both dark and light themes with dynamic switching
class AppTheme {
  AppTheme._();

  /// Get the dark theme
  static ThemeData get darkTheme => _buildTheme(isDark: true);

  /// Get the light theme
  static ThemeData get lightTheme => _buildTheme(isDark: false);

  /// Build theme based on brightness
  static ThemeData _buildTheme({required bool isDark}) {
    final colorScheme =
        isDark ? AppDarkColors.colorScheme : AppLightColors.colorScheme;

    final backgroundColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final iconPrimary =
        isDark ? AppColors.iconPrimaryDark : AppColors.iconPrimaryLight;
    final dividerColor =
        isDark ? AppColors.dividerDark : AppColors.dividerLight;
    final cardBackground =
        isDark ? AppColors.cardBackgroundDark : AppColors.cardBackgroundLight;
    final cardBorder =
        isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight;

    return ThemeData(
      // Set global font family so individual styles don't need to specify it
      fontFamily: 'SFProRounded',
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundColor,
      textTheme: appTextTheme(),

      // ============================================================
      // APPBAR THEME
      // ============================================================
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        iconTheme: IconThemeData(
          color: iconPrimary,
          size: 24,
        ),
      ),

      // ============================================================
      // ELEVATED BUTTON THEME (Lime primary)
      // ============================================================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ============================================================
      // OUTLINED BUTTON THEME
      // ============================================================
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
          side: const BorderSide(
            color: AppColors.primary,
            width: AppSpacing.borderNormal,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ============================================================
      // TEXT BUTTON THEME
      // ============================================================
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ============================================================
      // FILLED BUTTON THEME
      // ============================================================
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
        ),
      ),

      // ============================================================
      // INPUT DECORATION THEME (White search bar from reference)
      // ============================================================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? AppColors.searchBackgroundDark
            : AppColors.searchBackgroundLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: BorderSide(
            color: isDark
                ? AppColors.searchBorderDark
                : AppColors.searchBorderLight,
            width: AppSpacing.borderNormal,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: BorderSide(
            color: isDark
                ? AppColors.searchBorderDark
                : AppColors.searchBorderLight,
            width: AppSpacing.borderNormal,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: AppSpacing.borderThick,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: AppSpacing.borderNormal,
          ),
        ),
        hintStyle: TextStyle(
          fontSize: 14,
          color: isDark ? AppColors.searchHintDark : AppColors.searchHintLight,
        ),
        labelStyle: TextStyle(
          fontSize: 14,
          color: textSecondary,
        ),
      ),

      // ============================================================
      // CARD THEME
      // ============================================================
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          side: BorderSide(
            color: cardBorder,
            width: AppSpacing.borderNormal,
          ),
        ),
      ),

      // ============================================================
      // CHIP THEME
      // ============================================================
      chipTheme: ChipThemeData(
        backgroundColor: isDark
            ? AppColors.chipBackgroundDark
            : AppColors.chipBackgroundLight,
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.chipTextDark : AppColors.chipTextLight,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
      ),

      // ============================================================
      // DIVIDER THEME
      // ============================================================
      dividerTheme: DividerThemeData(
        color: dividerColor,
        thickness: AppSpacing.dividerThickness,
        space: AppSpacing.lg,
      ),

      // ============================================================
      // ICON THEME
      // ============================================================
      iconTheme: IconThemeData(
        color: iconPrimary,
        size: AppSpacing.iconLg,
      ),

      // ============================================================
      // BOTTOM NAVIGATION BAR THEME
      // ============================================================
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: AppColors.primary,
        unselectedItemColor:
            isDark ? AppColors.iconMutedDark : AppColors.iconMutedLight,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // ============================================================
      // NAVIGATION BAR THEME (Material 3)
      // ============================================================
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceColor,
        indicatorColor: AppColors.primary.withValues(alpha: 0.2),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),

      // ============================================================
      // FLOATING ACTION BUTTON THEME
      // ============================================================
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // ============================================================
      // DIALOG THEME
      // ============================================================
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
      ),

      // ============================================================
      // BOTTOM SHEET THEME
      // ============================================================
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceColor,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXxl),
          ),
        ),
      ),

      // ============================================================
      // SNACKBAR THEME
      // ============================================================
      snackBarTheme: SnackBarThemeData(
        backgroundColor:
            isDark ? AppColors.surfaceDarkVariant : AppColors.textPrimaryLight,
        contentTextStyle: TextStyle(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryDark,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ============================================================
      // PROGRESS INDICATOR THEME
      // ============================================================
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.surfaceDarkVariant,
        circularTrackColor: AppColors.surfaceDarkVariant,
      ),

      // ============================================================
      // SWITCH THEME
      // ============================================================
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return isDark ? AppColors.iconMutedDark : AppColors.iconMutedLight;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary.withValues(alpha: 0.3);
          }
          return isDark
              ? AppColors.surfaceDarkVariant
              : AppColors.surfaceLightVariant;
        }),
      ),

      // ============================================================
      // SLIDER THEME
      // ============================================================
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: isDark
            ? AppColors.surfaceDarkVariant
            : AppColors.surfaceLightVariant,
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withValues(alpha: 0.2),
      ),

      // ============================================================
      // TOOLTIP THEME
      // ============================================================
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceDarkVariant
              : AppColors.textPrimaryLight,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        textStyle: TextStyle(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryDark,
          fontSize: 12,
        ),
      ),

      // ============================================================
      // PAGE TRANSITIONS
      // ============================================================
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        },
      ),

      // ============================================================
      // EXTENSIONS
      // ============================================================
      extensions: [
        AppThemeExtension(
          isDark: isDark,
          cardBorderTints: _buildCardBorderTints(),
        ),
      ],
    );
  }

  static Map<CardBorderTint, Color> _buildCardBorderTints() {
    return {
      CardBorderTint.none: Colors.transparent,
      CardBorderTint.cyan: AppColors.cardBorderCyan,
      CardBorderTint.brown: AppColors.cardBorderBrown,
      CardBorderTint.purple: AppColors.cardBorderPurple,
      CardBorderTint.pink: AppColors.cardBorderPink,
      CardBorderTint.orange: AppColors.cardBorderOrange,
      CardBorderTint.blue: AppColors.cardBorderBlue,
    };
  }
}

/// Theme extension for custom properties
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  const AppThemeExtension({
    required this.isDark,
    required this.cardBorderTints,
  });

  final bool isDark;
  final Map<CardBorderTint, Color> cardBorderTints;

  @override
  AppThemeExtension copyWith({
    bool? isDark,
    Map<CardBorderTint, Color>? cardBorderTints,
  }) {
    return AppThemeExtension(
      isDark: isDark ?? this.isDark,
      cardBorderTints: cardBorderTints ?? this.cardBorderTints,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) {
      return this;
    }
    return AppThemeExtension(
      isDark: t < 0.5 ? isDark : other.isDark,
      cardBorderTints: t < 0.5 ? cardBorderTints : other.cardBorderTints,
    );
  }
}

/// Extension to access theme extension easily
extension AppThemeExtensionX on ThemeData {
  AppThemeExtension get appExtension =>
      extension<AppThemeExtension>() ??
      const AppThemeExtension(
        isDark: true,
        cardBorderTints: {},
      );
}
