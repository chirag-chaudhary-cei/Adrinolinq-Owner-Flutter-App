import 'package:flutter/material.dart';
import '../theme/app_colors_new.dart';
import '../theme/app_gradients.dart';
import '../theme/app_spacing.dart';
import '../theme/app_animations.dart';
import '../theme/app_responsive.dart';
import 'app_loading.dart';

// ============================================================
// BUTTON COMPONENTS
// ============================================================

/// Primary gradient button with lime color from reference design
class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isLoading = false,
    this.isEnabled = true,
    this.padding,
    this.borderRadius,
    this.fontSize,
    this.width,
    this.height,
    this.icon,
    this.gradient,
  });

  final String text;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool isEnabled;
  final EdgeInsets? padding;
  final double? borderRadius;
  final double? fontSize;
  final double? width;
  final double? height;
  final IconData? icon;
  final Gradient? gradient;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
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
    final isActive = widget.isEnabled && !widget.isLoading;

    return GestureDetector(
      onTapDown: isActive ? (_) => _controller.forward() : null,
      onTapUp: isActive ? (_) => _controller.reverse() : null,
      onTapCancel: isActive ? () => _controller.reverse() : null,
      onTap: isActive ? widget.onTap : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: AnimatedContainer(
          duration: AppDurations.normal,
          width: widget.width,
          height: widget.height ?? AppSpacing.buttonHeight,
          padding: widget.padding ??
              EdgeInsets.symmetric(
                horizontal: AppResponsive.s(context, 24),
                vertical: AppResponsive.s(context, 12),
              ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              widget.borderRadius ?? AppResponsive.radius(context, 12),
            ),
            gradient: isActive ? (widget.gradient ?? AppGradients.lime) : null,
            color: isActive ? null : AppColors.buttonDisabledDark,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.shadowLime,
                      blurRadius: AppResponsive.s(context, 16),
                      spreadRadius: 0,
                      offset: Offset(0, AppResponsive.s(context, 4)),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: widget.isLoading
                ? AppLoading.button(
                    size: AppResponsive.s(context, 20),
                    color: AppColors.onPrimary,
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          size: AppResponsive.icon(context, 18),
                          color: AppColors.onPrimary,
                        ),
                        SizedBox(width: AppResponsive.s(context, 8)),
                      ],
                      Text(
                        widget.text,
                        style: TextStyle(
                          fontSize: widget.fontSize ??
                              AppResponsive.font(context, 16),
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? AppColors.onPrimary
                              : AppColors.textMutedDark,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Secondary button with outline style
class SecondaryButton extends StatefulWidget {
  const SecondaryButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isLoading = false,
    this.isEnabled = true,
    this.padding,
    this.borderRadius,
    this.fontSize,
    this.width,
    this.height,
    this.icon,
    this.borderColor,
    this.textColor,
  });

  final String text;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool isEnabled;
  final EdgeInsets? padding;
  final double? borderRadius;
  final double? fontSize;
  final double? width;
  final double? height;
  final IconData? icon;
  final Color? borderColor;
  final Color? textColor;

  @override
  State<SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<SecondaryButton>
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
    final isActive = widget.isEnabled && !widget.isLoading;
    final color = widget.borderColor ?? AppColors.primary;

    return GestureDetector(
      onTapDown: isActive ? (_) => _controller.forward() : null,
      onTapUp: isActive ? (_) => _controller.reverse() : null,
      onTapCancel: isActive ? () => _controller.reverse() : null,
      onTap: isActive ? widget.onTap : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: AnimatedContainer(
          duration: AppDurations.normal,
          width: widget.width,
          height: widget.height ?? AppSpacing.buttonHeight,
          padding: widget.padding ??
              EdgeInsets.symmetric(
                horizontal: AppResponsive.s(context, 24),
                vertical: AppResponsive.s(context, 12),
              ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              widget.borderRadius ?? AppResponsive.radius(context, 12),
            ),
            border: Border.all(
              color: isActive ? color : AppColors.buttonDisabledDark,
              width: 1.5,
            ),
          ),
          child: Center(
            child: widget.isLoading
                ? AppLoading.button(
                    size: AppResponsive.s(context, 20),
                    color: color,
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          size: AppResponsive.icon(context, 18),
                          color: isActive ? color : AppColors.textMutedDark,
                        ),
                        SizedBox(width: AppResponsive.s(context, 8)),
                      ],
                      Text(
                        widget.text,
                        style: TextStyle(
                          fontSize: widget.fontSize ??
                              AppResponsive.font(context, 16),
                          fontWeight: FontWeight.w600,
                          color: widget.textColor ??
                              (isActive ? color : AppColors.textMutedDark),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Small action button (like "View Details" in reference)
class ActionButton extends StatefulWidget {
  const ActionButton({
    super.key,
    required this.text,
    required this.onTap,
    this.gradient,
    this.padding,
    this.borderRadius,
    this.fontSize,
  });

  final String text;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final EdgeInsets? padding;
  final double? borderRadius;
  final double? fontSize;

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton>
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
              EdgeInsets.symmetric(
                horizontal: AppResponsive.s(context, 16),
                vertical: AppResponsive.s(context, 8),
              ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              widget.borderRadius ?? AppResponsive.radius(context, 20),
            ),
            gradient: widget.gradient ?? AppGradients.lime,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLime,
                blurRadius: AppResponsive.s(context, 8),
                spreadRadius: 0,
                offset: Offset(0, AppResponsive.s(context, 2)),
              ),
            ],
          ),
          child: Text(
            widget.text,
            style: TextStyle(
              fontSize: widget.fontSize ?? AppResponsive.font(context, 12),
              fontWeight: FontWeight.w600,
              color: AppColors.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// CHIP COMPONENTS
// ============================================================

/// Category chip with semi-transparent background
class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.padding,
    this.fontSize,
  });

  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final EdgeInsets? padding;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ??
          EdgeInsets.symmetric(
            horizontal: AppResponsive.s(context, 12),
            vertical: AppResponsive.s(context, 6),
          ),
      decoration: BoxDecoration(
        borderRadius: AppResponsive.borderRadius(context, 16),
        color: backgroundColor ?? AppColors.chipBackgroundDark,
        border: Border.all(
          color: borderColor ?? Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: fontSize ?? AppResponsive.font(context, 12),
          fontWeight: FontWeight.w500,
          color: textColor ?? AppColors.textPrimaryDark,
        ),
      ),
    );
  }
}

