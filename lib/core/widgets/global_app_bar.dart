import 'package:flutter/material.dart';

import '../theme/app_colors_new.dart';
import '../theme/app_responsive.dart';
import 'app_back_button.dart';

/// Global AppBar for non-home screens (Discover, My Tournament, matches)
/// Reusable public header used across screens.
/// Supports both main screens (no back button) and inner screens (with back button).
class GlobalAppBar extends StatelessWidget {
  const GlobalAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.horizontalPadding = 20,
    this.verticalPadding,
    this.showDivider = true,
    this.showBackButton = false,
    // Title customization
    this.titleFontSize,
    this.titleFontWeight,
    this.titleColor,
    this.titleStyle,
    // Subtitle customization
    this.subtitleFontSize,
    this.subtitleFontWeight,
    this.subtitleColor,
    this.subtitleStyle,
    // Action button flags
    this.showAddButton = false,
    this.onAddPressed,
    this.addButtonText = 'Add',
    this.addButtonIcon = Icons.add,
    this.showEditButton = false,
    this.onEditPressed,
    this.editButtonText = 'Edit',
    this.editButtonIcon = Icons.edit_outlined,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final double horizontalPadding;
  final double? verticalPadding;
  final bool showDivider;
  final bool showBackButton;

  // Title customization
  final double? titleFontSize;
  final FontWeight? titleFontWeight;
  final Color? titleColor;
  final TextStyle? titleStyle;

  // Subtitle customization
  final double? subtitleFontSize;
  final FontWeight? subtitleFontWeight;
  final Color? subtitleColor;
  final TextStyle? subtitleStyle;

  // Add button configuration
  final bool showAddButton;
  final VoidCallback? onAddPressed;
  final String addButtonText;
  final IconData? addButtonIcon;

  // Edit button configuration
  final bool showEditButton;
  final VoidCallback? onEditPressed;
  final String editButtonText;
  final IconData? editButtonIcon;

  /// Builds an action button with icon and text
  Widget _buildActionButton(
    BuildContext context, {
    required IconData? icon,
    required String text,
    required VoidCallback? onPressed,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(
              icon,
              color: AppColors.accentBlue,
              size: AppResponsive.icon(context, 18),
            ),
          if (icon != null) SizedBox(width: AppResponsive.s(context, 4)),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'SFProRounded',
              color: AppColors.accentBlue,
              fontSize: AppResponsive.font(context, 14),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the trailing widget based on flags or custom trailing
  Widget? _buildTrailingWidget(BuildContext context) {
    // If custom trailing is provided, use it
    if (trailing != null) {
      return trailing;
    }

    // Build action buttons based on flags
    final List<Widget> actionButtons = [];

    if (showAddButton) {
      actionButtons.add(_buildActionButton(
        context,
        icon: addButtonIcon,
        text: addButtonText,
        onPressed: onAddPressed,
      ),);
    }

    if (showEditButton) {
      actionButtons.add(_buildActionButton(
        context,
        icon: editButtonIcon,
        text: editButtonText,
        onPressed: onEditPressed,
      ),);
    }

    if (actionButtons.isEmpty) {
      return null;
    }

    if (actionButtons.length == 1) {
      return actionButtons.first;
    }

    // Multiple buttons - show in a row with spacing
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: actionButtons
          .expand((button) =>
              [button, SizedBox(width: AppResponsive.s(context, 12))],)
          .toList()
        ..removeLast(), // Remove trailing spacer
    );
  }

  @override
  Widget build(BuildContext context) {
    final trailingWidget = _buildTrailingWidget(context);
    // Explicit leading takes precedence. Then back button if enabled.
    final leadingWidget =
        leading ?? (showBackButton ? const AppBackButton() : null);

    final content = Padding(
      padding: EdgeInsets.only(
        left: AppResponsive.s(context, horizontalPadding),
        right: AppResponsive.s(context, horizontalPadding),
        top: AppResponsive.s(context, 5),
        bottom: AppResponsive.s(context, verticalPadding ?? 16),
      ),
      child: Row(
        children: [
          if (leadingWidget != null) ...[
            leadingWidget,
            SizedBox(width: AppResponsive.s(context, 18)),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: subtitle != null
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: titleStyle ??
                      TextStyle(
                        fontFamily: 'SFProRounded',
                        fontSize:
                            titleFontSize ?? AppResponsive.font(context, 22),
                        fontWeight: titleFontWeight ?? FontWeight.w600,
                        color: titleColor ?? AppColors.textPrimaryLight,
                      ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: subtitleStyle ??
                        TextStyle(
                          fontFamily: 'SFProRounded',
                          fontSize: subtitleFontSize ??
                              AppResponsive.font(context, 14),
                          fontWeight: subtitleFontWeight ?? FontWeight.w400,
                          color: subtitleColor ?? AppColors.accentBlue,
                        ),
                  ),
              ],
            ),
          ),
          if (trailingWidget != null) ...[
            SizedBox(width: AppResponsive.s(context, 8)),
            trailingWidget,
          ],
        ],
      ),
    );

