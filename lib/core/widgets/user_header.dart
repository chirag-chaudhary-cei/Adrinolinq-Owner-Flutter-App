import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_animations.dart';
import '../../core/theme/app_colors_new.dart';
import '../../core/theme/app_responsive.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/app_assets.dart';
import '../../core/widgets/app_loading.dart';
import '../../features/profile/presentation/providers/profile_providers.dart';

/// User profile model
class UserProfile {
  final String id;
  final String name;
  final String? avatarUrl;
  final String? weatherLabel;
  final IconData? weatherIcon;

  const UserProfile({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.weatherLabel,
    this.weatherIcon,
  });
}

/// User header widget with avatar, name, weather badge, and notification icon
class UserHeader extends ConsumerWidget {
  const UserHeader({
    super.key,
    required this.user,
    this.onAvatarTap,
    this.onNotificationTap,
    this.hasNotifications = false,
  });

  final UserProfile user;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onNotificationTap;
  final bool hasNotifications;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarUrl = user.avatarUrl != null && user.avatarUrl!.isNotEmpty
        ? (user.avatarUrl!.startsWith('http')
            ? user.avatarUrl
            : ref
                .read(profileRepositoryProvider)
                .getUserImageUrl(user.avatarUrl))
        : null;
    return Padding(
      padding: AppResponsive.paddingSymmetric(context, horizontal: 5),
      child: Row(
        children: [
          // Avatar
          _AvatarWidget(
            avatarUrl: avatarUrl,
            onTap: onAvatarTap,
          ),
          AppResponsive.horizontalSpace(context, 10),

          // Name and weather
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Weather badge
                // if (user.weatherLabel != null)
                const _WeatherBadge(
                  label: "SUNNY",
                  icon: Icons.wb_sunny,
                  // label: user.weatherLabel!,
                  // icon: user.weatherIcon ?? Icons.wb_sunny,
                ),
                // AppResponsive.verticalSpace(context, 1),

                // Name
                // Display a trimmed name with a sensible fallback and ellipsis
                Text(
                  (user.name.trim().isEmpty ? 'Guest' : user.name.trim()),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppResponsive.font(context, 16),
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          // Notification icon
          _NotificationButton(
            onTap: onNotificationTap,
            hasNotifications: hasNotifications,
          ),
        ],
      ),
    );
  }
}

class _AvatarWidget extends StatefulWidget {
  const _AvatarWidget({
    this.avatarUrl,
    this.onTap,
  });

  final String? avatarUrl;
  final VoidCallback? onTap;

  @override
  State<_AvatarWidget> createState() => _AvatarWidgetState();
}

class _AvatarWidgetState extends State<_AvatarWidget>
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
    final size = AppResponsive.s(context, 48);

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
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.glassBorder,
              width: AppResponsive.thickness(context, 1),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowDark.withValues(alpha: 0.1),
                blurRadius: AppResponsive.s(context, 4),
                spreadRadius: -1,
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(AppResponsive.s(context, 1)),
            child: ClipOval(
              child: widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: widget.avatarUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.cardBackground,
                        child: Center(
                          child: AppLoading.circular(
                            size: 20.0,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) {
                        if (kDebugMode) {
                          print('❌ [UserHeader] Image load error: $error');
                          print('❌ [UserHeader] Failed URL: $url');
                        }
                        return _DefaultAvatar();
                      },
                    )
                  : _DefaultAvatar(),
            ),
          ),
        ),
      ),
    );
  }
}

class _DefaultAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cardBackground,
      child: Center(
        child: Icon(
          Icons.person,
          color: AppColors.iconMuted,
          size: AppResponsive.icon(context, 24),
        ),
      ),
    );
  }
}

class _WeatherBadge extends StatelessWidget {
  const _WeatherBadge({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          AppAssets.cloudySunIcon,
          width: AppResponsive.icon(context, 16),
          height: AppResponsive.icon(context, 16),
          colorFilter: const ColorFilter.mode(
            Color(0xFFFDB813),
            BlendMode.srcIn,
          ),
        ),
        AppResponsive.horizontalSpace(context, 6),
        Text(
          label,
          style: TextStyle(
            fontSize: AppResponsive.font(context, 11),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _NotificationButton extends StatefulWidget {
  const _NotificationButton({
    this.onTap,
    this.hasNotifications = false,
  });

  final VoidCallback? onTap;
  final bool hasNotifications;

  @override
  State<_NotificationButton> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<_NotificationButton>
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
          width: AppResponsive.s(context, 48),
          height: AppResponsive.s(context, 48),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF5C5C5C).withValues(alpha: 0.07),
            // border: Border.all(
            //   color: AppColors.glassBorder,
            //   width: AppResponsive.thickness(context, 1),
            // ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SvgPicture.asset(
                AppAssets.notificationIcon,
                width:
                    AppResponsive.icon(context, AppTokens.notificationIconSize),
                height:
                    AppResponsive.icon(context, AppTokens.notificationIconSize),
                colorFilter: const ColorFilter.mode(
                  Color(0xFF212121),
                  BlendMode.srcIn,
                ),
              ),
              // if (widget.hasNotifications)
              //   Positioned(
              //     top: AppResponsive.s(context, 10),
              //     right: AppResponsive.s(context, 12),
              //     child: Container(
              //       width: AppResponsive.s(context, 8),
              //       height: AppResponsive.s(context, 8),
              //       decoration: BoxDecoration(
              //         shape: BoxShape.circle,
              //         color: AppColors.error,
              //         border: Border.all(
              //           color: AppColors.surfaceDark,
              //           width: AppResponsive.thickness(context, 1.5),
              //         ),
              //       ),
              //     ),
              //   ),
            ],
          ),
        ),
      ),
    );
  }
}
