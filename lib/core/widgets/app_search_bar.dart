import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_animations.dart';
import '../../core/theme/app_colors_new.dart';
import '../../core/theme/app_responsive.dart';
import '../../core/utils/app_assets.dart';

/// Custom search bar widget with glassmorphism effect
class AppSearchBar extends StatefulWidget {
  const AppSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.hintText = 'Search Destination',
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final bool autofocus;

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _focusAnimation;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDurations.normal,
      vsync: this,
    );
    _focusAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.standard),
    );
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _focusAnimation,
      builder: (context, child) {
        return Container(
          height: AppResponsive.s(context, 48),
          decoration: BoxDecoration(
            borderRadius: AppResponsive.borderRadius(context, 46),
            color: Colors.white,
            border: Border.all(
              color: const Color(0xFF000000),
              width: AppResponsive.thickness(context, 2),
            ),
            // boxShadow: _isFocused
            //     ? [
            //         BoxShadow(
            //           color: AppColors.primary.withValues(alpha: 0.1),
            //           blurRadius: AppResponsive.s(context, 8),
            //           spreadRadius: 0,
            //         ),
            //       ]
            //     : null,
          ),
          child: Center(child: child),
        );
      },
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        enabled: widget.enabled,
        autofocus: widget.autofocus,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        style: TextStyle(
          color: Colors.black,
          fontSize: AppResponsive.s(context, 15),
          fontWeight: FontWeight.w500,
        ),
        cursorColor: AppColors.textSecondaryDark,
        decoration: InputDecoration(
          fillColor: Colors.transparent,
          hintText: widget.hintText,
          hintStyle: TextStyle(
            fontSize: AppResponsive.s(context, 15),
            fontWeight: FontWeight.w500,
            color: const Color(0xFF212121).withValues(alpha: 0.35),
          ),
          prefixIcon: widget.prefixIcon ??
              Padding(
                padding: AppResponsive.padding(context, left: 18, right: 12),
                child: SvgPicture.asset(
                  AppAssets.searchIcon,
                  width: AppResponsive.icon(context, 24),
                  height: AppResponsive.icon(context, 24),
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF1A1A1A),
                    BlendMode.srcIn,
                  ),
                ),
              ),
          prefixIconConstraints: BoxConstraints(
            minWidth: AppResponsive.s(context, 54),
          ),
          suffixIcon: widget.suffixIcon,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: AppResponsive.paddingSymmetric(
            context,
            horizontal: 0,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
