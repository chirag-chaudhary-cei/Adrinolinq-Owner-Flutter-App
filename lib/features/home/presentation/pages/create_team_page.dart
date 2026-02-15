import '../../../../core/widgets/global_app_bar.dart';
import '../../../../core/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_colors_new.dart';
import '../../../../core/theme/app_responsive.dart';
import '../../../../core/widgets/app_text_field_with_label.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/event_card.dart';
import '../../../../core/widgets/generic_form_dialog.dart';

import 'registration_summary_page.dart';
import '../../../../core/widgets/app_dropdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tournaments_providers.dart';
import '../../data/models/teammate_model.dart';
import '../../data/models/tournament_model.dart';

class CreateTeamPage extends ConsumerStatefulWidget {
  const CreateTeamPage({
    super.key,
    this.event,
    this.tournament,
    this.initialSelectedTeammates = const [],
    this.openDialogOnStart = false,
    this.teamId,
  }) : assert(event != null || tournament != null,
            'Either event or tournament must be provided',);

  final EventModel? event;
  final TournamentModel? tournament;
  final List<TeammateModel> initialSelectedTeammates;
  final bool openDialogOnStart;
  final int? teamId;

  @override
  ConsumerState<CreateTeamPage> createState() => _CreateTeamPageState();
}

class _CreateTeamPageState extends ConsumerState<CreateTeamPage> {
  late List<TeammateModel> _allTeammates;
  late Set<String> _selectedTeammateIds;
  late List<Map<String, dynamic>> _rawPlayerData;
  static const int maxTeamSize = 12;

