import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors_new.dart';
import '../../../../core/theme/app_responsive.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/detail_widgets.dart';
import '../../../../core/widgets/event_card.dart';
import '../../../../core/widgets/match_card.dart';
import '../../../../core/widgets/app_tab_bar.dart';
import '../../../../core/widgets/global_app_bar.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/providers/app_providers.dart';
import '../../data/models/tournament_registration_model.dart';
import '../providers/my_tournament_providers.dart';
import '../../../home/data/models/tournament_model.dart';
import '../../../home/presentation/providers/tournaments_providers.dart';
import '../../../auth/presentation/providers/onboarding_providers.dart';

DateTime? _parseApiDate(String dateStr) {
  if (dateStr.isEmpty) return null;
  try {
    final normalized = dateStr.replaceAll('/', '-');
    return DateFormat('dd-MM-yyyy HH:mm:ss').parse(normalized);
  } catch (_) {
    try {
      return DateTime.tryParse(dateStr);
    } catch (_) {
      return null;
    }
  }
}

String _formatDate(String dateStr) {
  final date = _parseApiDate(dateStr);
  if (date == null) return dateStr;
  return DateFormat('dd MMM yyyy').format(date);
}

String _formatTime(String dateStr) {
  final date = _parseApiDate(dateStr);
  if (date == null) return '';
  return DateFormat('hh:mm a').format(date);
}

String _constructPlayerName(Map<String, dynamic> player) {
  final firstName = player['firstName']?.toString() ?? '';
  final lastName = player['lastName']?.toString() ?? '';
  final nameTitle = player['nameTitle']?.toString() ?? '';
  final fullName = [firstName, lastName].where((s) => s.isNotEmpty).join(' ');
  if (fullName.isEmpty) return 'Unknown Player';
  return nameTitle.isNotEmpty ? '$nameTitle $fullName' : fullName;
}

class MatchTournamentModel {
  final EventModel event;
  final String registeredId;
  final String registeredDate;
  final String registeredTime;
  final double priceWithTax;
  final double serviceFee;
  final double totalAmount;
  final String registrationStartDate;
  final String registrationEndDate;
  final String startDate;
  final String startTime;
  final String endTime;
  final String locationAddress;
  final String aboutEvent;
  final String scoringStructure;
  final String equipmentRequired;
  final List<String> rules;
  final List<dynamic> tournamentSponsorsList;

  const MatchTournamentModel({
    required this.event,
    required this.registeredId,
    required this.registeredDate,
    required this.registeredTime,
    required this.priceWithTax,
    required this.serviceFee,
    required this.totalAmount,
    required this.registrationStartDate,
    required this.registrationEndDate,
    required this.startDate,
    required this.startTime,
    required this.endTime,
    required this.locationAddress,
    required this.aboutEvent,
    required this.scoringStructure,
    required this.equipmentRequired,
    required this.rules,
    required this.tournamentSponsorsList,
  });

