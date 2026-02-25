import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors_new.dart';
import '../../../../core/theme/app_responsive.dart';
import '../../data/models/manager_team_model.dart';
import '../../data/models/team_player_model.dart';
import '../providers/teams_providers.dart';

/// Team card widget matching the design specifications
class TeamCard extends ConsumerWidget {
  const TeamCard({
    super.key,
    required this.team,
    required this.onManage,
    required this.onEdit,
    required this.onDelete,
  });

  final ManagerTeamModel team;
  final VoidCallback onManage;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.read(teamsRepositoryProvider);
    final imageUrl = repository.getTeamImageUrl(team.imageFile);
    final playersAsync = ref.watch(teamPlayersProvider(team.id));

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
                  // Team Name + Player Count inline via RichText
                  Builder(builder: (context) {
                    final count = _currentPlayerCount(playersAsync);
                    return RichText(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                          if (count > 0) ...[
                            const TextSpan(text: '  '),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Icon(
                                Icons.group,
                                size: AppResponsive.s(context, 13),
                                color: const Color(0xFF888888),
                              ),
                            ),
                            TextSpan(
                              text: ' $count Players',
                              style: TextStyle(
                                fontFamily: 'SFProRounded',
                                fontSize: AppResponsive.font(context, 12),
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF888888),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }),

                  // Sport row
                  if (team.sportName != null && team.sportName!.isNotEmpty) ...[
                    SizedBox(height: AppResponsive.s(context, 3)),
                    Row(
                      children: [
                        Icon(
                          Icons.sports,
                          size: AppResponsive.s(context, 13),
                          color: AppColors.accentBlue,
                        ),
                        SizedBox(width: AppResponsive.s(context, 3)),
                        Text(
                          team.sportName!,
                          style: TextStyle(
                            fontFamily: 'SFProRounded',
                            fontSize: AppResponsive.font(context, 12),
                            fontWeight: FontWeight.w500,
                            color: AppColors.accentBlue,
                          ),
                        ),
                      ],
                    ),
                  ],

                  if (team.description != null &&
                      team.description!.trim().isNotEmpty) ...[
                    SizedBox(height: AppResponsive.s(context, 3)),
                    Text(
                      team.description!,
                      style: TextStyle(
                        fontFamily: 'SFProRounded',
                        fontSize: AppResponsive.font(context, 13),
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF666666),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: AppResponsive.s(context, 12)),

            // More menu
            PopupMenuButton<_TeamAction>(
              tooltip: 'Team actions',
              icon: const Icon(Icons.more_vert, color: Colors.black87),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (action) {
                switch (action) {
                  case _TeamAction.manage:
                    onManage();
                    break;
                  case _TeamAction.edit:
                    onEdit();
                    break;
                  case _TeamAction.delete:
                    onDelete();
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<_TeamAction>(
                  value: _TeamAction.manage,
                  child: Row(
                    children: [
                      Icon(Icons.manage_accounts_outlined,
                          size: 18, color: AppColors.accentBlue),
                      const SizedBox(width: 10),
                      const Text('Manage Players'),
                    ],
                  ),
                ),
                PopupMenuItem<_TeamAction>(
                  value: _TeamAction.edit,
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined,
                          size: 18, color: AppColors.textPrimaryLight),
                      const SizedBox(width: 10),
                      const Text('Edit Team'),
                    ],
                  ),
                ),
                PopupMenuItem<_TeamAction>(
                  value: _TeamAction.delete,
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline,
                          size: 18, color: Colors.red.shade600),
                      const SizedBox(width: 10),
                      Text('Delete',
                          style: TextStyle(color: Colors.red.shade600)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  int _currentPlayerCount(AsyncValue<List<TeamPlayerModel>> playersAsync) {
    return playersAsync.when(
      data: (players) => players.length,
      loading: () => team.currentPlayers ?? 0,
      error: (_, __) => team.currentPlayers ?? 0,
    );
  }
}

enum _TeamAction { manage, edit, delete }
