import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../theme/app_responsive.dart';

/// Match Status Badge Types
enum MatchStatusType {
  approved,
  pending,
  denied,
  completed,
  abandoned,
  custom,
}

/// Global Match Card Widget - Highly customizable with all variations
/// Supports: Top badges, action buttons, status badges, live matches, VS matches
class MatchCardNew extends StatelessWidget {
  /// Factory method to easily generate UI from matchStatusId
  /// Statuses: 0 = Pending, 1 = Live, 2 = Completed, 3 = Abandoned
  factory MatchCardNew.fromMatchStatus({
    Key? key,
    required int matchStatusId,
    required String team1Name,
    required String team1Section,
    String? team1AvatarUrl,
    required String team2Name,
    required String team2Section,
    String? team2AvatarUrl,
    required String headerLabel,
    int? team1Score,
    int? team2Score,
    String? matchDate,
    String? matchTime,
    // Role based
    bool isCaptain = false,
    bool teamSheetUploaded = false,
    VoidCallback? onUploadTeamSheet,
    // Callbacks
    VoidCallback? onWatchLive,
    VoidCallback? onNext,
    VoidCallback? onTap,
    String? winnerTeamName,
  }) {
    bool showScore = false;
    bool showVS = true;
    bool isLive = false;
    bool showLiveBadge = false;
    String? centerActionText;
    VoidCallback? onCenterActionTap;
    String? bottomActionText;
    VoidCallback? onBottomActionTap;

    switch (matchStatusId) {
      case 1: // Live
        showScore = true;
        isLive = true;
        showLiveBadge = true;
        bottomActionText = 'Watch Live';
        onBottomActionTap = onWatchLive;
        break;
      case 2: // Completed
        showScore = true;
        centerActionText = winnerTeamName != null
            ? '$winnerTeamName Is Winner'
            : 'Match Completed';
        break;
      case 3: // Abandoned
        showScore = false;
        showVS = true;
        break;
      case 0: // Pending
      default:
        showScore = false;
        showVS = false;
        if (isCaptain) {
          if (!teamSheetUploaded) {
            centerActionText = 'Upload Sheet';
            onCenterActionTap = onUploadTeamSheet;
          } else {
            centerActionText = 'Sheet Uploaded';
          }
        } else {
          centerActionText = 'Next';
          onCenterActionTap = onNext;
        }
        break;
    }

    return MatchCardNew(
      key: key,
      team1Name: team1Name,
      team1Section: team1Section,
      team1AvatarUrl: team1AvatarUrl,
      team2Name: team2Name,
      team2Section: team2Section,
      team2AvatarUrl: team2AvatarUrl,
      headerLabel: headerLabel,
      showScore: showScore,
      team1Score: team1Score,
      team2Score: team2Score,
      matchDate: matchDate,
      matchTime: matchTime,
      isLive: isLive,
      showLiveBadge: showLiveBadge,
      showVS: showVS,
      centerActionButtonText: centerActionText,
      onCenterActionButtonTap: onCenterActionTap,
      actionButtonText: bottomActionText,
      onActionButtonTap: onBottomActionTap,
      fullWidthActionButton: bottomActionText != null,
      onTap: onTap,
    );
  }

  const MatchCardNew({
    super.key,
    // Team info
    required this.team1Name,
    required this.team1Section,
    this.team1AvatarUrl,
    required this.team2Name,
    required this.team2Section,
    this.team2AvatarUrl,
    // Header label (Round name, Set number, etc.)
    required this.headerLabel,
    // Display mode flags
    this.showScore = false,
    this.team1Score,
    this.team2Score,
    this.matchDate,
    this.matchTime,
    // Live badge
    this.isLive = false,
    this.showLiveBadge = false,
    // Top notification badge
    this.topBadgeText,
    this.topBadgeIcon,
    this.topBadgeColor,
    // Action button
    this.actionButtonText,
    this.onActionButtonTap,
    this.fullWidthActionButton = false,
    // Center Action Button (small pill)
    this.centerActionButtonText,
    this.onCenterActionButtonTap,
    this.centerActionButtonColor,
    this.centerActionButtonTextColor,
    // Options
    this.showVS = true,
    // Status badge at bottom
    this.statusType,
    this.statusText,
    this.customStatusColor,
    // Customization
    this.onTap,
    this.margin,
    this.enableShadow = false,
    this.gradientColors,
  });

  // Team information
  final String team1Name;
  final String team1Section;
  final String? team1AvatarUrl;
  final String team2Name;
  final String team2Section;
  final String? team2AvatarUrl;

  // Header label
  final String headerLabel;

  // Display mode
  final bool showScore;
  final int? team1Score;
  final int? team2Score;
  final String? matchDate;
  final String? matchTime;

  // Live indicators
  final bool isLive;
  final bool showLiveBadge;

  // Top notification badge (e.g., "Your Assign by Captain for this Match")
  final String? topBadgeText;
  final IconData? topBadgeIcon;
  final Color? topBadgeColor;

