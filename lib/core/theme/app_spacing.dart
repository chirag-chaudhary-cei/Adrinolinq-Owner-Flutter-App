/// Application spacing tokens following 4dp rhythm
class AppSpacing {
  AppSpacing._();

  // Base spacing values (multiples of 4)
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 40.0;
  static const double massive = 48.0;

  // Section spacing
  static const double sectionGap = 24.0;
  static const double listItemGap = 12.0;
  static const double cardGap = 16.0;

  // Screen padding
  static const double screenHorizontal = 20.0;
  static const double screenVertical = 16.0;
  static const double screenTop = 12.0;

  // Card padding
  static const double cardPadding = 16.0;
  static const double cardPaddingSmall = 12.0;

  // Component radius
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusXxl = 24.0;
  static const double radiusFull = 100.0;

  // Button dimensions
  static const double buttonHeight = 48.0;
  static const double buttonHeightSmall = 36.0;
  static const double buttonRadius = 12.0;

  // Input dimensions
  static const double inputHeight = 52.0;
  static const double inputRadius = 12.0;

  // Icon sizes
  static const double iconXs = 14.0;
  static const double iconSm = 16.0;
  static const double iconMd = 20.0;
  static const double iconLg = 24.0;
  static const double iconXl = 28.0;
  static const double iconXxl = 32.0;

  // Avatar sizes
  static const double avatarSm = 32.0;
  static const double avatarMd = 40.0;
  static const double avatarLg = 48.0;
  static const double avatarXl = 56.0;

  // Card dimensions
  static const double eventCardWidth = 280.0;
  static const double eventCardHeight = 320.0;

  // Elevation levels
  static const double elevationNone = 0.0;
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;
  static const double elevationHighest = 16.0;

  // Border widths
  static const double borderThin = 0.5;
  static const double borderNormal = 1.0;
  static const double borderThick = 2.0;

  // Divider
  static const double dividerThickness = 1.0;
}

/// Component-specific tokens
class AppTokens {
  AppTokens._();

  // Chip
  static const double chipHeight = 28.0;
  static const double chipPaddingH = 12.0;
  static const double chipPaddingV = 6.0;
  static const double chipRadius = 20.0;
  static const double chipIconSize = 14.0;

  // Search bar
  static const double searchBarHeight = 48.0;
  static const double searchBarRadius = 24.0;
  static const double searchBarIconSize = 20.0;

  // Section header
  static const double sectionHeaderHeight = 24.0;

  // User header
  static const double userHeaderAvatarSize = 48.0;
  static const double notificationIconSize = 24.0;

  // Event card
  static const double eventCardImageHeight = 160.0;
  static const double eventCardContentPadding = 16.0;
  static const double eventCardBorderRadius = 20.0;
  static const double priceTagHeight = 32.0;
}

// Animation classes moved to app_animations.dart
// Import from there: import 'app_animations.dart';