/// Tag chip with icon support
class TagChip extends StatelessWidget {
  const TagChip({
    super.key,
    required this.label,
    this.icon,
    this.svgIcon,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.padding,
    this.fontSize,
  });

  final String label;
  final IconData? icon;
  final Widget? svgIcon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final EdgeInsets? padding;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ??
          EdgeInsets.symmetric(
            horizontal: AppResponsive.s(context, 10),
            vertical: AppResponsive.s(context, 6),
          ),
      decoration: BoxDecoration(
        borderRadius: AppResponsive.borderRadius(context, 16),
        color: backgroundColor ?? Colors.black.withValues(alpha: 0.4),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (svgIcon != null) ...[
            SizedBox(
              width: AppResponsive.icon(context, 14),
              height: AppResponsive.icon(context, 14),
              child: svgIcon,
            ),
            SizedBox(width: AppResponsive.s(context, 5)),
          ] else if (icon != null) ...[
            Icon(
              icon,
              size: AppResponsive.icon(context, 14),
              color: iconColor ?? textColor ?? Colors.white,
            ),
            SizedBox(width: AppResponsive.s(context, 5)),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize ?? AppResponsive.font(context, 12),
              fontWeight: FontWeight.w500,
              color: textColor ?? Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PRICE TAG COMPONENT
// ============================================================

/// Price tag with gradient background (lime from reference)
class PriceTag extends StatelessWidget {
  const PriceTag({
    super.key,
    required this.price,
    this.gradient,
    this.padding,
    this.borderRadius,
    this.fontSize,
  });

  final String price;
  final Gradient? gradient;
  final EdgeInsets? padding;
  final double? borderRadius;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ??
          EdgeInsets.symmetric(
            horizontal: AppResponsive.s(context, 12),
            vertical: AppResponsive.s(context, 6),
          ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          borderRadius ?? AppResponsive.radius(context, 20),
        ),
        gradient: gradient ?? AppGradients.lime,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLime,
            blurRadius: AppResponsive.s(context, 8),
            spreadRadius: 0,
            offset: Offset(0, AppResponsive.s(context, 2)),
          ),
        ],
      ),
      child: Text(
        price,
        style: TextStyle(
          fontSize: fontSize ?? AppResponsive.font(context, 14),
          fontWeight: FontWeight.w700,
          color: AppColors.onPrimary,
        ),
      ),
    );
  }
}

