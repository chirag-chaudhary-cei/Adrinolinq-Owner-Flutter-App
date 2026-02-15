import 'dart:ui';
import 'package:flutter/material.dart';
import 'app_colors_new.dart';
import 'app_responsive.dart';

/// Glassmorphism utility class for creating frosted glass effects
class GlassMorphism {
  GlassMorphism._();

  /// Standard glass container decoration
  static BoxDecoration glassDecoration(
    BuildContext context, {
    double borderRadius = 16,
    double borderWidth = 1,
    Color? backgroundColor,
    Color? borderColor,
    double opacity = 0.1,
  }) {
    return BoxDecoration(
      borderRadius: AppResponsive.borderRadius(context, borderRadius),
      color: (backgroundColor ?? AppColors.cardBackground)
          .withValues(alpha: opacity),
      border: Border.all(
        color: borderColor ?? AppColors.glassBorder,
        width: AppResponsive.thickness(context, borderWidth),
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.shadowDark.withValues(alpha: 0.2),
          blurRadius: AppResponsive.s(context, 20),
          spreadRadius: AppResponsive.s(context, 0),
          offset: Offset(0, AppResponsive.s(context, 8)),
        ),
      ],
    );
  }

  /// Glass decoration with gradient border
  static BoxDecoration glassGradientDecoration(
    BuildContext context, {
    double borderRadius = 16,
    double opacity = 0.15,
  }) {
    return BoxDecoration(
      borderRadius: AppResponsive.borderRadius(context, borderRadius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.cardBackground.withValues(alpha: opacity + 0.05),
          AppColors.cardBackground.withValues(alpha: opacity),
        ],
      ),
      border: Border.all(
        color: AppColors.glassBorder,
        width: AppResponsive.thickness(context, 1),
      ),
    );
  }

  /// Card glass decoration with stronger effect
  static BoxDecoration cardGlassDecoration(
    BuildContext context, {
    double borderRadius = 20,
    bool hasImage = false,
  }) {
    return BoxDecoration(
      borderRadius: AppResponsive.borderRadius(context, borderRadius),
      color: hasImage ? null : AppColors.cardBackground.withValues(alpha: 0.6),
      border: Border.all(
        color: AppColors.glassBorder,
        width: AppResponsive.thickness(context, 1),
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.shadowDark.withValues(alpha: 0.3),
          blurRadius: AppResponsive.s(context, 24),
          spreadRadius: AppResponsive.s(context, 0),
          offset: Offset(0, AppResponsive.s(context, 12)),
        ),
      ],
    );
  }

  /// Blur filter for glass effect
  static ImageFilter blurFilter({double sigma = 10}) {
    return ImageFilter.blur(sigmaX: sigma, sigmaY: sigma);
  }
}

/// Glass container widget with blur effect
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.blur = 10,
    this.opacity = 0.1,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderColor,
    this.backgroundColor,
  });

  final Widget child;
  final double borderRadius;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color? borderColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: AppResponsive.borderRadius(context, borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: GlassMorphism.glassDecoration(
              context,
              borderRadius: borderRadius,
              opacity: opacity,
              borderColor: borderColor,
              backgroundColor: backgroundColor,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Glass card widget for event cards with image background
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.blur = 10,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.backgroundImage,
    this.gradientOverlay = true,
    this.onTap,
  });

  final Widget child;
  final double borderRadius;
  final double blur;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final ImageProvider? backgroundImage;
  final bool gradientOverlay;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: Material(
        color: Colors.transparent,
        borderRadius: AppResponsive.borderRadius(context, borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: AppResponsive.borderRadius(context, borderRadius),
          splashColor: AppColors.primary.withValues(alpha: 0.1),
          highlightColor: AppColors.primary.withValues(alpha: 0.05),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: AppResponsive.borderRadius(context, borderRadius),
              border: Border.all(
                color: AppColors.glassBorder,
                width: AppResponsive.thickness(context, 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowDark.withValues(alpha: 0.3),
                  blurRadius: AppResponsive.s(context, 20),
                  spreadRadius: 0,
                  offset: Offset(0, AppResponsive.s(context, 10)),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: AppResponsive.borderRadius(context, borderRadius),
              child: Stack(
                children: [
                  // Background image
                  if (backgroundImage != null)
                    Positioned.fill(
                      child: Image(
                        image: backgroundImage!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  // Gradient overlay
                  if (gradientOverlay)
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppColors.backgroundDark.withValues(alpha: 0.3),
                              AppColors.backgroundDark.withValues(alpha: 0.85),
                              AppColors.backgroundDark.withValues(alpha: 0.95),
                            ],
                            stops: const [0.0, 0.4, 0.7, 1.0],
                          ),
                        ),
                      ),
                    ),
                  // Content
                  Padding(
                    padding: padding ?? EdgeInsets.zero,
                    child: child,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Glass chip widget for tags/labels
class GlassChip extends StatelessWidget {
  const GlassChip({
    super.key,
    required this.label,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = 20,
    this.padding,
  });

  final String label;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ??
          AppResponsive.paddingSymmetric(
            context,
            horizontal: 12,
            vertical: 6,
          ),
      decoration: BoxDecoration(
        borderRadius: AppResponsive.borderRadius(context, borderRadius),
        color: (backgroundColor ?? AppColors.chipBackground)
            .withValues(alpha: 0.8),
        border: Border.all(
          color: AppColors.glassBorder,
          width: AppResponsive.thickness(context, 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: AppResponsive.icon(context, 14),
              color: textColor ?? AppColors.chipText,
            ),
            AppResponsive.horizontalSpace(context, 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: AppResponsive.font(context, 12),
              fontWeight: FontWeight.w500,
              color: textColor ?? AppColors.chipText,
            ),
          ),
        ],
      ),
    );
  }
}

/// Price tag with glass effect
class GlassPriceTag extends StatelessWidget {
  const GlassPriceTag({
    super.key,
    required this.price,
    this.currency = '\$',
  });

  final String price;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppResponsive.paddingSymmetric(
        context,
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        borderRadius: AppResponsive.borderRadius(context, 20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.limeGradient,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLime,
            blurRadius: AppResponsive.s(context, 12),
            spreadRadius: 0,
            offset: Offset(0, AppResponsive.s(context, 4)),
          ),
        ],
      ),
      child: Text(
        '$currency$price',
        style: TextStyle(
          fontSize: AppResponsive.font(context, 14),
          fontWeight: FontWeight.w700,
          color: AppColors.onPrimary,
        ),
      ),
    );
  }
}