  factory MatchTournamentModel.fromTournament({
    required TournamentModel tournament,
    required TournamentRegistrationModel registration,
    required EventModel event,
  }) {
    List<String> parsedRules = [];
    if (tournament.rules != null && tournament.rules!.isNotEmpty) {
      final cleanRules = tournament.rules!
          .replaceAll(RegExp(r'<[^>]*>'), '')
          .replaceAll('&nbsp;', ' ')
          .trim();
      if (cleanRules.isNotEmpty) {
        parsedRules = cleanRules
            .split(RegExp(r'[\n\r]+|(?:\d+\.\s*)'))
            .where((s) => s.trim().isNotEmpty)
            .toList();
      }
    }
    if (parsedRules.isEmpty)
      parsedRules = ['Tournament rules will be provided by the organizer'];

    final locationParts = [
      if (tournament.region.isNotEmpty) tournament.region,
      if (tournament.city.isNotEmpty) tournament.city,
      if (tournament.district.isNotEmpty) tournament.district,
      if (tournament.state.isNotEmpty) tournament.state,
    ];
    final locationAddress =
        locationParts.isNotEmpty ? locationParts.join(', ') : 'Location TBA';

    return MatchTournamentModel(
      event: event,
      registeredId: '#${registration.id}',
      registeredDate: _formatDate(registration.creationTimestamp),
      registeredTime: _formatTime(registration.creationTimestamp),
      priceWithTax: registration.tournamentFeesAmount ?? 0,
      serviceFee: 0,
      totalAmount:
          registration.paymentAmount ?? registration.tournamentFeesAmount ?? 0,
      registrationStartDate: _formatDate(tournament.registrationStartDate),
      registrationEndDate: _formatDate(tournament.registrationCloseDate),
      startDate: _formatDate(tournament.tournamentDate),
      startTime: _formatTime(tournament.tournamentDate),
      endTime: _formatTime(tournament.tournamentEndDate),
      locationAddress: locationAddress,
      aboutEvent: tournament.description.isNotEmpty
          ? tournament.description
              .replaceAll(RegExp(r'<[^>]*>'), '')
              .replaceAll('&nbsp;', ' ')
              .trim()
          : 'Join this exciting ${tournament.sport} tournament organized by ${tournament.community}.',
      scoringStructure: tournament.tournamentType.isNotEmpty
          ? tournament.tournamentType
          : 'Standard scoring',
      equipmentRequired:
          'Equipment as per ${tournament.sport} tournament requirements',
      rules: parsedRules,
      tournamentSponsorsList: tournament.tournamentSponsorsList,
    );
  }
}

class MatchDetailsPage extends ConsumerStatefulWidget {
  const MatchDetailsPage({super.key, required this.event});
  final EventModel event;

  @override
  ConsumerState<MatchDetailsPage> createState() => _MatchDetailsPageState();
}

