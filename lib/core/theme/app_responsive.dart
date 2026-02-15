import 'package:flutter/material.dart';

/// Responsive utility class for consistent scaling across devices
/// Base design width: 390 (iPhone 14 Pro)
class AppResponsive {
  AppResponsive._();

  static const double _baseWidth = 390.0;
  static const double _baseHeight = 844.0;

  /// Get screen width percentage
  static double w(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * percentage;
  }

  /// Get screen height percentage
  static double h(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.height * percentage;
  }

  /// Scale pixel value based on screen width ratio
  static double s(BuildContext context, double px) {
    final screenWidth = MediaQuery.of(context).size.width;
    return px * (screenWidth / _baseWidth);
  }

  /// Scale radius value
  static double radius(BuildContext context, double px) {
    return s(context, px);
  }

  /// Scale icon size
  static double icon(BuildContext context, double px) {
    return s(context, px);
  }

  /// Scale padding value
  static double p(BuildContext context, double px) {
    return s(context, px);
  }

  /// Scale thickness (borders, dividers)
  static double thickness(BuildContext context, double px) {
    return s(context, px);
  }

  /// Scale font size
  static double font(BuildContext context, double px) {
    return s(context, px);
  }

  /// Scale height based on base height
  static double sh(BuildContext context, double px) {
    final screenHeight = MediaQuery.of(context).size.height;
    return px * (screenHeight / _baseHeight);
  }

  /// Get responsive EdgeInsets
  static EdgeInsets padding(
    BuildContext context, {
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    if (all != null) {
      return EdgeInsets.all(s(context, all));
    }
    return EdgeInsets.only(
      left: s(context, left ?? horizontal ?? 0),
      top: s(context, top ?? vertical ?? 0),
      right: s(context, right ?? horizontal ?? 0),
      bottom: s(context, bottom ?? vertical ?? 0),
    );
  }

  /// Get responsive symmetric EdgeInsets
  static EdgeInsets paddingSymmetric(
    BuildContext context, {
    double horizontal = 0,
    double vertical = 0,
  }) {
    return EdgeInsets.symmetric(
      horizontal: s(context, horizontal),
      vertical: s(context, vertical),
    );
  }

  /// Get responsive BorderRadius
  static BorderRadius borderRadius(BuildContext context, double px) {
    return BorderRadius.circular(radius(context, px));
  }

  /// Get responsive SizedBox width
  static SizedBox horizontalSpace(BuildContext context, double px) {
    return SizedBox(width: s(context, px));
  }

  /// Get responsive SizedBox height
  static SizedBox verticalSpace(BuildContext context, double px) {
    return SizedBox(height: s(context, px));
  }

  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide >= 600;
  }

  /// Check if device is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }

  /// Get device type
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return DeviceType.desktop;
    if (width >= 600) return DeviceType.tablet;
    return DeviceType.mobile;
  }
}

enum DeviceType { mobile, tablet, desktop }

/// Extension for easier access to responsive helpers
extension ResponsiveExtension on BuildContext {
  /// Scale pixel value
  double rs(double px) => AppResponsive.s(this, px);

  /// Scale radius
  double rRadius(double px) => AppResponsive.radius(this, px);

  /// Scale icon
  double rIcon(double px) => AppResponsive.icon(this, px);

  /// Scale padding
  double rPadding(double px) => AppResponsive.p(this, px);

  /// Scale font
  double rFont(double px) => AppResponsive.font(this, px);

  /// Scale thickness
  double rThickness(double px) => AppResponsive.thickness(this, px);

  /// Get responsive padding
  EdgeInsets rPaddingAll(double px) => AppResponsive.padding(this, all: px);

  /// Get responsive symmetric padding
  EdgeInsets rPaddingSymmetric({double horizontal = 0, double vertical = 0}) =>
      AppResponsive.paddingSymmetric(this,
          horizontal: horizontal, vertical: vertical,);

  /// Get responsive border radius
  BorderRadius rBorderRadius(double px) => AppResponsive.borderRadius(this, px);

  /// Horizontal space
  SizedBox rHSpace(double px) => AppResponsive.horizontalSpace(this, px);

  /// Vertical space
  SizedBox rVSpace(double px) => AppResponsive.verticalSpace(this, px);

  /// Check if tablet
  bool get isTablet => AppResponsive.isTablet(this);

  /// Check if desktop
  bool get isDesktop => AppResponsive.isDesktop(this);
}
