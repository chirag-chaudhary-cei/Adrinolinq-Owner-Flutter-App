import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/theme/app_colors_new.dart';
import '../../../../core/theme/app_responsive.dart';

/// Player card widget for displaying individual player in a team
class PlayerCard extends StatelessWidget {
  const PlayerCard({
    super.key,
    required this.player,
    this.onMenuTap,
  });

  final Map<String, dynamic> player;
  final VoidCallback? onMenuTap;

  @override
  Widget build(BuildContext context) {
    final name = player['name'] as String? ?? 'Unknown Player';
    final role = player['role'] as String? ?? '';
    final imageUrl = player['imageUrl'] as String? ?? '';

    return Padding(
      padding: AppResponsive.padding(
        context,
        horizontal: 16,
        vertical: 12,
      ),
      child: Row(
        children: [
          // Player Avatar
          Container(
            width: AppResponsive.s(context, 50),
            height: AppResponsive.s(context, 50),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
            ),
            child: ClipOval(
              child: imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade200,
                        child: Center(
                          child: Icon(
                            Icons.person,
                            size: AppResponsive.s(context, 24),
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade200,
                        child: Center(
                          child: Icon(
                            Icons.person,
                            size: AppResponsive.s(context, 24),
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Icon(
                        Icons.person,
                        size: AppResponsive.s(context, 24),
                        color: Colors.grey.shade400,
                      ),
                    ),
            ),
          ),
          SizedBox(width: AppResponsive.s(context, 12)),

          // Player Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Player Name
                Text(
                  name,
                  style: TextStyle(
                    fontFamily: 'SFProRounded',
                    fontSize: AppResponsive.font(context, 16),
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppResponsive.s(context, 4)),

                // Player Role
                Text(
                  'Left Arm Fast baller',
                  style: TextStyle(
                    fontFamily: 'SFProRounded',
                    fontSize: AppResponsive.font(context, 14),
                    fontWeight: FontWeight.w400,
                    color: AppColors.accentBlue,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Role Badge
          if (role.isNotEmpty)
            Container(
              padding: AppResponsive.paddingSymmetric(
                context,
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                role,
                style: TextStyle(
                  fontFamily: 'SFProRounded',
                  fontSize: AppResponsive.font(context, 12),
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          SizedBox(width: AppResponsive.s(context, 8)),

          // Menu Icon
          GestureDetector(
            onTap: onMenuTap,
            child: Icon(
              Icons.more_vert,
              color: Colors.grey.shade600,
              size: AppResponsive.s(context, 24),
            ),
          ),
        ],
      ),
    );
  }
}
