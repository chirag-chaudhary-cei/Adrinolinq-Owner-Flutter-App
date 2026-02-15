import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors_new.dart';
import '../../../../core/theme/app_responsive.dart';
import '../../../../core/widgets/generic_form_dialog.dart';
import '../../../../core/widgets/app_text_field_with_label.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../core/widgets/event_card.dart';
import '../../data/models/teammate_model.dart';
import 'registration_summary_page.dart';

/// Model for team data
class TeamModel {
  final String name;
  final String captainContact;
  final List<TeammateModel> players;

  TeamModel({
    required this.name,
    required this.captainContact,
    required this.players,
  });
}

class SelectPlayersPage extends StatefulWidget {
  const SelectPlayersPage({
    super.key,
    required this.event,
    required this.teamName,
    required this.captainContact,
    this.initialPlayers = const [],
  });

  final EventModel event;
  final String teamName;
  final String captainContact;
  final List<TeammateModel> initialPlayers;

  @override
  State<SelectPlayersPage> createState() => _SelectPlayersPageState();
}

class _SelectPlayersPageState extends State<SelectPlayersPage> {
  late List<TeammateModel> _players;
  static const int maxTeamSize = 14;

  @override
  void initState() {
    super.initState();
    _players = [
      TeammateModel(
        id: 'captain',
        name: 'Marcus Johnson',
        email:
            widget.captainContact.contains('@') ? widget.captainContact : null,
        mobile:
            !widget.captainContact.contains('@') ? widget.captainContact : null,
        isRegistered: true,
      ),
      ...widget.initialPlayers,
    ];
  }

  int get _currentCount => _players.length;

  Future<void> _showAddTeammateDialog() async {
    final emailController = TextEditingController();
    final roleController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<TeammateModel>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => GenericFormDialog(
        title: 'Add your teammates',
        subtitle:
            "You've add a new Teammates! Invite colleagues to collaborate on your team.",
        showAvatars: true,
        formKey: formKey,
        fields: [
          AppTextFieldWithLabel(
            controller: emailController,
            label: 'Email/Mobile No.',
            hintText: 'Email/Mobile No.',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter email or mobile number';
              }
              return null;
            },
          ),
          SizedBox(height: AppResponsive.p(context, 16)),
          AppTextFieldWithLabel(
            controller: roleController,
            label: 'Role',
            hintText: 'Role',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a role';
              }
              return null;
            },
          ),
        ],
        onSubmit: () {
          if (formKey.currentState?.validate() ?? false) {
            final input = emailController.text.trim();
            final isEmail = input.contains('@');

            final newTeammate = TeammateModel(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              name: isEmail ? input.split('@')[0] : 'Player',
              email: isEmail ? input : null,
              mobile: isEmail ? null : input,
              isRegistered: false,
            );

            Navigator.pop(context, newTeammate);
          }
        },
      ),
    );

    if (result != null && _currentCount < maxTeamSize) {
      setState(() {
        _players.add(result);
      });
    } else if (_currentCount >= maxTeamSize) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Maximum team size of $maxTeamSize players reached',
            style: TextStyle(fontFamily: 'SFProRounded'),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _deletePlayer(int index) async {
    if (index == 0) return;

    final shouldDelete = await AppDialogs.showDeleteConfirmation(
      context,
      title: 'Are you want to Delete?',
    );

    if (shouldDelete == true) {
      setState(() {
        _players.removeAt(index);
      });
    }
  }

  void _handleNext() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegistrationSummaryPage(
          event: widget.event,
          selectedTeammates: _players.skip(1).toList(),
          teamId: 0,
          pricePerPlayer: 0.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(),
                const Divider(height: 1, color: Color(0xFFE0E0E0)),
              ],
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
                    _buildPlayersList(),
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

  Widget _buildHeader() {
    return Container(
      padding: AppResponsive.padding(context, horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: AppResponsive.s(context, 40),
              height: AppResponsive.s(context, 40),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: AppResponsive.borderRadius(context, 20),
              ),
              child: Icon(
                Icons.arrow_back,
                size: AppResponsive.icon(context, 20),
                color: AppColors.textPrimaryLight,
              ),
            ),
          ),
          SizedBox(width: AppResponsive.s(context, 16)),
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
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                Text(
                  '($_currentCount / $maxTeamSize Players)',
                  style: TextStyle(
                    fontFamily: 'SFProRounded',
                    fontSize: AppResponsive.font(context, 14),
                    fontWeight: FontWeight.w500,
                    color: AppColors.accentBlue,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _showAddTeammateDialog,
            child: Text(
              '+ Add New',
              style: TextStyle(
                fontFamily: 'SFProRounded',
                fontSize: AppResponsive.font(context, 14),
                fontWeight: FontWeight.w600,
                color: AppColors.accentBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayersList() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _players.length,
      itemBuilder: (context, index) {
        final player = _players[index];
        final isCaptain = index == 0;
        return _buildPlayerItem(player, index, isCaptain);
      },
    );
  }

  Widget _buildPlayerItem(TeammateModel player, int index, bool isCaptain) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: AppResponsive.s(context, 8),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: AppResponsive.s(context, 24),
                backgroundColor: AppColors.accentBlue.withOpacity(0.1),
                backgroundImage: player.avatarUrl != null
                    ? AssetImage(player.avatarUrl!)
                    : null,
                child: player.avatarUrl == null
                    ? Text(
                        player.name
                            .split(' ')
                            .map((e) => e.isNotEmpty ? e[0] : '')
                            .join('')
                            .toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'SFProRounded',
                          fontSize: AppResponsive.font(context, 16),
                          fontWeight: FontWeight.w600,
                          color: AppColors.accentBlue,
                        ),
                      )
                    : null,
              ),
              SizedBox(width: AppResponsive.s(context, 12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.name,
                      style: TextStyle(
                        fontFamily: 'SFProRounded',
                        fontSize: AppResponsive.font(context, 16),
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    if (isCaptain)
                      Text(
                        'Captain',
                        style: TextStyle(
                          fontFamily: 'SFProRounded',
                          fontSize: AppResponsive.font(context, 13),
                          fontWeight: FontWeight.w500,
                          color: AppColors.accentBlue,
                        ),
                      )
                    else
                      Text(
                        'Left Arm Fast baller',
                        style: TextStyle(
                          fontFamily: 'SFProRounded',
                          fontSize: AppResponsive.font(context, 13),
                          fontWeight: FontWeight.w500,
                          color: AppColors.accentBlue,
                        ),
                      ),
                  ],
                ),
              ),
              if (!isCaptain)
                GestureDetector(
                  onTap: () => _deletePlayer(index),
                  child: Container(
                    width: AppResponsive.s(context, 32),
                    height: AppResponsive.s(context, 32),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE5E5),
                      borderRadius: AppResponsive.borderRadius(context, 8),
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      size: AppResponsive.icon(context, 18),
                      color: const Color(0xFFFF4D4D),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const Divider(
          color: Color(0xFFE0E0E0),
          height: 1,
          thickness: 1,
        ),
      ],
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
        enabled: _players.isNotEmpty,
      ),
    );
  }
}