  // Action button (e.g., "Assign Player")
  final String? actionButtonText;
  final VoidCallback? onActionButtonTap;
  final bool fullWidthActionButton;

  // Center Action button (small pill, e.g. "Next", "Upload Sheet")
  final String? centerActionButtonText;
  final VoidCallback? onCenterActionButtonTap;
  final Color? centerActionButtonColor;
  final Color? centerActionButtonTextColor;

  // Options
  final bool showVS;

  // Status badge at bottom
  final MatchStatusType? statusType;
  final String? statusText;
  final Color? customStatusColor;

  // Customization
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final bool enableShadow;
  final List<Color>? gradientColors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin ??
            AppResponsive.padding(context, horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: gradientColors ??
                [
                  const Color(0xFFBDD7F5),
                  const Color(0xFF67A9F4),
                  const Color(0xFF1377E8),
                ],
          ),
          borderRadius: BorderRadius.circular(AppResponsive.s(context, 24)),
          boxShadow: enableShadow
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top notification badge (if provided)
            if (topBadgeText != null) _buildTopBadge(context),

            // Main content
            Padding(
              padding:
                  AppResponsive.padding(context, horizontal: 16, vertical: 16),
              child: Column(
                children: [
                  // Header label
                  Text(
                    headerLabel,
                    style: TextStyle(
                      fontFamily: 'SFProRounded',
                      fontSize: AppResponsive.font(context, 15),
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: AppResponsive.s(context, 2)),

                  // Teams row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Team 1
                      Expanded(
                        flex: 2,
                        child: _TeamColumn(
                          teamName: team1Name,
                          section: team1Section,
                          avatarUrl: team1AvatarUrl,
                        ),
                      ),

                      // Center content (Score OR VS + Date/Time + Action Button)
                      Expanded(
                        flex: 3,
                        child: _buildCenterContent(context),
                      ),

                      // Team 2
                      Expanded(
                        flex: 2,
                        child: _TeamColumn(
                          teamName: team2Name,
                          section: team2Section,
                          avatarUrl: team2AvatarUrl,
                        ),
                      ),
                    ],
                  ),

                  // Action button below row:
                  // • always when fullWidthActionButton=true
                  // • or in score mode
                  if ((showScore || fullWidthActionButton) &&
                      actionButtonText != null) ...[
                    SizedBox(height: AppResponsive.s(context, 12)),
                    _buildFullWidthActionButton(context),
                  ],
                ],
              ),
            ),

            // Status badge at bottom (if provided)
            if (statusType != null || statusText != null)
              _buildStatusBadge(context),
          ],
        ),
      ),
    );
  }

  /// Build top notification badge
  Widget _buildTopBadge(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppResponsive.padding(context, horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: topBadgeColor ?? const Color(0xFF2196F3),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppResponsive.s(context, 24)),
          topRight: Radius.circular(AppResponsive.s(context, 24)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (topBadgeIcon != null) ...[
            Icon(
              topBadgeIcon,
              size: AppResponsive.icon(context, 14),
              color: Colors.white,
            ),
            SizedBox(width: AppResponsive.s(context, 4)),
          ],
          Flexible(
            child: Text(
              topBadgeText!,
              style: TextStyle(
                fontFamily: 'SFProRounded',
                fontSize: AppResponsive.font(context, 11),
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  /// Build center content - either score or VS with date/time
  Widget _buildCenterContent(BuildContext context) {
    if (showScore) {
      // Show score (for live/completed matches)
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${team1Score?.toString().padLeft(2, '0') ?? '00'} : ${team2Score?.toString().padLeft(2, '0') ?? '00'}',
            style: TextStyle(
              fontFamily: 'SFProRounded',
              fontSize: AppResponsive.font(context, 26),
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          // Show date below score (e.g., "15 Dec 2025")
          if (matchDate != null && !(showLiveBadge && isLive)) ...[
            SizedBox(height: AppResponsive.s(context, 2)),
            Text(
              matchDate!,
              style: TextStyle(
                fontFamily: 'SFProRounded',
                fontSize: AppResponsive.font(context, 10),
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (showLiveBadge && isLive) ...[
            SizedBox(height: AppResponsive.s(context, 6)),
            _buildLiveBadge(context),
          ],
          if (centerActionButtonText != null) ...[
            SizedBox(height: AppResponsive.s(context, 8)),
            _buildCenterActionButton(context),
          ],
        ],
      );
    } else {
      // Show VS with action button and date/time (for upcoming matches)
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showVS)
            Text(
              'VS',
              style: TextStyle(
                fontFamily: 'SFProRounded',
                fontSize: AppResponsive.font(context, 24),
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          // Center Action button (if provided) - small pill in center
          if (centerActionButtonText != null && !fullWidthActionButton) ...[
            SizedBox(height: AppResponsive.s(context, showVS ? 6 : 0)),
            _buildCenterActionButton(context),
          ],
          // Date/Time below
          if (matchDate != null || matchTime != null) ...[
            SizedBox(height: AppResponsive.s(context, 4)),
            if (matchTime != null)
              Text(
                showVS ? matchTime! : 'Start at $matchTime',
                style: TextStyle(
                  fontFamily: 'SFProRounded',
                  fontSize: AppResponsive.font(context, 12),
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            if (matchDate != null)
              Text(
                matchDate!,
                style: TextStyle(
                  fontFamily: 'SFProRounded',
                  fontSize: AppResponsive.font(context, 12),
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ],
      );
    }
  }

  /// Build live badge
  Widget _buildLiveBadge(BuildContext context) {
    return Container(
      padding: AppResponsive.padding(context, horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFDB0C00),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: AppResponsive.s(context, 3)),
          Text(
            'Live',
            style: TextStyle(
              fontFamily: 'SFProRounded',
              fontSize: AppResponsive.font(context, 11),
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Build small pill action button (for VS mode - e.g., "Next")
  Widget _buildCenterActionButton(BuildContext context) {
    return GestureDetector(
      onTap: onCenterActionButtonTap,
      child: Container(
        padding: AppResponsive.paddingSymmetric(
          context,
          horizontal: 14,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: centerActionButtonColor ?? Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          centerActionButtonText!,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'SFProRounded',
            fontSize: AppResponsive.font(context, 11),
            fontWeight: FontWeight.w600,
            color: centerActionButtonTextColor ?? const Color(0xFF1377E8),
          ),
        ),
      ),
    );
  }

  /// Build full-width action button (for score mode - e.g., "Watch Live")
  Widget _buildFullWidthActionButton(BuildContext context) {
    return GestureDetector(
      onTap: onActionButtonTap,
      child: Container(
        width: double.infinity,
        padding: AppResponsive.padding(context, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          actionButtonText!,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'SFProRounded',
            fontSize: AppResponsive.font(context, 14),
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1377E8),
          ),
        ),
      ),
    );
  }

  /// Build status badge at bottom
  Widget _buildStatusBadge(BuildContext context) {
    Color bgColor;
    Color textColor;
    IconData? icon;

    switch (statusType) {
      case MatchStatusType.approved:
        bgColor = const Color(0xFF4CAF50);
        textColor = Colors.white;
        icon = Icons.check_circle;
        break;
      case MatchStatusType.pending:
        bgColor = const Color(0xFFFF6B9D);
        textColor = Colors.white;
        icon = Icons.access_time;
        break;
      case MatchStatusType.denied:
        bgColor = const Color(0xFFE53935);
        textColor = Colors.white;
        icon = Icons.cancel;
        break;
      case MatchStatusType.completed:
        bgColor = const Color(0xFF3AA318);
        textColor = Colors.white;
        icon = Icons.check;
        break;
      case MatchStatusType.abandoned:
        bgColor = const Color(0xFF5C5C5C);
        textColor = Colors.white;
        icon = Icons.warning;
        break;
      case MatchStatusType.custom:
        bgColor = customStatusColor ?? Colors.grey;
        textColor = Colors.white;
        icon = null;
        break;
      default:
        bgColor = Colors.grey;
        textColor = Colors.white;
        icon = null;
    }

    return Container(
      width: double.infinity,
      padding: AppResponsive.padding(context, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppResponsive.s(context, 24)),
          bottomRight: Radius.circular(AppResponsive.s(context, 24)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: textColor,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: AppResponsive.s(context, 6)),
          ],
          Text(
            statusText ?? statusType!.name.toUpperCase(),
            style: TextStyle(
              fontFamily: 'SFProRounded',
              fontSize: AppResponsive.font(context, 12),
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Team Column Widget - Shows avatar, name, and section
class _TeamColumn extends StatelessWidget {
  const _TeamColumn({
    required this.teamName,
    required this.section,
    this.avatarUrl,
  });

  final String teamName;
  final String section;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar
        Container(
          width: AppResponsive.s(context, 56),
          height: AppResponsive.s(context, 56),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            // border: Border.all(
            //   color: Colors.white,
            //   width: 2,
            // ),
          ),
          child: ClipOval(
            child: avatarUrl != null && avatarUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: avatarUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _buildPlaceholder(context),
                  )
                : _buildPlaceholder(context),
          ),
        ),
        SizedBox(height: AppResponsive.s(context, 6)),
        // Team name
        Text(
          teamName,
          style: TextStyle(
            fontFamily: 'SFProRounded',
            fontSize: AppResponsive.font(context, 17),
            fontWeight: FontWeight.w700,
            height: 1.2,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        // SizedBox(height: AppResponsive.s(context, 2)),
        Text(
          section,
          style: TextStyle(
            fontFamily: 'SFProRounded',
            fontSize: AppResponsive.font(context, 13),
            fontWeight: FontWeight.w500,
            color: const Color(0xFF454545),
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Text(
          teamName.isNotEmpty ? teamName[0].toUpperCase() : 'A',
          style: TextStyle(
            fontFamily: 'SFProRounded',
            fontSize: AppResponsive.font(context, 22),
            fontWeight: FontWeight.w700,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }
}
