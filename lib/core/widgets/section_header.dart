import 'package:adrinolinq_owner/core/utils/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_responsive.dart';
import '../../core/theme/app_typography.dart';

/// Section header widget with title and "See all" action
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionText = 'See all',
    this.onActionTap,
    this.showAction = true,
  });

  final String title;
  final String actionText;
  final VoidCallback? onActionTap;
  final bool showAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppResponsive.paddingSymmetric(context, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title
          Text(
            title,
            style: AppWidgetTypography.sectionTitle(context,
                color: const Color(0xFF000000).withValues(alpha: 0.98),),
          ),

          // See all action
          if (showAction)
            GestureDetector(
              onTap: onActionTap,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    actionText,
                    style: AppWidgetTypography.sectionAction(context,
                        color: const Color(0xFF525252),),
                  ),
                  AppResponsive.horizontalSpace(context, 8),
                  SvgPicture.asset(
                    AppAssets.arrowRightIcon,
                    width: AppResponsive.icon(context, 10),
                    height: AppResponsive.icon(context, 10),
                    colorFilter: const ColorFilter.mode(
                        Color(0xFF525252), BlendMode.srcIn,),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