// ============================================================
// ICON BUTTON COMPONENT
// ============================================================

/// Circular icon button with optional badge
class AppIconButton extends StatefulWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size,
    this.iconSize,
    this.backgroundColor,
    this.iconColor,
    this.hasBadge = false,
    this.badgeCount,
    this.badgeColor,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final double? size;
  final double? iconSize;
  final Color? backgroundColor;
  final Color? iconColor;
  final bool hasBadge;
  final int? badgeCount;
  final Color? badgeColor;

  @override
  State<AppIconButton> createState() => _AppIconButtonState();
}

class _AppIconButtonState extends State<AppIconButton>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
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
    final buttonSize = widget.size ?? AppResponsive.s(context, 44);
    final iconSize = widget.iconSize ?? AppResponsive.icon(context, 24);

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
        child: SizedBox(
          width: buttonSize,
          height: buttonSize,
          child: Stack(
            children: [
              Container(
                width: buttonSize,
                height: buttonSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.backgroundColor ??
                      Colors.white.withValues(alpha: 0.1),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Icon(
                    widget.icon,
                    size: iconSize,
                    color: widget.iconColor ?? AppColors.iconPrimaryDark,
                  ),
                ),
              ),
              if (widget.hasBadge)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: widget.badgeCount != null
                        ? AppResponsive.s(context, 18)
                        : AppResponsive.s(context, 10),
                    height: widget.badgeCount != null
                        ? AppResponsive.s(context, 18)
                        : AppResponsive.s(context, 10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.badgeColor ?? AppColors.notificationBadge,
                      border: Border.all(
                        color: AppColors.backgroundDark,
                        width: 2,
                      ),
                    ),
                    child: widget.badgeCount != null
                        ? Center(
                            child: Text(
                              widget.badgeCount! > 99
                                  ? '99+'
                                  : widget.badgeCount.toString(),
                              style: TextStyle(
                                fontSize: AppResponsive.font(context, 10),
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// THEME TOGGLE BUTTON
// ============================================================

/// Animated theme toggle button for switching between light/dark mode
class ThemeToggleButton extends StatefulWidget {
  const ThemeToggleButton({
    super.key,
    required this.isDarkMode,
    required this.onToggle,
    this.size,
  });

  final bool isDarkMode;
  final VoidCallback onToggle;
  final double? size;

  @override
  State<ThemeToggleButton> createState() => _ThemeToggleButtonState();
}

class _ThemeToggleButtonState extends State<ThemeToggleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDurations.medium,
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.emphasized),
    );

    if (!widget.isDarkMode) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(ThemeToggleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDarkMode != widget.isDarkMode) {
      if (widget.isDarkMode) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size ?? AppResponsive.s(context, 44);

    return GestureDetector(
      onTap: widget.onToggle,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: widget.isDarkMode
              ? AppGradients.purple
              : const LinearGradient(
                  colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                ),
          boxShadow: [
            BoxShadow(
              color: widget.isDarkMode
                  ? AppColors.shadowPurple
                  : const Color(0x40F59E0B),
              blurRadius: AppResponsive.s(context, 12),
              spreadRadius: 0,
            ),
          ],
        ),
        child: AnimatedBuilder(
          animation: _rotationAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationAnimation.value * 3.14159,
              child: Icon(
                widget.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                size: AppResponsive.icon(context, 24),
                color: Colors.white,
              ),
            );
          },
        ),
      ),
    );
  }
}