  @override
  void initState() {
    super.initState();
    _allTeammates = [];
    _rawPlayerData = [];
    _selectedTeammateIds =
        widget.initialSelectedTeammates.map((t) => t.id).toSet();

    if (widget.teamId != null) {
      _fetchTeammates();
    }

    if (widget.openDialogOnStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAddTeammateDialog();
      });
    }
  }

  Future<void> _fetchTeammates() async {
    try {
      final teamPlayersFn =
          ref.read(tournamentTeamPlayersListProvider(widget.teamId!).future);
      final players = await teamPlayersFn;

      if (mounted) {
        setState(() {
          _rawPlayerData = List<Map<String, dynamic>>.from(players);

          _allTeammates = players.map((p) {
            final userId =
                (p['playerUserId'] ?? p['userId'] ?? p['id']) as int?;

            final playerName = (p['player'] ??
                    p['userFullName'] ??
                    p['playerName'] ??
                    p['name']) as String? ??
                'Teammate';

            final avatarUrl = (p['userProfileImage'] ??
                p['avatarUrl'] ??
                p['profileImage']) as String?;

            final roleName =
                (p['sportRole'] ?? p['role'] ?? p['roleName']) as String?;

            if (kDebugMode) {
              print(
                  '👤 [CreateTeamPage] Parsing player: ${p['player']} (ID: $userId, Role: $roleName)',);
              print('   Raw data keys: ${p.keys.toList()}');
            }

            return TeammateModel(
              id: userId.toString(),
              name: playerName,
              role: roleName,
              avatarUrl: avatarUrl,
              isRegistered: true,
            );
          }).toList();

          for (var t in _allTeammates) {
            if (_remainingSlots > 0) _selectedTeammateIds.add(t.id);
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [CreateTeamPage] Failed to fetch teammates: $e');
      }
    }
  }

  int get _remainingSlots {
    return maxTeamSize - (_selectedTeammateIds.length + 1);
  }

  Future<void> _showAddTeammateDialog() async {
    final emailController = TextEditingController();
    Map<String, dynamic>? selectedRole;

    final sportId = widget.tournament?.sportId ?? 4;

    final dataSource = ref.read(tournamentsRemoteDataSourceProvider);

    await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (dialogContext) => FutureBuilder<List<Map<String, dynamic>>>(
        future: dataSource.getSportRolesList(sportId),
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
                    const CircularProgressIndicator(),
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
              title: 'Add your teammates',
              subtitle:
                  "You've add a new Teammates! Invite colleagues to collaborate on your team.",
              submitLabel: 'Save',
              showAvatars: true,
              isLoading: isLoading,
              fields: [
                AppTextFieldWithLabel(
                  controller: emailController,
                  label: 'Email/Mobile No.',
                  hintText: 'Email/Mobile No.',
                ),
                if (roles.isNotEmpty) ...[
                  SizedBox(height: AppResponsive.s(context, 16)),
                  AppDropdownFormField<Map<String, dynamic>>(
                    label: 'Role',
                    hint: 'Select Role',
                    items: roles,
                    itemLabel: (role) => role['name'] as String? ?? '',
                    onChanged: (value) => selectedRole = value,
                    validator: (value) =>
                        value == null ? 'Please select a role' : null,
                  ),
                ],
              ],
              onSubmit: () async {
                final input = emailController.text.trim();
                if (input.isEmpty ||
                    (roles.isNotEmpty && selectedRole == null)) {
                  if (input.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please enter Email/Mobile No.'),),
                    );
                  } else if (roles.isNotEmpty && selectedRole == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select a role')),
                    );
                  }
                  return;
                }

                setDialogState(() => isLoading = true);

                try {
                  final dataSource =
                      ref.read(tournamentsRemoteDataSourceProvider);

                  final users = await dataSource.searchUserByQuery(input);

                  if (users.isEmpty) {
                    setDialogState(() => isLoading = false);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'User not found. Please check email/mobile.',),),
                      );
                    }
                    return;
                  }

                  final userData = users.first;
                  final playerUserId =
                      (userData['id'] ?? userData['userId']) as int?;
                  final sportRoleId = selectedRole?['id'] as int?;

                  if (playerUserId == null) {
                    setDialogState(() => isLoading = false);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Invalid user data: User ID missing'),),
                      );
                    }
                    return;
                  }

                  if (_allTeammates
                      .any((t) => t.id == playerUserId.toString())) {
                    setDialogState(() => isLoading = false);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Player is already in the team'),),
                      );
                    }
                    return;
                  }

                  if (widget.teamId != null) {
                    final playersToSave = <Map<String, dynamic>>[];

                    playersToSave.addAll(_rawPlayerData);

                    playersToSave.add({
                      'teamId': widget.teamId!,
                      'playerUserId': playerUserId,
                      if (sportRoleId != null) 'sportRoleId': sportRoleId,
                    });

                    if (kDebugMode) {
                      print(
                          '💾 [CreateTeamPage] Saving ${playersToSave.length} players in bulk',);
                    }

                    await dataSource.saveTournamentTeamPlayersBulk(
                      teamId: widget.teamId!,
                      players: playersToSave,
                    );

                    if (mounted) {
                      await _fetchTeammates();
                    }
                  } else {
                    if (kDebugMode) {
                      print(
                          '⚠️ [CreateTeamPage] Warning: teamId is null, cannot save player to API',);
                    }
                  }

                  if (context.mounted) Navigator.pop(dialogContext);
                } catch (e) {
                  setDialogState(() => isLoading = false);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to add teammate: $e')),
                    );
                  }
                }
              },
            );
          },);
        },
      ),
    );
  }

  void _showDeleteConfirmDialog(TeammateModel teammate) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(AppResponsive.radius(context, 32)),
        ),
        insetPadding: EdgeInsets.all(AppResponsive.p(context, 20)),
        child: Padding(
          padding: EdgeInsets.all(AppResponsive.p(context, 24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/gifs/delete_alert.gif',
                width: AppResponsive.s(context, 80),
                height: AppResponsive.s(context, 80),
              ),
              SizedBox(height: AppResponsive.s(context, 16)),
              Text(
                'Are you want to Delete?',
                style: TextStyle(
                  fontFamily: 'SFProRounded',
                  fontSize: AppResponsive.font(context, 18),
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: AppResponsive.s(context, 24)),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Cancel',
                      onPressed: () => Navigator.pop(context),
                      isOutlined: true,
                      borderColor: Colors.grey.shade300,
                      textColor: Colors.black,
                    ),
                  ),
                  SizedBox(width: AppResponsive.s(context, 12)),
                  Expanded(
                    child: AppButton(
                      text: 'Yes',
                      onPressed: () async {
                        Navigator.pop(context);

                        try {
                          final playerId = int.tryParse(teammate.id);
                          if (playerId != null) {
                            final dataSource =
                                ref.read(tournamentsRemoteDataSourceProvider);
                            await dataSource
                                .deleteTournamentTeamPlayer(playerId);
                          }

                          setState(() {
                            _allTeammates.remove(teammate);
                            _selectedTeammateIds.remove(teammate.id);
                          });
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Failed to remove player: $e'),),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleNext() {
    final selectedTeammates = _allTeammates
        .where((t) => _selectedTeammateIds.contains(t.id))
        .toList();

    if (widget.event != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RegistrationSummaryPage(
            event: widget.event!,
            selectedTeammates: selectedTeammates,
            teamId: widget.teamId ?? 0,
            pricePerPlayer: double.tryParse(
                    widget.event!.price.replaceAll(RegExp(r'[^0-9.]'), ''),) ??
                0.0,
          ),
        ),
      );
    } else if (widget.tournament != null) {
      final dataSource = ref.read(tournamentsRemoteDataSourceProvider);
      final imageUrl = widget.tournament!.imageFile != null &&
              widget.tournament!.imageFile!.isNotEmpty
          ? dataSource.getTournamentImageUrl(widget.tournament!.imageFile)
          : '';

      final mockEvent = EventModel(
        id: widget.tournament!.id.toString(),
        title: widget.tournament!.name,
        category: widget.tournament!.sport,
        date: widget.tournament!.tournamentDate,
        time: '',
        location: '${widget.tournament!.city}, ${widget.tournament!.state}',
        imageUrl: imageUrl,
        price: 'INR ${widget.tournament!.feesAmount.toStringAsFixed(0)}',
        tags: [],
        registeredCount: 0,
        maxParticipants: widget.tournament!.maximumRegistrationsCount,
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RegistrationSummaryPage(
            event: mockEvent,
            selectedTeammates: selectedTeammates,
            teamId: widget.teamId ?? 0,
            pricePerPlayer: widget.tournament?.feesAmount ?? 0.0,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: GlobalAppBar(
              title: 'Select Players',
              subtitle: '(12 / 14 Players)',
              showBackButton: true,
              showAddButton: true,
              addButtonText: 'Add New',
              onAddPressed: _showAddTeammateDialog,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: AppResponsive.padding(context, horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: AppResponsive.s(context, 20)),
                    _buildTeammatesList(),
                    SizedBox(height: AppResponsive.s(context, 20)),
                  ],
                ),
              ),
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildTeammatesList() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _allTeammates.length,
      itemBuilder: (context, index) {
        final teammate = _allTeammates[index];
        final isSelected = _selectedTeammateIds.contains(teammate.id);
        return _buildTeammateItem(teammate, isSelected);
      },
    );
  }

  Widget _buildTeammateItem(TeammateModel teammate, bool isSelected) {
    final index = _allTeammates.indexOf(teammate);
    final isCaptain = index == 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppResponsive.borderRadius(context, 16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: AppResponsive.s(context, 50),
                height: AppResponsive.s(context, 50),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceLightVariant,
                  image: DecorationImage(
                    image: teammate.avatarUrl != null &&
                            teammate.avatarUrl!.isNotEmpty
                        ? NetworkImage(teammate.avatarUrl!)
                        : const AssetImage('assets/images/demo1.jpg')
                            as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
                child:
                    (teammate.avatarUrl == null || teammate.avatarUrl!.isEmpty)
                        ? Center(
                            child: Text(
                              teammate.name.isNotEmpty
                                  ? teammate.name[0].toUpperCase()
                                  : 'T',
                              style: TextStyle(
                                fontFamily: 'SFProRounded',
                                fontSize: AppResponsive.font(context, 18),
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimaryLight,
                              ),
                            ),
                          )
                        : null,
              ),
              SizedBox(width: AppResponsive.s(context, 12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          teammate.name,
                          style: TextStyle(
                            fontFamily: 'SFProRounded',
                            fontSize: AppResponsive.font(context, 20),
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        if (teammate.role != null &&
                            teammate.role!.isNotEmpty &&
                            !isCaptain) ...[
                          SizedBox(width: AppResponsive.s(context, 8)),
                          Container(
                            padding: AppResponsive.padding(context,
                                horizontal: 8, vertical: 2,),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0E0E0),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              teammate.role!,
                              style: TextStyle(
                                fontFamily: 'SFProRounded',
                                fontSize: AppResponsive.font(context, 12),
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF5C5C5C),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: AppResponsive.s(context, 1)),
                    Text(
                      isCaptain
                          ? (teammate.role != null && teammate.role!.isNotEmpty
                              ? 'Captain • ${teammate.role}'
                              : 'Captain')
                          : (teammate.role ?? 'Team Member'),
                      style: TextStyle(
                        fontFamily: 'SFProRounded',
                        fontSize: AppResponsive.font(context, 16),
                        fontWeight: FontWeight.w500,
                        color: AppColors.accentBlue,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isCaptain)
                GestureDetector(
                  onTap: () {
                    _showDeleteConfirmDialog(teammate);
                  },
                  child: SizedBox(
                    width: AppResponsive.s(context, 36),
                    height: AppResponsive.s(context, 36),
                    child: SvgPicture.asset(
                      'assets/icons/delete.svg',
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: AppResponsive.padding(context, vertical: 15),
            child: const Divider(height: 1, color: AppColors.dividerLight),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: EdgeInsets.only(
        left: AppResponsive.p(context, 20),
        right: AppResponsive.p(context, 20),
        top: AppResponsive.p(context, 12),
        bottom: MediaQuery.of(context).padding.bottom +
            AppResponsive.p(context, 12),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: AppButton(
        text: 'Next',
        onPressed: _handleNext,
        trailingIcon: Icons.chevron_right,
        width: double.infinity,
        enabled: _selectedTeammateIds.isNotEmpty,
      ),
    );
  }
}
