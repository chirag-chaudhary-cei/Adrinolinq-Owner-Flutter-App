import 'package:flutter/material.dart';
import '../theme/app_colors_new.dart';
import '../theme/app_responsive.dart';
import 'app_back_button.dart';

/// Global header widget for inner detail screens
class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.title,
    this.onBackPressed,
    this.backgroundColor,
    this.showBackButton = true,
    this.iconColor,
    this.trailing,
  });

  final String title;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final bool showBackButton;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? Colors.white;
    final iconColorFinal = iconColor ?? Colors.white;

    return Container(
      padding:
          AppResponsive.padding(context, horizontal: 20, top: 5, bottom: 16),
      decoration: BoxDecoration(
        color: bg,
      ),
      child: Row(
        children: [
          if (showBackButton) ...[
            AppBackButton(onPressed: onBackPressed, iconColor: iconColorFinal),
            SizedBox(width: AppResponsive.s(context, 16)),
          ],
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'SFProRounded',
                fontSize: AppResponsive.font(context, 20),
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryLight,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
