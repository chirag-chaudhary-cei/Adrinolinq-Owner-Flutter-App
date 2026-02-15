import 'package:flutter/material.dart';
import '../theme/app_colors_new.dart';
import '../theme/app_responsive.dart';
import '../theme/app_animations.dart';

/// A reusable section card with consistent styling
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? AppResponsive.padding(context, all: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppResponsive.borderRadius(context, 20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: AppResponsive.s(context, 20),
            offset: Offset(0, AppResponsive.s(context, 6)),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// A reusable dashed divider widget
class DashedDivider extends StatelessWidget {
  const DashedDivider({
    super.key,
    this.color,
    this.dashWidth,
    this.dashSpace,
    this.height,
  });

  final Color? color;
  final double? dashWidth;
  final double? dashSpace;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dWidth = dashWidth ?? AppResponsive.s(context, 5);
        final dSpace = dashSpace ?? AppResponsive.s(context, 3);
        final dashCount = (constraints.maxWidth / (dWidth + dSpace)).floor();

        return Row(
          children: List.generate(dashCount, (index) {
            return Padding(
              padding: EdgeInsets.only(right: dSpace),
              child: Container(
                width: dWidth,
                height: height ?? AppResponsive.thickness(context, 1),
                color: color ?? const Color(0xFFE0E0E0),
              ),
            );
          }),
        );
      },
    );
  }
}

