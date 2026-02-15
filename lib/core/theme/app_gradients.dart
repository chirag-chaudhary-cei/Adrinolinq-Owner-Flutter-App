import 'package:flutter/material.dart';

/// Application gradient definitions extracted from reference design
class AppGradients {
  AppGradients._();

  // ============================================================
  // PRIMARY GRADIENTS (Lime/Neon Green)
  // ============================================================

  /// Lime gradient for primary buttons and price tags
  static const LinearGradient lime = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFE5FF00),
      Color(0xFFD4FF00),
    ],
  );

  /// Lime horizontal gradient
  static const LinearGradient limeHorizontal = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFFD4FF00),
      Color(0xFFE5FF00),
    ],
  );

  // ============================================================
  // PURPLE GRADIENTS
  // ============================================================

  /// Purple gradient for secondary actions
  static const LinearGradient purple = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF9333EA),
      Color(0xFF7C3AED),
    ],
  );

  /// Purple horizontal gradient
  static const LinearGradient purpleHorizontal = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF7C3AED),
      Color(0xFF9333EA),
    ],
  );

  /// Purple action gradient for "See all" buttons
  static const LinearGradient purpleAction = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF9333EA),
      Color(0xFF7C3AED),
    ],
  );

  /// Purple button gradient
  static const LinearGradient purpleButton = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF9333EA),
      Color(0xFF7C3AED),
    ],
  );

  // ============================================================
  // CYAN/TEAL GRADIENTS
  // ============================================================

  /// Cyan gradient for card borders
  static const LinearGradient cyan = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2DD4BF),
      Color(0xFF14B8A6),
    ],
  );

  /// Cyan subtle gradient for glows
  static const LinearGradient cyanSubtle = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x4014B8A6),
      Color(0x2014B8A6),
    ],
  );

  // ============================================================
  // BROWN GRADIENTS (for card variants)
  // ============================================================

  /// Brown gradient for card borders
  static const LinearGradient brown = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFA0724B),
      Color(0xFF8B5A2B),
    ],
  );

  /// Brown subtle gradient for glows
  static const LinearGradient brownSubtle = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x408B5A2B),
      Color(0x208B5A2B),
    ],
  );

  // ============================================================
  // CARD GRADIENTS
  // ============================================================

  /// Dark card gradient
  static const LinearGradient cardDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E1E2E),
      Color(0xFF151520),
    ],
  );

  /// Glass gradient for glassmorphism effects
  static const LinearGradient glass = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x1AFFFFFF),
      Color(0x0DFFFFFF),
    ],
  );

  /// Glass overlay for content panels
  static const LinearGradient glassOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x00000000),
      Color(0x40000000),
      Color(0x80000000),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  // ============================================================
  // BACKGROUND GRADIENTS
  // ============================================================

  /// Main background gradient
  static const LinearGradient backgroundDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF030107),
      Color(0xFF13131A),
    ],
  );

  /// Background radial glow effect
  static const RadialGradient backgroundGlow = RadialGradient(
    center: Alignment.center,
    radius: 1.0,
    colors: [
      Color(0x206B00FF),
      Color(0x00030107),
    ],
  );

  // ============================================================
  // GLOW GRADIENTS
  // ============================================================

  /// Purple glow gradient
  static const RadialGradient purpleGlow = RadialGradient(
    center: Alignment.center,
    radius: 0.8,
    colors: [
      Color(0x407C3AED),
      Color(0x007C3AED),
    ],
  );

  /// Cyan glow gradient
  static const RadialGradient cyanGlow = RadialGradient(
    center: Alignment.center,
    radius: 0.8,
    colors: [
      Color(0x4014B8A6),
      Color(0x0014B8A6),
    ],
  );

  /// Lime glow gradient
  static const RadialGradient limeGlow = RadialGradient(
    center: Alignment.center,
    radius: 0.8,
    colors: [
      Color(0x40D4FF00),
      Color(0x00D4FF00),
    ],
  );

  // ============================================================
  // SHIMMER GRADIENT (for loading effects)
  // ============================================================

  /// Shimmer gradient for loading states
  static const LinearGradient shimmer = LinearGradient(
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
    colors: [
      Color(0xFF1E1E2E),
      Color(0xFF2A2A3E),
      Color(0xFF1E1E2E),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  // ============================================================
  // STATUS GRADIENTS
  // ============================================================

  /// Success gradient
  static const LinearGradient success = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF34D399),
      Color(0xFF10B981),
    ],
  );

  /// Warning gradient
  static const LinearGradient warning = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFBBF24),
      Color(0xFFF59E0B),
    ],
  );

  /// Error gradient
  static const LinearGradient error = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF87171),
      Color(0xFFEF4444),
    ],
  );
}
