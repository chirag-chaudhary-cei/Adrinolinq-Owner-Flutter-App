import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors_new.dart';
import '../../../../core/theme/app_responsive.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/app_text_field_with_label.dart';
import '../../../../core/widgets/generic_form_dialog.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../data/models/manager_team_model.dart';
import '../../data/models/save_team_player_request.dart';
import '../../data/models/team_player_model.dart';
import '../providers/teams_providers.dart';
import '../widgets/player_card.dart';

/// Team Players Page - View and manage players in a team
class TeamPlayersPage extends ConsumerStatefulWidget {
  const TeamPlayersPage({
    super.key,
    required this.team,
  });

  final ManagerTeamModel team;

  @override
  ConsumerState<TeamPlayersPage> createState() => _TeamPlayersPageState();
}

class _TeamPlayersPageState extends ConsumerState<TeamPlayersPage> {
  Future<void> _showAddPlayerDialog() async {
    final mobileController = TextEditingController();
    Map<String, dynamic>? selectedRole;

    final sportId = widget.team.sportId;
    final rolesAsync = ref.read(sportRolesProvider(sportId).future);

    await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (dialogContext) => FutureBuilder<List<Map<String, dynamic>>>(
        future: rolesAsync,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppResponsive.radius(context, 32)),
              ),
              child: Padding(
                padding: EdgeInsets.all(AppResponsive.p(context, 40)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: AppColors.accentBlue,
                    ),
                    SizedBox(height: AppResponsive.s(context, 16)),
                    Text(
                      'Loading roles...',
                      style: TextStyle(
                        fontFamily: 'SFProRounded',
                        fontSize: AppResponsive.font(context, 14),
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (snapshot.hasError) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('Failed to load roles: ${snapshot.error}'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('OK'),
                ),
              ],
            );
          }

          final roles = snapshot.data ?? [];

          bool isLoading = false;

