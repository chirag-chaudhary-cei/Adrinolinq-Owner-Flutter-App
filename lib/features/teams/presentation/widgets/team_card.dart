import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors_new.dart';
import '../../../../core/theme/app_responsive.dart';
import '../../../../core/widgets/app_button.dart';
import '../../data/models/manager_team_model.dart';
import '../providers/teams_providers.dart';
import '../pages/team_players_page.dart';

/// Team card widget matching the design specifications
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

    return Container(
      margin: AppResponsive.padding(context, horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: AppResponsive.padding(context, all: 16),
        child: Row(
          children: [
            // Circular Team Picture
            Container(
              width: AppResponsive.s(context, 60),
              height: AppResponsive.s(context, 60),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceLight,
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
              child: ClipOval(
                child: imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.surfaceLight,
                          child: Center(
                            child: Icon(
                              Icons.shield_outlined,
                              size: AppResponsive.s(context, 24),
                              color: AppColors.textMutedLight,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.surfaceLight,
                          child: Center(
                            child: Icon(
                              Icons.shield_outlined,
                              size: AppResponsive.s(context, 24),
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
                            size: AppResponsive.s(context, 24),
                            color: AppColors.textMutedLight,
                          ),
                        ),
                      ),
              ),
            ),
            SizedBox(width: AppResponsive.s(context, 14)),

            // Team Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Team Name with Player Count
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: team.name,
                          style: TextStyle(
                            fontFamily: 'SFProRounded',
                            fontSize: AppResponsive.font(context, 16),
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: ' (11/15 Players)',
                          style: TextStyle(
                            fontFamily: 'SFProRounded',
                            fontSize: AppResponsive.font(context, 14),
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppResponsive.s(context, 4)),

                  // Captain/Manager Name
                  Text(
                    team.description ?? 'No description available',
                    style: TextStyle(
                      fontFamily: 'SFProRounded',
                      fontSize: AppResponsive.font(context, 14),
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF666666),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: AppResponsive.s(context, 12)),

            // Manage Button
            AppButton(
              text: 'Manage',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TeamPlayersPage(team: team),
                  ),
                );
              },
              width: AppResponsive.s(context, 90),
              height: AppResponsive.s(context, 36),
              fontSize: AppResponsive.font(context, 13),
            ),
          ],
        ),
      ),
    );
  }
}
