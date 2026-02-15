import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_animations.dart';
import '../theme/app_responsive.dart';

/// Global back button widget with glassmorphic effect
class AppBackButton extends StatefulWidget {
  const AppBackButton({
    super.key,
    this.onPressed,
    this.color = Colors.white,
    this.iconColor,
    this.backgroundColor,
    this.size = 44,
    this.isTransparent = false,
  });

  final VoidCallback? onPressed;
  final Color color;
  final Color? iconColor;
  final Color? backgroundColor;
  final double size;
  final bool isTransparent;

  @override
  State<AppBackButton> createState() => _AppBackButtonState();
}

class _AppBackButtonState extends State<AppBackButton> {
  bool _isPressed = false;

  void _handleTap() {
    if (widget.onPressed != null) {
      widget.onPressed!();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _handleTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.9 : 1.0,
        duration: AppDurations.quick,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
              AppResponsive.radius(context, widget.size / 2),),
          child: widget.isTransparent
              ? _buildTransparentButton(context)
              : _buildSolidButton(context),
        ),
      ),
    );
  }

  /// Transparent glassmorphic button with layered design
  Widget _buildTransparentButton(BuildContext context) {
    return Container(
      width: AppResponsive.s(context, widget.size),
      height: AppResponsive.s(context, widget.size),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(
            AppResponsive.radius(context, widget.size / 2),),
        border: Border.all(
          color: const Color(0xFFFFFFFF).withValues(alpha: 0.1), // 10% white
          width: AppResponsive.thickness(context, 1),
        ),
      ),
      child: Center(
        child: SvgPicture.asset(
          'assets/icons/arrow-left.svg',
          // width: AppResponsive.icon(context, 20),
          // height: AppResponsive.icon(context, 20),
          color: widget.iconColor ?? Colors.white,
        ),
      ),
    );
  }

  /// Solid button with opaque background
  Widget _buildSolidButton(BuildContext context) {
    return Container(
      width: AppResponsive.s(context, widget.size),
      height: AppResponsive.s(context, widget.size),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? const Color(0xFFE1E1E1),
        borderRadius: BorderRadius.circular(
            AppResponsive.radius(context, widget.size / 2),),
        border: Border.all(
          color: const Color(0xFFFFFFFF).withValues(alpha: 0.1),
          width: AppResponsive.thickness(context, 1),
        ),
      ),
      child: Center(
        child: SvgPicture.asset(
          'assets/icons/arrow-left.svg',
          width: AppResponsive.icon(context, 24),
          height: AppResponsive.icon(context, 24),
          color: widget.iconColor ?? Colors.black,
        ),
      ),
    );
  }
}