/// Entry point for the team creation flow
class TeamCreationFlow {
  static Future<void> start(BuildContext context, EventModel event) async {
    final teamNameController = TextEditingController();
    final captainContactController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final teamCreated = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => GenericFormDialog(
        title: 'Create Team',
        subtitle: "You've add a new Team! Add Teammates to your team.",
        showAvatars: true,
        formKey: formKey,
        fields: [
          AppTextFieldWithLabel(
            controller: teamNameController,
            label: 'Team Name',
            hintText: 'Team Name',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter team name';
              }
              return null;
            },
          ),
          SizedBox(height: AppResponsive.p(context, 16)),
          AppTextFieldWithLabel(
            controller: captainContactController,
            label: 'Captain Email/Mobile No.',
            hintText: 'Captain Email/Mobile No.',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter captain email or mobile';
              }
              return null;
            },
          ),
        ],
        onSubmit: () {
          if (formKey.currentState?.validate() ?? false) {
            Navigator.pop(context, true);
          }
        },
      ),
    );

    if (teamCreated != true) return;

    final teamName = teamNameController.text.trim();
    final captainContact = captainContactController.text.trim();

    final emailController = TextEditingController();
    final roleController = TextEditingController();
    final addFormKey = GlobalKey<FormState>();

    final firstTeammate = await showDialog<TeammateModel>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => GenericFormDialog(
        title: 'Add your teammates',
        subtitle:
            "You've add a new Teammates! Invite colleagues to collaborate on your team.",
        showAvatars: true,
        formKey: addFormKey,
        fields: [
          AppTextFieldWithLabel(
            controller: emailController,
            label: 'Email/Mobile No.',
            hintText: 'Email/Mobile No.',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter email or mobile number';
              }
              return null;
            },
          ),
          SizedBox(height: AppResponsive.p(context, 16)),
          AppTextFieldWithLabel(
            controller: roleController,
            label: 'Role',
            hintText: 'Role',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a role';
              }
              return null;
            },
          ),
        ],
        onSubmit: () {
          if (addFormKey.currentState?.validate() ?? false) {
            final input = emailController.text.trim();
            final isEmail = input.contains('@');

            final newTeammate = TeammateModel(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              name: isEmail ? input.split('@')[0] : 'Player',
              email: isEmail ? input : null,
              mobile: isEmail ? null : input,
              isRegistered: false,
            );

            Navigator.pop(context, newTeammate);
          }
        },
      ),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectPlayersPage(
          event: event,
          teamName: teamName,
          captainContact: captainContact,
          initialPlayers: firstTeammate != null ? [firstTeammate] : [],
        ),
      ),
    );
  }
}
