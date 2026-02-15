import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors_new.dart';
import '../theme/app_responsive.dart';

/// Global bottom navigation bar for the Owner app
/// 5 tabs: Home, My Tournament, Teams, Matches, Profile
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFEEEEEE),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: AppResponsive.padding(context, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                index: 0,
                asset: 'assets/icons/li_home.svg',
                label: 'Home',
              ),
              _buildNavItem(
                context,
                index: 1,
                asset: 'assets/icons/li_pie-chart.svg',
                label: 'My Tournament',
              ),
              _buildNavItem(
                context,
                index: 2,
                asset: 'assets/icons/users.svg',
                label: 'Teams',
              ),
              _buildNavItem(
                context,
                index: 3,
                asset: 'assets/icons/li_clock.svg',
                label: 'Matches',
              ),
              _buildNavItem(
                context,
                index: 4,
                asset: 'assets/icons/li_user.svg',
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required String asset,
    required String label,
  }) {
    final isSelected = currentIndex == index;
    final color = isSelected ? AppColors.accentBlue : AppColors.textMutedLight;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: AppResponsive.icon(context, 24),
              height: AppResponsive.icon(context, 28),
              child: SvgPicture.asset(
                asset,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
            ),
            SizedBox(height: AppResponsive.s(context, 4)),
            SizedBox(
              width: double.infinity,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  softWrap: false,
                  style: TextStyle(
                    fontFamily: 'SFProRounded',
                    fontSize: AppResponsive.font(context, 13),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: color,
                    height: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
