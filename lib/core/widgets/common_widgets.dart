import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/app_animations.dart';
import '../theme/app_gradients.dart';
import '../theme/app_responsive.dart';
import '../theme/app_typography.dart';

/// Reusable gradient text widget
class GradientText extends StatelessWidget {
  const GradientText({
    super.key,
    required this.text,
    required this.gradient,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final LinearGradient gradient;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(bounds),
      child: Text(
        text,
        style: style?.copyWith(color: Colors.white) ??
            const TextStyle(color: Colors.white),
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}

/// Reusable gradient icon widget
class GradientIcon extends StatelessWidget {
  const GradientIcon({
    super.key,
    required this.icon,
    required this.gradient,
    this.size,
  });

  final IconData icon;
  final LinearGradient gradient;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(bounds),
      child: Icon(
        icon,
        size: size,
        color: Colors.white,
      ),
    );
  }
}

/// Reusable glassmorphism container
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.blurSigma = 10,
    this.padding,
    this.width,
    this.height,
  });

  final Widget child;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double blurSigma;
  final EdgeInsets? padding;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: borderRadius ?? BorderRadius.circular(16),
            color: backgroundColor ?? Colors.white.withValues(alpha: 0.1),
            border:
                borderColor != null ? Border.all(color: borderColor!) : null,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Reusable purple gradient button
class PurpleGradientButton extends StatefulWidget {
  const PurpleGradientButton({
    super.key,
    required this.text,
    required this.onTap,
    this.padding,
    this.borderRadius,
    this.fontSize,
    this.showShadow = true,
  });

  final String text;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final double? borderRadius;
  final double? fontSize;
  final bool showShadow;

  @override
  State<PurpleGradientButton> createState() => _PurpleGradientButtonState();
}

class _PurpleGradientButtonState extends State<PurpleGradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDurations.buttonPress,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.standard),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          padding: widget.padding ??
              AppResponsive.paddingSymmetric(
                context,
                horizontal: 20,
                vertical: 10,
              ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              widget.borderRadius ?? AppResponsive.radius(context, 12),
            ),
            gradient: AppGradients.purpleButton,
            boxShadow: widget.showShadow
                ? [
                    BoxShadow(
                      color: AppWidgetColors.purpleButtonEnd
                          .withValues(alpha: 0.4),
                      blurRadius: AppResponsive.s(context, 12),
                      spreadRadius: 0,
                      offset: Offset(0, AppResponsive.s(context, 4)),
                    ),
                  ]
                : null,
          ),
          child: Text(
            widget.text,
            style: AppWidgetTypography.viewDetailsButton(context)
                .copyWith(fontSize: widget.fontSize),
          ),
        ),
      ),
    );
  }
}

/// Reusable chip widget with dark background
class DarkChip extends StatelessWidget {
  const DarkChip({
    super.key,
    required this.label,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.padding,
  });

  final String label;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ??
          AppResponsive.paddingSymmetric(
            context,
            horizontal: 10,
            vertical: 6,
          ),
      decoration: BoxDecoration(
        borderRadius: AppResponsive.borderRadius(context, 16),
        color: backgroundColor ??
            AppWidgetColors.tagBackground.withValues(alpha: 0.6),
        border: Border.all(
          color: borderColor ?? Colors.white.withValues(alpha: 0.08),
          width: AppResponsive.thickness(context, 1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: AppResponsive.icon(context, 14),
              color: textColor ?? Colors.white,
            ),
            AppResponsive.horizontalSpace(context, 5),
          ],
          Text(
            label,
            style: AppWidgetTypography.eventTag(context)
                .copyWith(color: textColor),
          ),
        ],
      ),
    );
  }
}

/// Reusable divider line
class AppDivider extends StatelessWidget {
  const AppDivider({
    super.key,
    this.color,
    this.thickness,
    this.height,
  });

  final Color? color;
  final double? thickness;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height ?? AppResponsive.thickness(context, thickness ?? 1),
      color: color ?? Colors.white.withValues(alpha: 0.15),
    );
  }
}

/// Reusable icon with text row
class IconTextRow extends StatelessWidget {
  const IconTextRow({
    super.key,
    required this.icon,
    required this.text,
    this.iconSize,
    this.iconColor,
    this.textStyle,
    this.spacing,
  });

  final IconData icon;
  final String text;
  final double? iconSize;
  final Color? iconColor;
  final TextStyle? textStyle;
  final double? spacing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: iconSize ?? AppResponsive.icon(context, 16),
          color: iconColor ?? Colors.white,
        ),
        SizedBox(width: spacing ?? AppResponsive.s(context, 6)),
        Text(
          text,
          style: textStyle ?? AppTypography.bodySmall(context),
        ),
      ],
    );
  }
}

/// Reusable scale animation wrapper
class ScaleAnimation extends StatefulWidget {
  const ScaleAnimation({
    super.key,
    required this.child,
    this.onTap,
    this.scaleBegin = 1.0,
    this.scaleEnd = 0.95,
    this.duration,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scaleBegin;
  final double scaleEnd;
  final Duration? duration;

  @override
  State<ScaleAnimation> createState() => _ScaleAnimationState();
}

class _ScaleAnimationState extends State<ScaleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration ?? AppDurations.buttonPress,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: widget.scaleBegin,
      end: widget.scaleEnd,
    ).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.standard),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// Reusable purple glow effect widget
class GlowEffect extends StatelessWidget {
  const GlowEffect({
    super.key,
    this.size = 200,
    this.color,
    this.opacity = 0.2,
  });

  final double size;
  final Color? color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color:
                  (color ?? const Color(0xFF6B00FF)).withValues(alpha: opacity),
              blurRadius: AppResponsive.s(context, size / 2),
              spreadRadius: AppResponsive.s(context, size / 4),
            ),
          ],
        ),
      ),
    );
  }
}