class _MatchDetailsPageState extends ConsumerState<MatchDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showPriceBreakup = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildHeader(
    BuildContext context,
    MatchTournamentModel matchTournament,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GlobalAppBar(
          title: widget.event.title,
          titleFontSize: AppResponsive.s(context, 20),
          subtitle: widget.event.category,
          subtitleFontSize: AppResponsive.s(context, 16),
          showBackButton: true,
          showDivider: true,
        ),
        // if (matchTournament.tournamentSponsorsList.isNotEmpty)
        //   _MatchSponsorsSection(matchTournament: matchTournament),
      ],
    );
  }

  Widget _buildMatchCard(BuildContext context) {
    return Padding(
      padding: AppResponsive.padding(context, horizontal: 20, top: 16),
      child: MatchCardNew(
        team1Name: 'Team A',
        team1Section: '${widget.event.registeredCount} Players',
        team2Name: 'Team B',
        team2Section: '${widget.event.registeredCount} Players',
        headerLabel: 'Round - 1',
        showScore: false,
        matchDate: '15 Dec 2025',
        matchTime: '8:00 PM',
        margin: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return AppTabBar(
        tabController: _tabController,
        tabs: const ['Your Details', 'Tournament Details']);
  }

  @override
  Widget build(BuildContext context) {
    final tournamentId = int.tryParse(widget.event.id) ?? 0;
    final registrationsAsync = ref.watch(myTournamentRegistrationsProvider);

    return registrationsAsync.when(
      data: (registrations) {
        final registration =
            registrations.cast<TournamentRegistrationModel?>().firstWhere(
                  (reg) => reg?.tournamentId == tournamentId,
                  orElse: () => null,
                );

        if (registration != null) {
          final tournamentAsync =
              ref.watch(tournamentDetailsProvider(registration.tournamentId));
          return tournamentAsync.when(
            data: (tournament) {
              final matchTournament = tournament != null
                  ? MatchTournamentModel.fromTournament(
                      tournament: tournament,
                      registration: registration,
                      event: widget.event)
                  : _createFallbackModel(registration);
              return _buildContent(context, matchTournament, registration);
            },
            loading: () => Scaffold(
                backgroundColor: Colors.white,
                body: Center(
                    child: AppLoading.circular(color: AppColors.accentBlue))),
            error: (error, stack) => _buildContent(
                context, _createFallbackModel(registration), registration),
          );
        }
        return _buildContent(context, _createFallbackModel(null), null);
      },
      loading: () => Scaffold(
          backgroundColor: Colors.white,
          body:
              Center(child: AppLoading.circular(color: AppColors.accentBlue))),
      error: (error, stack) =>
          _buildContent(context, _createFallbackModel(null), null),
    );
  }

  MatchTournamentModel _createFallbackModel(
      TournamentRegistrationModel? registration) {
    return MatchTournamentModel(
      event: widget.event,
      registeredId: registration != null ? '#${registration.id}' : '#000',
      registeredDate: registration != null
          ? _formatDate(registration.creationTimestamp)
          : _formatDate(DateTime.now().toString()),
      registeredTime: registration != null
          ? _formatTime(registration.creationTimestamp)
          : _formatTime(DateTime.now().toString()),
      priceWithTax: registration?.tournamentFeesAmount ?? 0,
      serviceFee: 0,
      totalAmount: registration?.paymentAmount ??
          registration?.tournamentFeesAmount ??
          0,
      registrationStartDate: '',
      registrationEndDate: '',
      startDate: '',
      startTime: '',
      endTime: '',
      locationAddress: widget.event.location,
      aboutEvent:
          'Join this exciting ${widget.event.category} tournament. More details will be available soon.',
      scoringStructure: 'Standard scoring',
      equipmentRequired: 'Equipment as per tournament requirements',
      rules: ['Tournament rules will be provided by the organizer'],
      tournamentSponsorsList: const [],
    );
  }

  Widget _buildContent(
      BuildContext context,
      MatchTournamentModel matchTournament,
      TournamentRegistrationModel? registration) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              SafeArea(
                  bottom: false, child: _buildHeader(context, matchTournament)),
              _buildMatchCard(context),
              _buildTabBar(context),
              Expanded(
                child: IndexedStack(
                  index: _tabController.index,
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          _YourDetailsTab(
                            registration: registration,
                            tournamentId: int.tryParse(widget.event.id) ?? 0,
                            showPriceBreakup: _showPriceBreakup,
                            onTogglePriceBreakup: () {
                              setState(() {
                                _showPriceBreakup = !_showPriceBreakup;
                              });
                            },
                            isInviteOnly: !widget.event.openOrClose,
                          ),
                          SizedBox(height: AppResponsive.sh(context, 100)),
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          _TournamentDetailsTab(
                              matchTournament: matchTournament,
                              tournamentId: int.tryParse(widget.event.id) ?? 0),
                          SizedBox(height: AppResponsive.sh(context, 100)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Container(
                padding: AppResponsive.padding(context,
                    horizontal: 20, vertical: 12, bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: AppResponsive.s(context, 10),
                        offset: Offset(0, AppResponsive.s(context, -2))),
                  ],
                ),
                child: AppButton(
                  text: 'View Your Matches',
                  onPressed: () {
                    Navigator.pushNamed(context, AppRouter.liveMatchScreen,
                        arguments: widget.event);
                  },
                  trailingIcon: Icons.chevron_right,
                  width: double.infinity,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _YourDetailsTab extends ConsumerWidget {
  const _YourDetailsTab(
      {this.registration,
      required this.tournamentId,
      required this.showPriceBreakup,
      required this.onTogglePriceBreakup,
      this.isInviteOnly = false});

  final TournamentRegistrationModel? registration;
  final int tournamentId;
  final bool showPriceBreakup;
  final VoidCallback onTogglePriceBreakup;
  final bool isInviteOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enrolledPlayersAsync =
        ref.watch(enrolledPlayersProvider(tournamentId));
    final apiClient = ref.watch(apiClientProvider);

    return Padding(
      padding: AppResponsive.padding(context, horizontal: 20, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (registration != null)
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoRowWithIcon(
                      icon: Icons.confirmation_number_outlined,
                      title: 'Registered Id',
                      value: '#${registration!.id}'),
                  SizedBox(height: AppResponsive.s(context, 16)),
                  InfoRowWithIcon(
                    icon: Icons.calendar_today_outlined,
                    title: 'Registered Date & Time',
                    value:
                        '${_formatDate(registration!.creationTimestamp)}  ${_formatTime(registration!.creationTimestamp)}',
                  ),
                  if (registration!.paymentStatus != null &&
                      registration!.paymentStatus!.isNotEmpty) ...[
                    SizedBox(height: AppResponsive.s(context, 16)),
                    InfoRowWithIcon(
                        icon: Icons.payment_outlined,
                        title: 'Payment Status',
                        value: registration!.paymentStatus!),
                  ],
                ],
              ),
            ),
          SizedBox(height: AppResponsive.s(context, 16)),
          enrolledPlayersAsync.when(
            data: (players) {
              if (players.isEmpty) {
                return SectionCard(
                  child: Center(
                    child: Padding(
                      padding: AppResponsive.padding(context, vertical: 20),
                      child: Text('No enrolled players yet',
                          style: TextStyle(
                              fontFamily: 'SFProRounded',
                              fontSize: AppResponsive.font(context, 14),
                              color: AppColors.textSecondaryLight)),
                    ),
                  ),
                );
              }

              final seenIds = <int>{};
              final uniquePlayers = players.where((player) {
                final id = player['id'] as int? ?? 0;
                if (seenIds.contains(id)) return false;
                seenIds.add(id);
                return true;
              }).toList();

              final teammates = uniquePlayers.map((player) {
                final avatarFile = (player['imageFile'] ??
                        player['userProfileImage'] ??
                        player['avatarUrl'] ??
                        player['profileImage'])
                    ?.toString();
                final avatarUrl = avatarFile != null && avatarFile.isNotEmpty
                    ? '${apiClient.baseUrl}${ApiEndpoints.usersUploads}$avatarFile'
                    : null;
                return TeammateDisplayModel(
                  id: player['id']?.toString() ?? '',
                  name: _constructPlayerName(player),
                  role: player['sportRole']?.toString() ?? '',
                  avatarUrl: avatarUrl,
                );
              }).toList();

              return TeammatesSection(
                title: 'Enrolled Players',
                playerCount: teammates.length,
                teammates: teammates,
                maxVisibleTeammates: 6,
                showCheckIcon: false,
                onAddTap: () {},
                addButtonText: '',
              );
            },
            loading: () => Padding(
                padding: AppResponsive.padding(context, vertical: 20),
                child: Center(
                    child: AppLoading.circular(color: AppColors.accentBlue))),
            error: (error, stack) => Padding(
              padding: AppResponsive.padding(context, vertical: 20),
              child: Center(
                  child: Text('Error loading enrolled players',
                      style: TextStyle(
                          fontFamily: 'SFProRounded',
                          fontSize: AppResponsive.font(context, 14),
                          color: Colors.red))),
            ),
          ),
          if (!isInviteOnly && registration != null)
            PriceSection(
              priceWithTax: registration!.tournamentFeesAmount ?? 0,
              serviceFee: 0,
              totalAmount: registration!.tournamentFeesAmount ?? 0,
              showBreakup: showPriceBreakup,
              onToggleBreakup: onTogglePriceBreakup,
            ),
        ],
      ),
    );
  }
}

