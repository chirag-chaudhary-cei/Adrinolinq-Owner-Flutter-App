import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/onboarding_providers.dart';
import '../../core/theme/app_colors_new.dart';
import '../../core/theme/app_responsive.dart';
import '../../core/theme/app_animations.dart';
import '../../core/utils/app_assets.dart';
import 'app_loading.dart';

/// Model for event data
class EventModel {
  final String id;
  final String title;
  final String location;
  final String imageUrl;
  final String date;
  final String time;
  final String price;
  final String category;
  final int? sportId;
  final List<String> tags;
  final int registeredCount;
  final int maxParticipants;
  final bool isLive;
  final bool openOrClose; // true = open registration, false = invite only
  final String? inviteCode; // for invite-only tournaments
  final String? registrationStatus; // e.g., "Pending", "Confirmed"
  final String? paymentStatus; // e.g., "Pending", "Paid"
  final String community; // community name

  const EventModel({
    required this.id,
    required this.title,
    required this.location,
    required this.imageUrl,
    required this.date,
    required this.time,
    required this.price,
    required this.category,
    this.sportId,
    required this.tags,
    required this.registeredCount,
    required this.maxParticipants,
    this.isLive = false,
    this.openOrClose = true,
    this.inviteCode,
    this.registrationStatus,
    this.paymentStatus,
    this.community = '',
  });

  bool get isFull => registeredCount >= maxParticipants;
  String get participantsText => '$registeredCount/$maxParticipants Registered';
}

/// Event card widget with glassmorphism effect - matches design exactly
class EventCard extends StatefulWidget {
  const EventCard({
    super.key,
    required this.event,
    this.onTap,
    this.onViewDetails,
    this.width,
  });

