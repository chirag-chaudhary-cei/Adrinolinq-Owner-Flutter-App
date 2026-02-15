import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors_new.dart';
import '../../../../core/theme/app_responsive.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_search_bar.dart';
import '../../data/models/manager_team_model.dart';
import '../providers/teams_providers.dart';
import '../widgets/team_card.dart';
import 'create_team_page.dart';

/// Teams Page - View and manage manager-owned teams
class TeamsPage extends ConsumerStatefulWidget {
  const TeamsPage({super.key});

  @override
  ConsumerState<TeamsPage> createState() => _TeamsPageState();
}

class _TeamsPageState extends ConsumerState<TeamsPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final teamsAsync = ref.watch(teamsListProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Add Team button
            Padding(
              padding:
                  AppResponsive.padding(context, horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Teams',
                          style: TextStyle(
                            fontSize: AppResponsive.font(context, 24),
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                        SizedBox(height: AppResponsive.s(context, 4)),
                        Text(
                          'Manage your teams',
                          style: TextStyle(
                            fontSize: AppResponsive.font(context, 14),
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Add Team Button
                  SizedBox(
                    height: AppResponsive.s(context, 40),
                    child: AppButton(
                      text: '+ Add Team',
                      onPressed: () => _navigateToCreateTeam(),
                      fontSize: AppResponsive.font(context, 14),
                      horizontalPadding: 16,
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: AppResponsive.padding(context, horizontal: 20),
              child: AppSearchBar(
                hintText: 'Search Teams',
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
            SizedBox(height: AppResponsive.s(context, 16)),

            // Teams List
            Expanded(
              child: teamsAsync.when(
                data: (teams) {
                  // Filter teams based on search query
                  final filteredTeams = _searchQuery.isEmpty
                      ? teams
                      : teams.where((team) {
                          final name = team.name.toLowerCase();
                          final sport = team.sportName?.toLowerCase() ?? '';
                          return name.contains(_searchQuery) ||
                              sport.contains(_searchQuery);
                        }).toList();

                  if (filteredTeams.isEmpty) {
                    return RefreshIndicator(
                      color: AppColors.accentBlue,
                      onRefresh: () async {
                        ref.invalidate(teamsListProvider);
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shield_outlined,
                                  size: AppResponsive.s(context, 64),
                                  color: AppColors.textMutedLight,
                                ),
                                SizedBox(height: AppResponsive.s(context, 16)),
                                Text(
                                  _searchQuery.isEmpty
                                      ? 'No teams yet'
                                      : 'No teams found',
                                  style: TextStyle(
                                    fontSize: AppResponsive.font(context, 18),
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimaryLight,
                                  ),
                                ),
                                SizedBox(height: AppResponsive.s(context, 8)),
                                Text(
                                  _searchQuery.isEmpty
                                      ? 'Create your first team'
                                      : 'Try a different search',
                                  style: TextStyle(
                                    fontSize: AppResponsive.font(context, 14),
                                    color: AppColors.textSecondaryLight,
                                  ),
                                ),
                                if (_searchQuery.isEmpty) ...[
                                  SizedBox(
                                      height: AppResponsive.s(context, 24)),
                                  Text(
                                    'Pull down to refresh',
                                    style: TextStyle(
                                      fontSize: AppResponsive.font(context, 12),
                                      color: AppColors.textMutedLight,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.accentBlue,
                    onRefresh: () async {
                      ref.invalidate(teamsListProvider);
                    },
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: filteredTeams.length,
                      itemBuilder: (context, index) {
                        final team = filteredTeams[index];
                        return TeamCard(
                          team: team,
                          onTap: () => _navigateToEditTeam(team),
                        );
                      },
                    ),
                  );
                },
                loading: () => Center(
                  child: AppLoading.circular(),
                ),
                error: (error, stack) => RefreshIndicator(
                  color: AppColors.accentBlue,
                  onRefresh: () async {
                    ref.invalidate(teamsListProvider);
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: AppResponsive.s(context, 64),
                              color: Colors.red.shade300,
                            ),
                            SizedBox(height: AppResponsive.s(context, 16)),
                            Text(
                              'Failed to load teams',
                              style: TextStyle(
                                fontSize: AppResponsive.font(context, 18),
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimaryLight,
                              ),
                            ),
                            SizedBox(height: AppResponsive.s(context, 8)),
                            Padding(
                              padding: AppResponsive.padding(context,
                                  horizontal: 40),
                              child: Text(
                                error
                                    .toString()
                                    .replaceFirst('Exception: ', ''),
                                style: TextStyle(
                                  fontSize: AppResponsive.font(context, 14),
                                  color: AppColors.textSecondaryLight,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: AppResponsive.s(context, 24)),
                            AppButton(
                              text: 'Retry',
                              onPressed: () {
                                ref.invalidate(teamsListProvider);
                              },
                              width: AppResponsive.s(context, 120),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToCreateTeam() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const CreateTeamPage(),
      ),
    );

    if (result == true && mounted) {
      // Team was created/updated, refresh the list
      ref.invalidate(teamsListProvider);
    }
  }

  Future<void> _navigateToEditTeam(ManagerTeamModel team) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => CreateTeamPage(team: team),
      ),
    );

    if (result == true && mounted) {
      // Team was updated, refresh the list
      ref.invalidate(teamsListProvider);
    }
  }
}