    if (!showDivider) return content;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        content,
        const Divider(height: 1, color: AppColors.dividerLight),
      ],
    );
  }
}

/// Home AppBar with profile section (Type A)
/// Shows avatar, weather, name, and notification bell
class HomeAppBar extends StatelessWidget {
  const HomeAppBar({
    super.key,
    this.avatarUrl,
    this.userName,
    this.weatherText = 'SUNNY',
    this.onNotificationTap,
  });

  final String? avatarUrl;
  final String? userName;
  final String weatherText;
  final VoidCallback? onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: AppResponsive.padding(context, horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Avatar
              Container(
                width: AppResponsive.s(context, 48),
                height: AppResponsive.s(context, 48),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceLightVariant,
                  border: Border.all(
                    color: const Color(0xFFEEEEEE),
                    width: 1,
                  ),
                ),
                child: ClipOval(
                  child: avatarUrl != null && avatarUrl!.isNotEmpty
                      ? Image.network(
                          avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _buildDefaultAvatar(context),
                        )
                      : _buildDefaultAvatar(context),
                ),
              ),
              SizedBox(width: AppResponsive.s(context, 12)),
              // Name and weather
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Weather row
                    Row(
                      children: [
                        Text(
                          '☀️',
                          style: TextStyle(
                            fontSize: AppResponsive.font(context, 12),
                          ),
                        ),
                        SizedBox(width: AppResponsive.s(context, 4)),
                        Text(
                          weatherText,
                          style: TextStyle(
                            fontFamily: 'SFProRounded',
                            color: AppColors.textMutedLight,
                            fontSize: AppResponsive.font(context, 11),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppResponsive.s(context, 2)),
                    // Name
                    Text(
                      userName ?? 'Welcome',
                      style: TextStyle(
                        fontFamily: 'SFProRounded',
                        color: AppColors.textPrimaryLight,
                        fontSize: AppResponsive.font(context, 18),
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Notification bell
              GestureDetector(
                onTap: onNotificationTap,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: AppResponsive.s(context, 44),
                  height: AppResponsive.s(context, 44),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surfaceLightVariant,
                    border: Border.all(
                      color: const Color(0xFFEEEEEE),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.notifications_outlined,
                    size: AppResponsive.icon(context, 22),
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFEEEEEE)),
      ],
    );
  }

  Widget _buildDefaultAvatar(BuildContext context) {
    // Get initials from name
    String initials = 'U';
    if (userName != null && userName!.isNotEmpty) {
      final parts = userName!.split(' ');
      if (parts.length >= 2) {
        initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else {
        initials = userName![0].toUpperCase();
      }
    }

    return Container(
      color: AppColors.accentBlue.withOpacity(0.1),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontFamily: 'SFProRounded',
            color: AppColors.accentBlue,
            fontSize: AppResponsive.font(context, 18),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Search bar widget for consistent search UI
class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    super.key,
    this.hintText = 'Search Destination',
    this.onTap,
    this.controller,
    this.onChanged,
    this.enabled = true,
  });

  final String hintText;
  final VoidCallback? onTap;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? null : onTap,
      child: Container(
        margin: AppResponsive.padding(context, horizontal: 16, vertical: 12),
        padding: AppResponsive.padding(context, horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceLightVariant,
          borderRadius: AppResponsive.borderRadius(context, 28),
          border: Border.all(
            color: const Color(0xFFEEEEEE),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search,
              size: AppResponsive.icon(context, 22),
              color: AppColors.textMutedLight,
            ),
            SizedBox(width: AppResponsive.s(context, 12)),
            Expanded(
              child: enabled
                  ? TextField(
                      controller: controller,
                      onChanged: onChanged,
                      decoration: InputDecoration(
                        hintText: hintText,
                        hintStyle: TextStyle(
                          fontFamily: 'SFProRounded',
                          color: AppColors.textMutedLight,
                          fontSize: AppResponsive.font(context, 16),
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: TextStyle(
                        fontFamily: 'SFProRounded',
                        color: AppColors.textPrimaryLight,
                        fontSize: AppResponsive.font(context, 16),
                        fontWeight: FontWeight.w400,
                      ),
                    )
                  : Text(
                      hintText,
                      style: TextStyle(
                        fontFamily: 'SFProRounded',
                        color: AppColors.textMutedLight,
                        fontSize: AppResponsive.font(context, 16),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
