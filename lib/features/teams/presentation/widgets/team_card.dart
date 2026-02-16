import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors_new.dart';
import '../../../../core/theme/app_responsive.dart';
import '../../data/models/manager_team_model.dart';
import '../providers/teams_providers.dart';

/// Team card widget with glassmorphism effect
class TeamCard extends ConsumerWidget {
  const TeamCard({
    super.key,
    required this.team,
    this.onTap,
    this.onLongPress,
  });

  final ManagerTeamModel team;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.read(teamsRepositoryProvider);
    final imageUrl = repository.getTeamImageUrl(team.imageFile);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: AppResponsive.padding(context, horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: AppResponsive.padding(context, all: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.95),
                    Colors.white.withOpacity(0.85),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Team Logo
                  Container(
                    width: AppResponsive.s(context, 80),
                    height: AppResponsive.s(context, 80),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.surfaceLight,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentBlue.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: AppColors.surfaceLight,
                                child: Center(
                                  child: Icon(
                                    Icons.shield_outlined,
                                    size: AppResponsive.s(context, 32),
                                    color: AppColors.textMutedLight,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: AppColors.surfaceLight,
                                child: Center(
                                  child: Icon(
                                    Icons.shield_outlined,
                                    size: AppResponsive.s(context, 32),
                                    color: AppColors.textMutedLight,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              color: AppColors.surfaceLight,
                              child: Center(
                                child: Icon(
                                  Icons.shield_outlined,
                                  size: AppResponsive.s(context, 32),
                                  color: AppColors.textMutedLight,
                                ),
                              ),
                            ),
                    ),
                  ),
                  SizedBox(width: AppResponsive.s(context, 16)),

                  // Team Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Team Name
                        Text(
                          team.name,
                          style: TextStyle(
                            fontSize: AppResponsive.font(context, 18),
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: AppResponsive.s(context, 4)),

                        // Sport Badge
                        if (team.sportName != null &&
                            team.sportName!.isNotEmpty)
                          Container(
                            padding: AppResponsive.padding(
                              context,
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accentBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              team.sportName!,
                              style: TextStyle(
                                fontSize: AppResponsive.font(context, 12),
                                fontWeight: FontWeight.w600,
                                color: AppColors.accentBlue,
                              ),
                            ),
                          ),
                        SizedBox(height: AppResponsive.s(context, 8)),

                        // Description
                        if (team.description != null &&
                            team.description!.isNotEmpty)
                          Text(
                            team.description!,
                            style: TextStyle(
                              fontSize: AppResponsive.font(context, 14),
                              color: AppColors.textSecondaryLight,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),

                  // Arrow Icon
                  Icon(
                    Icons.mode_edit_outlined,
                    color: AppColors.textMutedLight,
                    size: AppResponsive.s(context, 20),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