/// A reusable info row with icon, title and value
class InfoRowWithIcon extends StatelessWidget {
  const InfoRowWithIcon({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.iconBackgroundColor,
    this.iconColor,
    this.iconSize,
    this.titleStyle,
    this.valueStyle,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color? iconBackgroundColor;
  final Color? iconColor;
  final double? iconSize;
  final TextStyle? titleStyle;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: AppResponsive.s(context, 44),
          height: AppResponsive.s(context, 44),
          decoration: BoxDecoration(
            color: iconBackgroundColor ?? AppColors.accentBlue,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor ?? Colors.white,
            size: iconSize ?? AppResponsive.icon(context, 22),
          ),
        ),
        AppResponsive.horizontalSpace(context, 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: titleStyle ??
                    TextStyle(
                      fontFamily: 'SFProRounded',
                      fontSize: AppResponsive.font(context, 14),
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondaryLight,
                    ),
              ),
              AppResponsive.verticalSpace(context, 2),
              Text(
                value,
                style: valueStyle ??
                    TextStyle(
                      fontFamily: 'SFProRounded',
                      fontSize: AppResponsive.font(context, 16),
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryLight,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Model for teammate display in list
class TeammateDisplayModel {
  final String id;
  final String name;
  final String? role;
  final String? avatarUrl;
  final bool isSelected;

  const TeammateDisplayModel({
    required this.id,
    required this.name,
    this.role,
    this.avatarUrl,
    this.isSelected = true,
  });
}

/// A reusable teammate item widget
class TeammateListItem extends StatelessWidget {
  const TeammateListItem({
    super.key,
    required this.name,
    this.role,
    this.avatarUrl,
    this.showCheckIcon = false,
    this.showDivider = true,
    this.onTap,
  });

  final String name;
  final String? role;
  final String? avatarUrl;
  final bool showCheckIcon;
  final bool showDivider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              _buildAvatar(context),
              SizedBox(width: AppResponsive.s(context, 16)),
              // Name and role
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontFamily: 'SFProRounded',
                        fontSize: AppResponsive.font(context, 16),
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    if (role != null && role!.isNotEmpty) ...[
                      SizedBox(height: AppResponsive.s(context, 2)),
                      Text(
                        role!,
                        style: TextStyle(
                          fontFamily: 'SFProRounded',
                          fontSize: AppResponsive.font(context, 13),
                          fontWeight: FontWeight.w500,
                          color: AppColors.accentBlue,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Check icon (if enabled)
              if (showCheckIcon)
                Container(
                  width: AppResponsive.s(context, 28),
                  height: AppResponsive.s(context, 28),
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue,
                    borderRadius: AppResponsive.borderRadius(context, 8),
                  ),
                  child: Icon(
                    Icons.check,
                    size: AppResponsive.icon(context, 18),
                    color: Colors.white,
                  ),
                ),
            ],
          ),
          // Show divider only if showDivider is true
          if (showDivider) ...[
            SizedBox(height: AppResponsive.s(context, 12)),
            const Divider(
              color: Color(0xFFE0E0E0),
              height: 1,
              thickness: 1,
            ),
            SizedBox(height: AppResponsive.s(context, 12)),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    // Generate initials from name for fallback
    final initials = name
        .split(' ')
        .take(2)
        .map((e) => e.isNotEmpty ? e[0] : '')
        .join('')
        .toUpperCase();

    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      if (avatarUrl!.startsWith('http')) {
        // Network image with error handling
        return CircleAvatar(
          radius: AppResponsive.s(context, 24),
          backgroundColor: AppColors.accentBlue.withOpacity(0.1),
          child: ClipOval(
            child: Image.network(
              avatarUrl!,
              width: AppResponsive.s(context, 48),
              height: AppResponsive.s(context, 48),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Show initials on error
                return Center(
                  child: Text(
                    initials.isNotEmpty ? initials : '?',
                    style: TextStyle(
                      fontFamily: 'SFProRounded',
                      fontSize: AppResponsive.font(context, 16),
                      fontWeight: FontWeight.w600,
                      color: AppColors.accentBlue,
                    ),
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                // Show initials while loading
                return Center(
                  child: Text(
                    initials.isNotEmpty ? initials : '?',
                    style: TextStyle(
                      fontFamily: 'SFProRounded',
                      fontSize: AppResponsive.font(context, 16),
                      fontWeight: FontWeight.w600,
                      color: AppColors.accentBlue.withOpacity(0.5),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      } else {
        // Asset image
        return CircleAvatar(
          radius: AppResponsive.s(context, 24),
          backgroundImage: AssetImage(avatarUrl!),
          backgroundColor: AppColors.accentBlue.withOpacity(0.1),
        );
      }
    }

    // No avatar URL - show initials
    return CircleAvatar(
      radius: AppResponsive.s(context, 24),
      backgroundColor: AppColors.accentBlue.withOpacity(0.1),
      child: Text(
        initials.isNotEmpty ? initials : '?',
        style: TextStyle(
          fontFamily: 'SFProRounded',
          fontSize: AppResponsive.font(context, 16),
          fontWeight: FontWeight.w600,
          color: AppColors.accentBlue,
        ),
      ),
    );
  }
}

/// A reusable teammates section widget
class TeammatesSection extends StatelessWidget {
  const TeammatesSection({
    super.key,
    required this.title,
    required this.playerCount,
    required this.teammates,
    this.onAddTap,
    this.addButtonText = '+ Add new Teammates',
    this.showCheckIcon = false,
    this.maxVisibleTeammates,
  });

  final String title;
  final int playerCount;
  final List<TeammateDisplayModel> teammates;
  final VoidCallback? onAddTap;
  final String addButtonText;
  final bool showCheckIcon;
  final int? maxVisibleTeammates;

  @override
  Widget build(BuildContext context) {
    final visibleTeammates = maxVisibleTeammates != null
        ? teammates.take(maxVisibleTeammates!).toList()
        : teammates;

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'SFProRounded',
                  fontSize: AppResponsive.font(context, 18),
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              SizedBox(width: AppResponsive.s(context, 4)),
              Text(
                '($playerCount Player)',
                style: TextStyle(
                  fontFamily: 'SFProRounded',
                  fontSize: AppResponsive.font(context, 13),
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
          SizedBox(height: AppResponsive.s(context, 16)),
          const DashedDivider(),
          SizedBox(height: AppResponsive.s(context, 16)),
          // Teammates list
          ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: visibleTeammates.length,
            itemBuilder: (context, index) {
              final teammate = visibleTeammates[index];
              final isLast = index == visibleTeammates.length - 1;
              return TeammateListItem(
                name: teammate.name,
                role: teammate.role,
                avatarUrl: teammate.avatarUrl,
                showCheckIcon: showCheckIcon,
                showDivider: !isLast,
              );
            },
          ),
          // Add button - only show if onAddTap is provided
          if (onAddTap != null) ...[
            SizedBox(height: AppResponsive.s(context, 4)),
            GestureDetector(
              onTap: onAddTap,
              child: Center(
                child: Text(
                  addButtonText,
                  style: TextStyle(
                    fontFamily: 'SFProRounded',
                    fontSize: AppResponsive.font(context, 14),
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentBlue,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A reusable price section widget
class PriceSection extends StatelessWidget {
  const PriceSection({
    super.key,
    required this.priceWithTax,
    required this.serviceFee,
    required this.totalAmount,
    required this.showBreakup,
    required this.onToggleBreakup,
    this.currencySymbol = '₹',
    this.totalLabel = 'Total Amount to be paid',
  });

  final double priceWithTax;
  final double serviceFee;
  final double totalAmount;
  final bool showBreakup;
  final VoidCallback onToggleBreakup;
  final String currencySymbol;
  final String totalLabel;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Price',
                style: TextStyle(
                  fontFamily: 'SFProRounded',
                  fontSize: AppResponsive.font(context, 18),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              GestureDetector(
                onTap: onToggleBreakup,
                child: Row(
                  children: [
                    Text(
                      'View Price Breakup',
                      style: TextStyle(
                        fontFamily: 'SFProRounded',
                        fontSize: AppResponsive.font(context, 13),
                        fontWeight: FontWeight.w500,
                        color: AppColors.accentBlue,
                      ),
                    ),
                    SizedBox(width: AppResponsive.s(context, 4)),
                    AnimatedRotation(
                      turns: showBreakup ? 0.5 : 0,
                      duration: AppDurations.quick,
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: AppResponsive.icon(context, 18),
                        color: AppColors.accentBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppResponsive.s(context, 16)),
          const DashedDivider(),
          if (showBreakup) ...[
            SizedBox(height: AppResponsive.s(context, 16)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Price + Taxes & Service Fees',
                  style: TextStyle(
                    fontFamily: 'SFProRounded',
                    fontSize: AppResponsive.font(context, 14),
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                Text(
                  '$currencySymbol${priceWithTax.toStringAsFixed(0)} + $currencySymbol${serviceFee.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontFamily: 'SFProRounded',
                    fontSize: AppResponsive.font(context, 14),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppResponsive.s(context, 16)),
            const DashedDivider(),
          ],
          SizedBox(height: AppResponsive.s(context, 16)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                totalLabel,
                style: TextStyle(
                  fontFamily: 'SFProRounded',
                  fontSize: AppResponsive.font(context, 15),
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              Text(
                '$currencySymbol${totalAmount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontFamily: 'SFProRounded',
                  fontSize: AppResponsive.font(context, 20),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A reusable section header widget
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.style,
  });

  final String title;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: style ??
          TextStyle(
            fontFamily: 'SFProRounded',
            fontSize: AppResponsive.font(context, 14),
            fontWeight: FontWeight.w700,
            color: const Color(0xFF000000),
          ),
    );
  }
}

/// A reusable rule item with check icon
class RuleItem extends StatelessWidget {
  const RuleItem({
    super.key,
    required this.text,
    this.icon,
    this.iconColor,
  });

  final String text;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: AppResponsive.s(context, 2)),
          child: Icon(
            icon ?? Icons.check_circle_outline,
            color: iconColor ?? AppColors.accentBlue,
            size: AppResponsive.icon(context, 20),
          ),
        ),
        AppResponsive.horizontalSpace(context, 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'SFProRounded',
              fontSize: AppResponsive.font(context, 14),
              height: 1.4,
              color: const Color(0xFF616161),
            ),
          ),
        ),
      ],
    );
  }
}