class _TournamentDetailsTab extends ConsumerWidget {
  const _TournamentDetailsTab(
      {required this.matchTournament, required this.tournamentId});

  final MatchTournamentModel matchTournament;
  final int tournamentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enrolledPlayersAsync =
        ref.watch(enrolledPlayersProvider(tournamentId));

    return enrolledPlayersAsync.when(
      data: (players) => _buildContent(context, players.length),
      loading: () => Padding(
          padding: AppResponsive.padding(context, horizontal: 20, top: 20),
          child: const Center(child: CircularProgressIndicator())),
      error: (error, stack) =>
          _buildContent(context, matchTournament.event.registeredCount),
    );
  }

  Widget _buildContent(BuildContext context, int enrolledPlayersCount) {
    return Padding(
      padding: AppResponsive.padding(context, horizontal: 20, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MatchTournamentInfoContainer(
              matchTournament: matchTournament,
              enrolledPlayersCount: enrolledPlayersCount),
          SizedBox(height: AppResponsive.s(context, 20)),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'ABOUT EVENT'),
                SizedBox(height: AppResponsive.s(context, 10)),
                Text(matchTournament.aboutEvent,
                    style: TextStyle(
                        fontFamily: 'SFProRounded',
                        fontSize: AppResponsive.font(context, 14),
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                        color: const Color(0xFF5C5C5C))),
              ],
            ),
          ),
          SizedBox(height: AppResponsive.s(context, 16)),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionWithIconInline(
                    icon: AppAssets.trophyIcon,
                    iconColor: Color(0xFFFFF8E1),
                    title: 'SCORING STRUCTURE'),
                SizedBox(height: AppResponsive.s(context, 12)),
                Text(matchTournament.scoringStructure,
                    style: TextStyle(
                        fontFamily: 'SFProRounded',
                        fontSize: AppResponsive.font(context, 14),
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                        color: const Color(0xFF5C5C5C))),
              ],
            ),
          ),
          SizedBox(height: AppResponsive.s(context, 16)),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionWithIconInline(
                    icon: Icons.description_outlined,
                    iconColor: Color(0xFFE3F2FD),
                    title: 'EQUIPMENT REQUIRED'),
                SizedBox(height: AppResponsive.s(context, 12)),
                Text(matchTournament.equipmentRequired,
                    style: TextStyle(
                        fontFamily: 'SFProRounded',
                        fontSize: AppResponsive.font(context, 14),
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                        color: const Color(0xFF5C5C5C))),
              ],
            ),
          ),
          SizedBox(height: AppResponsive.s(context, 16)),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'RULES & REGULATIONS'),
                ...matchTournament.rules.map(
                  (rule) => Padding(
                    padding: EdgeInsets.only(top: AppResponsive.s(context, 10)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                              EdgeInsets.only(top: AppResponsive.s(context, 8)),
                          child: Container(
                              width: AppResponsive.s(context, 5),
                              height: AppResponsive.s(context, 5),
                              decoration: const BoxDecoration(
                                  color: Color(0xFF5C5C5C),
                                  shape: BoxShape.circle)),
                        ),
                        SizedBox(width: AppResponsive.s(context, 10)),
                        Expanded(
                            child: Text(rule,
                                style: TextStyle(
                                    fontFamily: 'SFProRounded',
                                    fontSize: AppResponsive.font(context, 14),
                                    fontWeight: FontWeight.w400,
                                    height: 1.5,
                                    color: const Color(0xFF5C5C5C)))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchTournamentInfoContainer extends StatelessWidget {
  const _MatchTournamentInfoContainer(
      {required this.matchTournament, required this.enrolledPlayersCount});

  final MatchTournamentModel matchTournament;
  final int enrolledPlayersCount;

  @override
  Widget build(BuildContext context) {
    final progress = matchTournament.event.maxParticipants > 0
        ? enrolledPlayersCount / matchTournament.event.maxParticipants
        : 0.0;

    return SectionCard(
      child: Column(
        children: [
          InfoRowWithIcon(
            icon: Icons.calendar_today_outlined,
            title: 'Registration Start Date & End Date',
            value:
                '${matchTournament.registrationStartDate}  to  ${matchTournament.registrationEndDate}',
          ),
          SizedBox(height: AppResponsive.s(context, 18)),
          _DetailInfoRowWithDetail(
            icon: Icons.calendar_today_outlined,
            title: 'Start Date & Time',
            subtitle: matchTournament.startDate,
            detail: '${matchTournament.startTime} - ${matchTournament.endTime}',
          ),
          SizedBox(height: AppResponsive.s(context, 18)),
          _DetailInfoRowWithDetail(
              icon: Icons.location_on_outlined,
              title: 'Location',
              subtitle: matchTournament.locationAddress),
          SizedBox(height: AppResponsive.s(context, 18)),
          Row(
            children: [
              Container(
                width: AppResponsive.s(context, 44),
                height: AppResponsive.s(context, 44),
                decoration: const BoxDecoration(
                    color: AppColors.accentBlue, shape: BoxShape.circle),
                child: Icon(Icons.people_outline,
                    color: Colors.white, size: AppResponsive.icon(context, 22)),
              ),
              SizedBox(width: AppResponsive.s(context, 14)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Registration',
                        style: TextStyle(
                            fontFamily: 'SFProRounded',
                            fontSize: AppResponsive.font(context, 14),
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondaryLight)),
                    SizedBox(height: AppResponsive.s(context, 4)),
                    Text(
                      '$enrolledPlayersCount/${matchTournament.event.maxParticipants} Players',
                      style: TextStyle(
                          fontFamily: 'SFProRounded',
                          fontSize: AppResponsive.font(context, 16),
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimaryLight),
                    ),
                    SizedBox(height: AppResponsive.s(context, 4)),
                    AppLoading.linearRounded(
                        value: progress,
                        height: AppResponsive.s(context, 8),
                        borderRadius: AppResponsive.radius(context, 8),
                        color: AppColors.accentBlue,
                        backgroundColor: const Color(0xFFE8EAF6)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailInfoRowWithDetail extends StatelessWidget {
  const _DetailInfoRowWithDetail(
      {required this.icon,
      required this.title,
      required this.subtitle,
      this.detail = ''});

  final IconData icon;
  final String title;
  final String subtitle;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: AppResponsive.s(context, 44),
          height: AppResponsive.s(context, 44),
          decoration: const BoxDecoration(
              color: AppColors.accentBlue, shape: BoxShape.circle),
          child: Icon(icon,
              color: Colors.white, size: AppResponsive.icon(context, 22)),
        ),
        SizedBox(width: AppResponsive.s(context, 14)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontFamily: 'SFProRounded',
                      fontSize: AppResponsive.font(context, 14),
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondaryLight)),
              SizedBox(height: AppResponsive.s(context, 2)),
              Text(subtitle,
                  style: TextStyle(
                      fontFamily: 'SFProRounded',
                      fontSize: AppResponsive.font(context, 16),
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryLight)),
              if (detail.isNotEmpty) ...[
                SizedBox(height: AppResponsive.s(context, 2)),
                Text(detail,
                    style: TextStyle(
                        fontFamily: 'SFProRounded',
                        fontSize: AppResponsive.font(context, 14),
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryLight)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionWithIconInline extends StatelessWidget {
  const _SectionWithIconInline(
      {required this.icon, required this.iconColor, required this.title});

  final dynamic icon;
  final Color iconColor;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        icon is IconData
            ? Icon(icon,
                color: AppColors.accentBlue,
                size: AppResponsive.icon(context, 20))
            : Center(
                child: SvgPicture.asset(
                  icon,
                  width: AppResponsive.icon(context, 20),
                  height: AppResponsive.icon(context, 20),
                  colorFilter: const ColorFilter.mode(
                      AppColors.accentBlue, BlendMode.srcIn),
                ),
              ),
        SizedBox(width: AppResponsive.s(context, 8)),
        Text(title,
            style: TextStyle(
                fontFamily: 'SFProRounded',
                fontSize: AppResponsive.font(context, 14),
                fontWeight: FontWeight.w700,
                color: const Color(0xFF000000))),
      ],
    );
  }
}

/// Sponsors Section Widget
class _MatchSponsorsSection extends ConsumerWidget {
  const _MatchSponsorsSection({
    required this.matchTournament,
  });

  final MatchTournamentModel matchTournament;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sponsorsData = matchTournament.tournamentSponsorsList;

    if (kDebugMode) {
      print('👁️ [_MatchSponsorsSection] Building sponsors section');
      print('   Tournament: ${matchTournament.event.title}');
      print('   Sponsors count: ${sponsorsData.length}');
      print('   Sponsors data: $sponsorsData');
    }

    if (sponsorsData.isEmpty) {
      if (kDebugMode) {
        print('   ❌ No sponsors - returning empty SizedBox');
      }
      return const SizedBox(height: 0, width: double.infinity);
    }

    return _SponsorsAutoScrollSection(sponsorsData: sponsorsData);
  }
}

class _SponsorsAutoScrollSection extends ConsumerStatefulWidget {
  const _SponsorsAutoScrollSection({required this.sponsorsData});

  final List<dynamic> sponsorsData;

  @override
  ConsumerState<_SponsorsAutoScrollSection> createState() =>
      _SponsorsAutoScrollSectionState();
}

class _SponsorsAutoScrollSectionState
    extends ConsumerState<_SponsorsAutoScrollSection> {
  late PageController _pageController;
  Timer? _timer;
  double _itemWidth = 0;

  @override
  void initState() {
    super.initState();
    int initialPage = 10000;
    if (widget.sponsorsData.isNotEmpty) {
      initialPage = 10000 - (10000 % widget.sponsorsData.length);
    }

    _pageController = PageController(
      viewportFraction: 1 / 3,
      initialPage: initialPage,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final double screenWidth = MediaQuery.of(context).size.width;
    final double availableWidth = screenWidth - AppResponsive.s(context, 40);
    _itemWidth = availableWidth / 3;

    if (widget.sponsorsData.length > 3 && _timer == null) {
      _startAutoScroll();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    const duration = Duration(seconds: 3);
    _timer = Timer.periodic(duration, (timer) {
      if (_pageController.hasClients) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        _pageController.nextPage(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: AppResponsive.s(context, 12),
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: widget.sponsorsData.length <= 3
            ? SizedBox(
                height: AppResponsive.s(context, 95),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: widget.sponsorsData.map((sponsor) {
                    final dataSource =
                        ref.read(tournamentsRemoteDataSourceProvider);
                    final imageUrl =
                        dataSource.getSponsorImageUrl(sponsor['imageFile']);

                    return SizedBox(
                      width: _itemWidth,
                      child: Center(
                        child: _SponsorTile(
                          imageUrl: imageUrl,
                          sponsorName: sponsor['name'] ?? '',
                          sponsorType: sponsor['sponsorType'] ?? '',
                        ),
                      ),
                    );
                  }).toList(),
                ),
              )
            : SizedBox(
                height: AppResponsive.s(context, 95),
                child: PageView.builder(
                  controller: _pageController,
                  itemBuilder: (context, index) {
                    final sponsor =
                        widget.sponsorsData[index % widget.sponsorsData.length];
                    final dataSource =
                        ref.read(tournamentsRemoteDataSourceProvider);
                    final imageUrl =
                        dataSource.getSponsorImageUrl(sponsor['imageFile']);

                    return Center(
                      child: _SponsorTile(
                        imageUrl: imageUrl,
                        sponsorName: sponsor['name'] ?? '',
                        sponsorType: sponsor['sponsorType'] ?? '',
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}

class _SponsorTile extends StatelessWidget {
  const _SponsorTile({
    required this.imageUrl,
    required this.sponsorName,
    required this.sponsorType,
  });

  final String imageUrl;
  final String sponsorName;
  final String sponsorType;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: AppResponsive.s(context, 60),
          height: AppResponsive.s(context, 40),
          decoration: BoxDecoration(
            borderRadius: AppResponsive.borderRadius(context, 8),
          ),
          child: imageUrl.isEmpty
              ? const Icon(
                  Icons.business,
                  color: Colors.white,
                  size: 18,
                )
              : CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                  placeholder: (context, url) => const Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.business,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
        ),
        AppResponsive.verticalSpace(context, 5),
        Text(
          sponsorName.isNotEmpty
              ? sponsorName[0].toUpperCase() +
                  sponsorName.substring(1).toLowerCase()
              : '',
          style: TextStyle(
            fontSize: AppResponsive.font(context, 13),
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.normal,
            color: const Color(0xFF5C5C5C),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        Text(
          sponsorType.isNotEmpty
              ? "(${sponsorType[0].toUpperCase()}${sponsorType.substring(1).toLowerCase()})"
              : '',
          style: TextStyle(
            fontSize: AppResponsive.font(context, 13),
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.normal,
            color: AppColors.accentBlue,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
