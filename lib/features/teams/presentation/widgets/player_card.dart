import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors_new.dart';
import '../../../../core/theme/app_responsive.dart';
import '../../data/models/team_player_model.dart';
import '../providers/teams_providers.dart';

/// Player card widget for displaying individual player in a team
class PlayerCard extends ConsumerWidget {
  const PlayerCard({
    super.key,
    required this.player,
    this.onDeleteTap,
  });

  final dynamic player;
  final VoidCallback? onDeleteTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Support both TeamPlayerModel and Map<String, dynamic>
    final String name;
    final String role;
    final String proficiency;
    final String? imageFile;

    if (player is TeamPlayerModel) {
      name = player.playerName ?? 'Unknown Player';
      role = player.sportRole ?? 'Player';
      proficiency = player.proficiencyLevel ?? '';
      imageFile = player.imageFile;
    } else if (player is Map<String, dynamic>) {
      name = player['playerName'] as String? ??
          player['player'] as String? ??
          player['name'] as String? ??
          'Unknown Player';
      role = player['sportRole'] as String? ??
          player['role'] as String? ??
          'Player';
      proficiency = player['proficiencyLevel'] as String? ?? '';
      imageFile =
          player['imageFile'] as String? ?? player['imageUrl'] as String?;
    } else {
      name = 'Unknown Player';
      role = 'Player';
      proficiency = '';
      imageFile = null;
    }

    // Get player image URL
    final repository = ref.watch(teamsRepositoryProvider);
    final imageUrl = repository.getPlayerImageUrl(imageFile);

    return Column(
      children: [
        Padding(
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
                  child: (imageUrl != null && imageUrl.isNotEmpty)
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
                    // Player Name + Proficiency Badge Row
                    Row(
                      children: [
                        // Player Name
                        Flexible(
                          child: Text(
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
                        ),
                        // Proficiency Badge
                        if (proficiency.isNotEmpty) ...[
                          SizedBox(width: AppResponsive.s(context, 8)),
                          Container(
                            padding: AppResponsive.paddingSymmetric(
                              context,
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text(
                              proficiency,
                              style: TextStyle(
                                fontFamily: 'SFProRounded',
                                fontSize: AppResponsive.font(context, 12),
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF5C5C5C),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: AppResponsive.s(context, 4)),

                    // Player Role
                    if (role.isNotEmpty)
                      Text(
                        role,
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

              SizedBox(width: AppResponsive.s(context, 8)),

              // Delete Icon
              GestureDetector(
                onTap: onDeleteTap,
                child: SvgPicture.asset(
                  'assets/icons/delete.svg',
                  width: AppResponsive.s(context, 36),
                  height: AppResponsive.s(context, 36),
                ),
              ),
            ],
          ),
        ),
        // Divider
        Padding(
          padding: AppResponsive.paddingSymmetric(
            context,
            horizontal: 16,
          ),
          child: Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFF0A1217).withOpacity(0.25),
          ),
        ),
      ],
    );
  }
}
