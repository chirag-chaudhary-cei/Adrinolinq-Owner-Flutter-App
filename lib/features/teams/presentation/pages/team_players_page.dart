import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors_new.dart';
import '../../../../core/theme/app_responsive.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/app_text_field_with_label.dart';
import '../../../../core/widgets/generic_form_dialog.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../data/models/manager_team_model.dart';
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
  // TODO: Replace with actual player data from API
  final List<Map<String, dynamic>> _players = [
    {
      'id': 1,
      'name': 'Marcus Johnson',
      'role': 'Expert',
      'imageUrl': '',
    },
    {
      'id': 2,
      'name': 'Marcus Johnson',
      'role': 'Expert',
      'imageUrl': '',
    },
    {
      'id': 3,
      'name': 'Marcus Johnson',
      'role': 'Expert',
      'imageUrl': '',
    },
    {
      'id': 4,
      'name': 'Marcus Johnson',
      'role': 'Expert',
      'imageUrl': '',
    },
  ];

  Future<void> _showAddPlayerDialog() async {
    final mobileController = TextEditingController();
    Map<String, dynamic>? selectedRole;

    // TODO: Get sport roles from API based on team's sport
    final roles = [
      {'id': 1, 'name': 'Expert'},
      {'id': 2, 'name': 'Beginner'},
      {'id': 3, 'name': 'Intermediate'},
    ];

    await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (dialogContext) {
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
                // TODO: Implement API call to add player
                await Future.delayed(const Duration(seconds: 1));

                // Add player to local list for now
                setState(() {
                  _players.add({
                    'id': DateTime.now().millisecondsSinceEpoch,
                    'name': 'New Player',
                    'role': selectedRole?['name'] ?? 'Unknown',
                    'imageUrl': '',
                  });
                });

                if (context.mounted) {
                  Navigator.pop(dialogContext);
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
                    SnackBar(content: Text('Failed to add player: $e')),
                  );
                }
              }
            },
          );
        });
      },
    );
  }

  void _showPlayerOptions(Map<String, dynamic> player) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppResponsive.radius(context, 20)),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: AppResponsive.padding(context, all: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit, color: AppColors.accentBlue),
                  title: const Text('Edit Player'),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Implement edit player
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remove Player'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _players.remove(player);
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final playerCount = _players.length;
    final maxPlayers = 15; // TODO: Get from team data

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: AppResponsive.padding(context, all: 16),
              child: Row(
                children: [
                  const AppBackButton(isTransparent: false),
                  SizedBox(width: AppResponsive.s(context, 12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Players',
                          style: TextStyle(
                            fontFamily: 'SFProRounded',
                            fontSize: AppResponsive.font(context, 20),
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
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
                        ),
                      ],
                    ),
                  ),
                  // Add Button
                  GestureDetector(
                    onTap: _showAddPlayerDialog,
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
                ],
              ),
            ),

            // Divider
            Divider(
              color: Colors.grey.shade200,
              thickness: 1,
              height: 1,
            ),

            // Players List
            Expanded(
              child: _players.isEmpty
                  ? Center(
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
                    )
                  : ListView.separated(
                      itemCount: _players.length,
                      separatorBuilder: (context, index) => Divider(
                        color: Colors.grey.shade200,
                        thickness: 1,
                        height: 1,
                        indent: AppResponsive.s(context, 16),
                        endIndent: AppResponsive.s(context, 16),
                      ),
                      itemBuilder: (context, index) {
                        final player = _players[index];
                        return PlayerCard(
                          player: player,
                          onMenuTap: () => _showPlayerOptions(player),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