  final EventModel event;
  final VoidCallback? onTap;
  final VoidCallback? onViewDetails;
  final double? width;

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.standard),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final cardWidth = widget.width ?? AppResponsive.s(context, 300);
    final cardHeight = AppResponsive.s(context, 350);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.onTap,
        child: Container(
          width: cardWidth,
          height: cardHeight,
          decoration: BoxDecoration(
            borderRadius: AppResponsive.borderRadius(context, 33),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.13),
              width: AppResponsive.thickness(context, 1),
            ),
          ),
          child: ClipRRect(
            borderRadius: AppResponsive.borderRadius(context, 33),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: AppResponsive.borderRadius(context, 33),
              ),
              child: ClipRRect(
                borderRadius: AppResponsive.borderRadius(context, 33),
                child: Stack(
                  children: [
                    // Background image - full card
                    Positioned.fill(
                      child: widget.event.imageUrl.startsWith('http')
                          ? CachedNetworkImage(
                              imageUrl: widget.event.imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  AppLoading.imagePlaceholder(
                                backgroundColor: AppColors.cardBackground,
                                indicatorSize: AppResponsive.icon(context, 24),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: AppColors.cardBackground,
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: AppColors.iconMuted,
                                  size: AppResponsive.icon(context, 48),
                                ),
                              ),
                            )
                          : Image.asset(
                              widget.event.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppColors.cardBackground,
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: AppColors.iconMuted,
                                    size: AppResponsive.icon(context, 48),
                                  ),
                                );
                              },
                            ),
                    ),

                    // Live badge OR Price tag OR Invite Code badge - top right
                    Positioned(
                      top: AppResponsive.s(context, 14),
                      right: AppResponsive.s(context, 16),
                      child: widget.event.isLive
                          ? const _LiveBadge()
                          : widget.event.openOrClose
                              ? _PriceTag(price: widget.event.price)
                              : _InviteCodeBadge(code: widget.event.inviteCode),
                    ),

                    // Glassmorphism bottom panel
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppResponsive.s(context, 6),
                          vertical: AppResponsive.s(context, 6),
                        ),
                        child: _GlassBottomPanel(
                          event: widget.event,
                          onViewDetails: widget.onViewDetails,
                        ),
                      ),
                    ),

                    // Category chip removed — sport is shown inside tags row below
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Live badge widget
class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppResponsive.paddingSymmetric(
        context,
        horizontal: 15,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        borderRadius: AppResponsive.borderRadius(context, 16),
        color: const Color(0xFFFF3B30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AppResponsive.s(context, 6),
            height: AppResponsive.s(context, 6),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
          AppResponsive.horizontalSpace(context, 4),
          Text(
            'Live',
            style: TextStyle(
              fontSize: AppResponsive.font(context, 12),
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Price tag with gradient background
class _PriceTag extends StatefulWidget {
  const _PriceTag({required this.price});

  final String price;

  @override
  State<_PriceTag> createState() => _PriceTagState();
}

class _PriceTagState extends State<_PriceTag>
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
    // Check if price is 0 or Free
    final isFree = widget.price == '0' ||
        widget.price == '0.0' ||
        widget.price.toLowerCase() == 'free';
    final displayText = isFree ? 'Free' : 'INR ${widget.price}';

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppResponsive.borderRadius(context, 16),
            color: Colors.black.withValues(alpha: 0.15),
          ),
          child: Container(
            padding: AppResponsive.paddingSymmetric(
              context,
              horizontal: 15,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              borderRadius: AppResponsive.borderRadius(context, 16),
              color: AppColors.accentBlue,
            ),
            child: Text(
              displayText,
              style: TextStyle(
                fontSize: AppResponsive.font(context, 12),
                fontWeight: FontWeight.w900,
                color: AppColors.onPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Invite code badge for closed/invite-only tournaments
class _InviteCodeBadge extends StatelessWidget {
  const _InviteCodeBadge({this.code});

  final String? code;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: AppResponsive.borderRadius(context, 16),
        color: Colors.black.withValues(alpha: 0.15),
      ),
      child: Container(
        padding: AppResponsive.paddingSymmetric(
          context,
          horizontal: 12,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          borderRadius: AppResponsive.borderRadius(context, 16),
          color: const Color(0xFFCDFE00), // Green for invite-only
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline,
              size: AppResponsive.icon(context, 12),
              color: Colors.black,
            ),
            AppResponsive.horizontalSpace(context, 4),
            Text(
              'Invite Only',
              style: TextStyle(
                fontSize: AppResponsive.font(context, 11),
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Category chip with elevated styling

/// Glassmorphism bottom panel with event details
class _GlassBottomPanel extends StatelessWidget {
  const _GlassBottomPanel({
    required this.event,
    this.onViewDetails,
  });

  final EventModel event;
  final VoidCallback? onViewDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppResponsive.padding(
        context,
        horizontal: 16,
        vertical: 10,
        top: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppResponsive.radius(context, 30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Text(
            event.title,
            style: TextStyle(
              fontSize: AppResponsive.font(context, 17),
              fontWeight: FontWeight.w900,
              color: const Color(0xFF212121),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          //community
          Text(
            event.community,
            style: TextStyle(
              fontSize: AppResponsive.font(context, 12),
              fontWeight: FontWeight.w500,
              color: const Color(0xFF3E8EE9),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          AppResponsive.verticalSpace(context, 2),

          // Location
          Text(
            event.location,
            style: TextStyle(
              fontSize: AppResponsive.font(context, 12),
              fontWeight: FontWeight.w500,
              color: const Color(0xFF212121).withValues(alpha: 0.43),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          AppResponsive.verticalSpace(context, 3),

          // Date and time row
          Row(
            children: [
              SvgPicture.asset(
                AppAssets.calendarIcon,
                width: AppResponsive.icon(context, 13),
                height: AppResponsive.icon(context, 13),
                colorFilter: const ColorFilter.mode(
                  Color(0xFF757575),
                  BlendMode.srcIn,
                ),
              ),
              AppResponsive.horizontalSpace(context, 6),
              Text(
                event.time.isNotEmpty
                    ? '${event.date} . ${event.time}'
                    : event.date,
                style: TextStyle(
                  fontSize: AppResponsive.font(context, 12),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6F6F6F),
                ),
              ),
            ],
          ),
          AppResponsive.verticalSpace(context, 3),

          // Tags row - show sport name and Tournament tag
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  right: AppResponsive.s(context, 6),
                ),
                child: _TagChip(tag: event.category),
              ),
              if (event.tags.isNotEmpty && event.tags.length > 1)
                Padding(
                  padding: EdgeInsets.only(
                    right: AppResponsive.s(context, 6),
                  ),
                  child: const _TagChip(tag: 'Tournament'),
                ),
            ],
          ),
          AppResponsive.verticalSpace(context, 4),

          // Bottom row - Participants and View Details button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LEFT SIDE — constrain width
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                        right: AppResponsive.s(context, 5),
                      ),
                      height: AppResponsive.s(context, 1),
                      decoration: BoxDecoration(
                        borderRadius: AppResponsive.borderRadius(context, 2),
                        color: const Color(0xFFE0E0E0),
                      ),
                    ),
                    SizedBox(
                      height: AppResponsive.s(context, 30),
                      child: Align(
                        alignment: Alignment.center,
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              AppAssets.multiPersonIcon,
                              width: AppResponsive.icon(context, 18),
                              height: AppResponsive.icon(context, 18),
                              colorFilter: const ColorFilter.mode(
                                Color(0xFF616161),
                                BlendMode.srcIn,
                              ),
                            ),
                            AppResponsive.horizontalSpace(context, 3),
                            Text(
                              event.participantsText,
                              style: TextStyle(
                                fontSize: AppResponsive.font(context, 12),
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF6F6F6F),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // RIGHT SIDE — untouched
              _ViewDetailsButton(onTap: onViewDetails),
            ],
          ),
        ],
      ),
    );
  }
}

/// Tag chip widget
class _TagChip extends StatelessWidget {
  const _TagChip({required this.tag});

  final String tag;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppResponsive.paddingSymmetric(
        context,
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        borderRadius: AppResponsive.borderRadius(context, 16),
        color: const Color(0xFF5C5C5C).withValues(alpha: 0.07),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            AppAssets.trophyIcon,
            width: AppResponsive.icon(context, 10),
            height: AppResponsive.icon(context, 10),
            colorFilter: const ColorFilter.mode(
              Color(0xFF616161),
              BlendMode.srcIn,
            ),
          ),
          AppResponsive.horizontalSpace(context, 3),
          Text(
            tag,
            style: TextStyle(
              fontSize: AppResponsive.font(context, 10),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF212121).withValues(alpha: 0.63),
            ),
          ),
        ],
      ),
    );
  }
}

/// View Details button with gradient
class _ViewDetailsButton extends StatefulWidget {
  const _ViewDetailsButton({this.onTap});

  final VoidCallback? onTap;

  @override
  State<_ViewDetailsButton> createState() => _ViewDetailsButtonState();
}

class _ViewDetailsButtonState extends State<_ViewDetailsButton>
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
          width: AppResponsive.s(context, 110),
          height: AppResponsive.s(context, 30),
          decoration: BoxDecoration(
            borderRadius: AppResponsive.borderRadius(context, 32),
            color: const Color(0xFFCDFE00),
          ),
          child: Center(
            child: Text(
              'View Details',
              style: TextStyle(
                fontSize: AppResponsive.font(context, 12),
                fontWeight: FontWeight.bold,
                color: const Color(0xFF000000),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
