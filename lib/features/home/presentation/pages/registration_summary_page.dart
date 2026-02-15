import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors_new.dart';
import '../../../../core/theme/app_responsive.dart';
import '../../../../core/theme/app_animations.dart';
import '../../../../core/widgets/generic_form_dialog.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/app_text_field_with_label.dart';
import '../../../../core/widgets/detail_widgets.dart';
import '../../../../core/widgets/event_card.dart';
import '../../../payment/presentation/pages/payment_status_page.dart';
import '../../data/models/teammate_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tournaments_providers.dart';
import '../../../my_tournament/presentation/providers/my_tournament_providers.dart';
import '../../../my_tournament/data/models/tournament_registration_model.dart';

class RegistrationSummaryPage extends ConsumerStatefulWidget {
  const RegistrationSummaryPage({
    super.key,
    required this.event,
    this.selectedTeammates = const [],
    required this.teamId,
    required this.pricePerPlayer,
    this.isInviteOnly = false,
  });

  final EventModel event;
  final List<TeammateModel> selectedTeammates;
  final int teamId;
  final double pricePerPlayer;
  final bool isInviteOnly;

  @override
  ConsumerState<RegistrationSummaryPage> createState() =>
      _RegistrationSummaryPageState();
}

class _RegistrationSummaryPageState
    extends ConsumerState<RegistrationSummaryPage> {
  late List<TeammateModel> _selectedTeammates;
  bool _agreeToTerms = false;
  bool _showPriceBreakup = false;
  static const int maxTeamSize = 12;
  bool sts = true;

  @override
  void initState() {
    super.initState();
    _selectedTeammates = List.from(widget.selectedTeammates);
  }

  double get _totalPrice {
    final playerCount = _selectedTeammates.length + 1;
    return playerCount * widget.pricePerPlayer;
  }

  double get _taxesAndFees {
    return _totalPrice * 0.12;
  }

  double get _totalAmount {
    return _totalPrice + _taxesAndFees;
  }

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

    if (result != null && _selectedTeammates.length < maxTeamSize - 1) {
      setState(() {
        _selectedTeammates.add(result);
      });
    }
  }

  Future<void> _handleRegister() async {
    if (!_agreeToTerms) {
      AppDialogs.showError(
        context,
        message: 'Please agree to the terms and conditions to proceed',
      );
      return;
    }

    if (!widget.isInviteOnly && _selectedTeammates.isEmpty) {
      AppDialogs.showError(
        context,
        message: 'Please create a team before registering',
      );
      return;
    }

    AppLoading.showDialog(context, message: 'Processing registration...');

    try {
      final result = await ref.read(saveTournamentRegistrationProvider({
        'teamId': widget.teamId,
        'tournamentId': int.parse(widget.event.id),
      }).future,);

      if (!mounted) return;

      if (result != null) {
        TournamentRegistrationModel.fromJson(result);

        ref.invalidate(myTournamentRegistrationsProvider);
      }

      AppLoading.dismissDialog(context);

      sts = !sts;
      Navigator.pushNamed(
        context,
        AppRouter.paymentStatus,
        arguments: {
          'status': sts ? PaymentStatus.success : PaymentStatus.failed,
          'event': widget.event,
          'tournamentId': int.parse(widget.event.id),
        },
      );
    } catch (e) {
      if (!mounted) return;
      AppLoading.dismissDialog(context);

      AppDialogs.showError(
        context,
        message:
            'Registration failed: ${e.toString().replaceAll('Exception: ', '')}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: Column(
        children: [
          const SafeArea(
            bottom: false,
            child: AppHeader(
              title: 'Registration Summary',
              iconColor: Color(0XFF000000),
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
                    _buildEventCard(),
                    SizedBox(height: AppResponsive.s(context, 20)),
                    if (!widget.isInviteOnly) ...[
                      _buildTeammatesSection(),
                      SizedBox(height: AppResponsive.s(context, 20)),
                    ],
                    _buildPriceSection(),
                    SizedBox(height: AppResponsive.s(context, 20)),
                    _buildAgreementCheckbox(),
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

  Widget _buildEventCard() {
    return Container(
      padding: AppResponsive.padding(context, all: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppResponsive.borderRadius(context, 20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: AppResponsive.s(context, 20),
            offset: Offset(0, AppResponsive.s(context, 6)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: AppResponsive.s(context, 50),
                height: AppResponsive.s(context, 50),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLightVariant,
                  borderRadius: AppResponsive.borderRadius(context, 12),
                ),
                child: ClipRRect(
                  borderRadius: AppResponsive.borderRadius(context, 12),
                  child: widget.event.imageUrl.startsWith('http')
                      ? Image.network(
                          widget.event.imageUrl,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          widget.event.imageUrl,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              SizedBox(width: AppResponsive.s(context, 12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.event.title,
                      style: TextStyle(
                        fontFamily: 'SFProRounded',
                        fontSize: AppResponsive.font(context, 16),
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryLight,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AppResponsive.s(context, 4)),
                    Text(
                      widget.event.category,
                      style: TextStyle(
                        fontFamily: 'SFProRounded',
                        fontSize: AppResponsive.font(context, 13),
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppResponsive.s(context, 16)),
          _buildDashedDivider(),
          SizedBox(height: AppResponsive.s(context, 16)),
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: AppResponsive.icon(context, 16),
                color: AppColors.accentBlue,
              ),
              SizedBox(width: AppResponsive.s(context, 8)),
              Text(
                '${widget.event.date} • ${widget.event.time}',
                style: TextStyle(
                  fontFamily: 'SFProRounded',
                  fontSize: AppResponsive.font(context, 13),
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          SizedBox(height: AppResponsive.s(context, 8)),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: AppResponsive.icon(context, 16),
                color: AppColors.accentBlue,
              ),
              SizedBox(width: AppResponsive.s(context, 8)),
              Text(
                widget.event.location,
                style: TextStyle(
                  fontFamily: 'SFProRounded',
                  fontSize: AppResponsive.font(context, 13),
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          SizedBox(height: AppResponsive.s(context, 16)),
          AppButton(
            text: 'View Rules',
            onPressed: () {
              // Show rules
            },
            backgroundColor: AppColors.accentBlue,
            textColor: Colors.white,
            fontSize: AppResponsive.font(context, 16),
            fontWeight: FontWeight.w600,
            height: AppResponsive.s(context, 48),
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  Widget _buildTeammatesSection() {
    return Container(
      padding: AppResponsive.padding(context, all: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppResponsive.borderRadius(context, 20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: AppResponsive.s(context, 20),
            offset: Offset(0, AppResponsive.s(context, 6)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Your Teammates',
                style: TextStyle(
                  fontFamily: 'SFProRounded',
                  fontSize: AppResponsive.font(context, 18),
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              SizedBox(width: AppResponsive.s(context, 4)),
              Text(
                '(${_selectedTeammates.length + 1} Player)',
                style: TextStyle(
                  fontFamily: 'SFProRounded',
                  fontSize: AppResponsive.font(context, 13),
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
          SizedBox(height: AppResponsive.s(context, 5)),
          _buildDashedDivider(),
          SizedBox(height: AppResponsive.s(context, 16)),
          if (_selectedTeammates.isEmpty)
            _buildCreateTeamButton()
          else
            _buildTeammatesListWithButton(),
        ],
      ),
    );
  }

  Widget _buildDashedDivider() {
    return const DashedDivider();
  }

  Widget _buildCreateTeamButton() {
    return AppButton(
      text: 'Add Teammates',
      onPressed: _showAddTeammateDialog,
      width: double.infinity,
      backgroundColor: AppColors.accentBlue,
      textColor: Colors.white,
      fontSize: AppResponsive.font(context, 16),
      fontWeight: FontWeight.w600,
      height: AppResponsive.s(context, 48),
    );
  }

  Widget _buildTeammatesListWithButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _selectedTeammates.length,
          itemBuilder: (context, index) {
            final teammate = _selectedTeammates[index];
            return _buildTeammateItem(teammate);
          },
        ),
        SizedBox(height: AppResponsive.s(context, 8)),
        Center(
          child: GestureDetector(
            onTap: _showAddTeammateDialog,
            child: Text(
              'Add & Edit Teammates',
              style: TextStyle(
                fontFamily: 'SFProRounded',
                fontSize: AppResponsive.font(context, 14),
                fontWeight: FontWeight.w600,
                color: AppColors.accentBlue,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTeammateItem(TeammateModel teammate) {
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
                        ? NetworkImage(teammate.avatarUrl!) as ImageProvider
                        : const AssetImage('assets/images/demo1.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: teammate.avatarUrl == null
                    ? Center(
                        child: Text(
                          teammate.name[0].toUpperCase(),
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
                        SizedBox(width: AppResponsive.s(context, 8)),
                        Container(
                          padding: AppResponsive.padding(context,
                              horizontal: 8, vertical: 2,),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E0E0),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Expert',
                            style: TextStyle(
                              fontFamily: 'SFProRounded',
                              fontSize: AppResponsive.font(context, 12),
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF5C5C5C),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppResponsive.s(context, 1)),
                    Text(
                      'Left Arm Fast baller',
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

  Widget _buildPriceSection() {
    return Container(
      padding: AppResponsive.padding(context, all: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppResponsive.borderRadius(context, 20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: AppResponsive.s(context, 20),
            offset: Offset(0, AppResponsive.s(context, 6)),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Price',
                style: TextStyle(
                  fontFamily: 'SFProRounded',
                  fontSize: AppResponsive.font(context, 18),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showPriceBreakup = !_showPriceBreakup;
                  });
                },
                child: Row(
                  children: [
                    Text(
                      'View Price Breakup',
                      style: TextStyle(
                        fontFamily: 'SFProRounded',
                        fontSize: AppResponsive.font(context, 13),
                        fontWeight: FontWeight.w500,
                        color: AppColors.accentBlue,
                      ),
                    ),
                    SizedBox(width: AppResponsive.s(context, 4)),
                    Icon(
                      _showPriceBreakup
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: AppResponsive.icon(context, 18),
                      color: AppColors.accentBlue,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppResponsive.s(context, 16)),
          _buildDashedDivider(),
          if (_showPriceBreakup) ...[
            SizedBox(height: AppResponsive.s(context, 16)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Price + Taxes & Service Fees',
                  style: TextStyle(
                    fontFamily: 'SFProRounded',
                    fontSize: AppResponsive.font(context, 14),
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                Text(
                  '\$${_totalPrice.toStringAsFixed(0)} + \$${_taxesAndFees.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontFamily: 'SFProRounded',
                    fontSize: AppResponsive.font(context, 14),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppResponsive.s(context, 16)),
            _buildDashedDivider(),
          ],
          SizedBox(height: AppResponsive.s(context, 16)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount to be paid',
                style: TextStyle(
                  fontFamily: 'SFProRounded',
                  fontSize: AppResponsive.font(context, 15),
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              Text(
                '\$${_totalAmount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontFamily: 'SFProRounded',
                  fontSize: AppResponsive.font(context, 20),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgreementCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _agreeToTerms = !_agreeToTerms),
          child: AnimatedContainer(
            duration: AppDurations.quick,
            width: AppResponsive.s(context, 20),
            height: AppResponsive.s(context, 20),
            decoration: BoxDecoration(
              color: _agreeToTerms ? AppColors.accentBlue : Colors.transparent,
              border: Border.all(
                color: _agreeToTerms
                    ? AppColors.accentBlue
                    : const Color(0xFFBDBDBD),
                width: 1.5,
              ),
              borderRadius: AppResponsive.borderRadius(context, 6),
            ),
            child: _agreeToTerms
                ? Icon(
                    Icons.check,
                    color: Colors.white,
                    size: AppResponsive.icon(context, 16),
                  )
                : null,
          ),
        ),
        SizedBox(width: AppResponsive.s(context, 12)),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontFamily: 'SFProRounded',
                fontSize: AppResponsive.font(context, 13),
                height: 1.5,
                color: AppColors.textSecondaryLight,
              ),
              children: [
                const TextSpan(text: 'I agree to the '),
                const TextSpan(
                  text: 'terms',
                  style: TextStyle(
                    color: AppColors.accentBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(text: ' and '),
                const TextSpan(
                  text: 'conditions',
                  style: TextStyle(
                    color: AppColors.accentBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(text: ', '),
                const TextSpan(
                  text: 'waiver of liability',
                  style: TextStyle(
                    color: AppColors.accentBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(text: ' and '),
                const TextSpan(
                  text: 'understand the rules of the tournament',
                  style: TextStyle(
                    color: AppColors.accentBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
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
        text: 'Register Now • \$${widget.pricePerPlayer.toStringAsFixed(0)}',
        onPressed: _handleRegister,
        trailingIcon: Icons.chevron_right,
        width: double.infinity,
      ),
    );
  }
}