          return StatefulBuilder(builder: (context, setDialogState) {
            return GenericFormDialog(
              title: 'Add Player',
              subtitle: 'Add a new player to ${widget.team.name}',
              submitLabel: 'Add',
              showAvatars: true,
              isLoading: isLoading,
              fields: [
                AppTextFieldWithLabel(
                  controller: mobileController,
                  label: 'Mobile No.',
                  hintText: 'Enter mobile number',
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: AppResponsive.s(context, 16)),
                if (roles.isNotEmpty)
                  AppDropdownFormField<Map<String, dynamic>>(
                    label: 'Sport Role',
                    hint: 'Select Role',
                    items: roles,
                    itemLabel: (role) => role['name'] as String? ?? '',
                    onChanged: (value) => selectedRole = value,
                    validator: (value) =>
                        value == null ? 'Please select a role' : null,
                  ),
              ],
              onSubmit: () async {
                final mobile = mobileController.text.trim();
                if (mobile.isEmpty || selectedRole == null) {
                  if (mobile.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter mobile number'),
                      ),
                    );
                  } else if (selectedRole == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select a role')),
                    );
                  }
                  return;
                }

                setDialogState(() => isLoading = true);

                try {
                  final request = SaveTeamPlayerRequest(
                    teamId: widget.team.id,
                    sportRoleId: selectedRole?['id'] as int,
                    mobile: mobile,
                  );

                  final repository = ref.read(teamsRepositoryProvider);
                  await repository.saveTeamPlayers(request);

                  if (context.mounted) {
                    Navigator.pop(dialogContext);
                    // Refresh the players list
                    ref.invalidate(teamPlayersProvider(widget.team.id));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Player added successfully'),
                        backgroundColor: AppColors.accentBlue,
                      ),
                    );
                  }
                } catch (e) {
                  setDialogState(() => isLoading = false);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          e.toString().replaceFirst('Exception: ', ''),
                        ),
                      ),
                    );
                  }
                }
              },
            );
          });
        },
      ),
    );
  }

  Future<void> _deletePlayer(dynamic player) async {
    // Get player ID
    final int? playerId;
    if (player is TeamPlayerModel) {
      playerId = player.id;
    } else if (player is Map<String, dynamic>) {
      playerId = player['id'] as int?;
    } else {
      playerId = null;
    }

    if (playerId == null) {
      await AppDialogs.showError(
        context,
        message: 'Invalid player data',
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await AppDialogs.showConfirmation(
      context,
      title: 'Remove Player',
      message: 'Are you sure you want to remove ?',
      confirmText: 'Remove',
      cancelText: 'Cancel',
      customGifPath: 'assets/gifs/deleteAlert.gif',
    );

    if (confirmed != true) return;

    // Show loading dialog
    if (mounted) {
      AppDialogs.showLoading(context, message: 'Removing player...');
    }

    try {
      final repository = ref.read(teamsRepositoryProvider);
      await repository.deleteTeamPlayers(playerId);

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        await AppDialogs.showSuccess(
          context,
          message: 'Player removed successfully',
        );
        // Refresh the players list
        ref.invalidate(teamPlayersProvider(widget.team.id));
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        await AppDialogs.showError(
          context,
          message: e.toString().replaceFirst('Exception: ', ''),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final playersAsync = ref.watch(teamPlayersProvider(widget.team.id));

    return playersAsync.when(
      data: (players) => _buildContent(context, players),
      loading: () => Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, 0, widget.team.maxPlayers ?? 15),
              Divider(
                color: Colors.grey.shade200,
                thickness: 1,
                height: 1,
              ),
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.accentBlue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, 0, widget.team.maxPlayers ?? 15),
              Divider(
                color: Colors.grey.shade200,
                thickness: 1,
                height: 1,
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: AppResponsive.s(context, 64),
                        color: Colors.red.shade300,
                      ),
                      SizedBox(height: AppResponsive.s(context, 16)),
                      Text(
                        'Failed to load players',
                        style: TextStyle(
                          fontSize: AppResponsive.font(context, 18),
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      SizedBox(height: AppResponsive.s(context, 8)),
                      Padding(
                        padding: AppResponsive.padding(context, horizontal: 40),
                        child: Text(
                          error.toString().replaceFirst('Exception: ', ''),
                          style: TextStyle(
                            fontSize: AppResponsive.font(context, 14),
                            color: AppColors.textSecondaryLight,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<dynamic> players) {
    final playerCount = players.length;
    final maxPlayers = widget.team.maxPlayers ?? 15;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, playerCount, maxPlayers),

            // Divider
            Divider(
              color: Colors.grey.shade200,
              thickness: 1,
              height: 1,
            ),

            // Players List
            Expanded(
              child: RefreshIndicator(
                color: AppColors.accentBlue,
                onRefresh: () async {
                  // Invalidate the provider to force a fresh fetch
                  ref.invalidate(teamPlayersProvider(widget.team.id));
                  // Wait for the provider to complete
                  await ref.read(teamPlayersProvider(widget.team.id).future);
                },
                child: players.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: AppResponsive.s(context, 100)),
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: AppResponsive.s(context, 64),
                                  color: AppColors.textMutedLight,
                                ),
                                SizedBox(height: AppResponsive.s(context, 16)),
                                Text(
                                  'No players yet',
                                  style: TextStyle(
                                    fontSize: AppResponsive.font(context, 18),
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimaryLight,
                                  ),
                                ),
                                SizedBox(height: AppResponsive.s(context, 8)),
                                Text(
                                  'Add your first player',
                                  style: TextStyle(
                                    fontSize: AppResponsive.font(context, 14),
                                    color: AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: players.length,
                        separatorBuilder: (context, index) => Divider(
                          color: Colors.grey.shade200,
                          thickness: 1,
                          height: 1,
                          indent: AppResponsive.s(context, 16),
                          endIndent: AppResponsive.s(context, 16),
                        ),
                        itemBuilder: (context, index) {
                          final player = players[index];
                          return PlayerCard(
                            player: player,
                            onDeleteTap: () => _deletePlayer(player),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int playerCount, int maxPlayers) {
    return Padding(
      padding: AppResponsive.padding(context, all: 16),
      child: Row(
        children: [
          const AppBackButton(isTransparent: false),
          SizedBox(width: AppResponsive.s(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Players',
                  style: TextStyle(
                    fontFamily: 'SFProRounded',
                    fontSize: AppResponsive.font(context, 20),
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppResponsive.s(context, 2)),
                Text(
                  '($playerCount/$maxPlayers Players)',
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
          SizedBox(width: AppResponsive.s(context, 12)),
          // Add Button
          GestureDetector(
            onTap: _showAddPlayerDialog,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppResponsive.s(context, 8),
                vertical: AppResponsive.s(context, 4),
              ),
              child: Text(
                '+ Add',
                style: TextStyle(
                  fontFamily: 'SFProRounded',
                  fontSize: AppResponsive.font(context, 16),
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentBlue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
