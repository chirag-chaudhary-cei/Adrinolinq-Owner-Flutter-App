
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors_new.dart';
import '../../../../core/theme/app_responsive.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_tab_bar.dart';
import '../../../../core/widgets/detail_widgets.dart';
import '../../../../core/widgets/event_card.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/providers/app_providers.dart';
import '../../data/models/tournament_registration_model.dart';
import '../../data/models/my_team_model.dart';
import '../providers/my_tournament_providers.dart';
import '../../../home/data/models/tournament_model.dart';
import '../../../home/presentation/providers/tournaments_providers.dart';

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

class RegisteredTournamentModel {
  final EventModel event;
  final String registeredId;
  final String registeredDate;
  final String registeredTime;
  final List<TeammateModel> teammates;
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
  final int currentRegistered;
  final int maximumRegistrationsCount;

  const RegisteredTournamentModel({
    required this.event,
    required this.registeredId,
    required this.registeredDate,
    required this.registeredTime,
    required this.teammates,
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
    required this.currentRegistered,
    required this.maximumRegistrationsCount,
  });

  factory RegisteredTournamentModel.fromTournament({
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
    if (parsedRules.isEmpty) {
      parsedRules = ['Tournament rules will be provided by the organizer'];
    }

    final locationParts = [
      if (tournament.region.isNotEmpty) tournament.region,
      if (tournament.city.isNotEmpty) tournament.city,
      if (tournament.district.isNotEmpty) tournament.district,
      if (tournament.state.isNotEmpty) tournament.state,
    ];
    final locationAddress =
        locationParts.isNotEmpty ? locationParts.join(', ') : 'Location TBA';

    return RegisteredTournamentModel(
      event: event,
      registeredId: '#${registration.id}',
      registeredDate: _formatDate(registration.creationTimestamp),
      registeredTime: _formatTime(registration.creationTimestamp),
      teammates: const [],
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
      currentRegistered: tournament.currentRegistered,
      maximumRegistrationsCount: tournament.maximumRegistrationsCount,
    );
  }
}

class TeammateModel {
  final String name;
  final String role;
  final String? avatarUrl;

  const TeammateModel({
    required this.name,
    required this.role,
    this.avatarUrl,
  });
}

class RegisteredTournamentDetailPage extends ConsumerStatefulWidget {
  const RegisteredTournamentDetailPage({
    super.key,
    required this.event,
    required this.registration,
  });

  final EventModel event;
  final TournamentRegistrationModel registration;

  @override
  ConsumerState<RegisteredTournamentDetailPage> createState() =>
      _RegisteredTournamentDetailPageState();
}

class _RegisteredTournamentDetailPageState
    extends ConsumerState<RegisteredTournamentDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showPriceBreakup = false;

  final ScrollController _tournamentDetailsScrollController =
      ScrollController();
  final ScrollController _myTeamScrollController = ScrollController();

  double _headerOffset = 0.0;
  double _maxHeaderHeight = 300.0;
  static const double _tabBarHeight = 68.0;
  static const double _minAppBarHeight = 72.0;

  int _lastTabIndex = 0;

  double get _collapseExtent => _maxHeaderHeight - _minAppBarHeight;
  double get _expandedTotalHeight => _maxHeaderHeight + _tabBarHeight;

  void _handleTabChange() {
    if (_tabController.index == _lastTabIndex) return;
    if (_tabController.indexIsChanging) return;

    final wasCollapsed = _headerOffset >= 0.5;
    final newController = _tabController.index == 0
        ? _tournamentDetailsScrollController
        : _myTeamScrollController;

    _lastTabIndex = _tabController.index;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (newController.hasClients && mounted) {
        final maxExtent = newController.position.maxScrollExtent;
        if (wasCollapsed && maxExtent > 0) {
          newController.jumpTo(_collapseExtent.clamp(0.0, maxExtent));
          setState(() => _headerOffset = 1.0);
        } else {
          newController.jumpTo(0.0);
          setState(() => _headerOffset = 0.0);
        }
      }
    });
    setState(() {});
  }

  void _onTournamentDetailsScroll() {
    if (!_tournamentDetailsScrollController.hasClients) return;
    if (_tabController.index != 0) return;
    _updateHeaderOffset(_tournamentDetailsScrollController);
  }

  void _onMyTeamScroll() {
    if (!_myTeamScrollController.hasClients) return;
    if (_tabController.index != 1) return;
    _updateHeaderOffset(_myTeamScrollController);
  }

  void _updateHeaderOffset(ScrollController controller) {
    if (_collapseExtent <= 0) return;
    final offset = controller.offset;
    final newOffset = (offset / _collapseExtent).clamp(0.0, 1.0);
    if ((newOffset - _headerOffset).abs() > 0.001) {
      setState(() => _headerOffset = newOffset);
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _lastTabIndex = _tabController.index;
    _tabController.addListener(_handleTabChange);
    _tournamentDetailsScrollController.addListener(_onTournamentDetailsScroll);
    _myTeamScrollController.addListener(_onMyTeamScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      );
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _tournamentDetailsScrollController
        .removeListener(_onTournamentDetailsScroll);
    _tournamentDetailsScrollController.dispose();
    _myTeamScrollController.removeListener(_onMyTeamScroll);
    _myTeamScrollController.dispose();
    super.dispose();
  }

  Widget _buildCollapsibleHeader(
    BuildContext context,
    RegisteredTournamentModel registeredTournament,
  ) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    _maxHeaderHeight = AppResponsive.sh(context, 300);

    final collapsedHeaderHeight = _minAppBarHeight + statusBarHeight;
    final expandedHeaderHeight = _maxHeaderHeight;
    final currentHeaderHeight = expandedHeaderHeight -
        (expandedHeaderHeight - collapsedHeaderHeight) * _headerOffset;

    final heroContentOpacity = (1 - _headerOffset * 1.5).clamp(0.0, 1.0);
    final appBarBgOpacity = _headerOffset;
    final titleOpacity = ((_headerOffset - 0.5) * 2).clamp(0.0, 1.0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      height: currentHeaderHeight,
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: heroContentOpacity,
              child: _HeroImageSection(event: widget.event),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: collapsedHeaderHeight,
            child: Opacity(
              opacity: appBarBgOpacity,
              child: Container(color: Colors.white),
            ),
          ),
          Positioned(
            top: statusBarHeight + AppResponsive.s(context, 12),
            left: AppResponsive.s(context, 16),
            child: const AppBackButton(isTransparent: false),
          ),
          Positioned(
            top: statusBarHeight + AppResponsive.s(context, 12),
            left: AppResponsive.s(context, 80),
            right: AppResponsive.s(context, 16),
            height: AppResponsive.s(context, 48),
            child: Opacity(
              opacity: titleOpacity,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.event.title,
                  style: TextStyle(
                    fontFamily: 'SFProRounded',
                    fontSize: AppResponsive.font(context, 18),
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return AppTabBar(
      tabController: _tabController,
      tabs: const ['Tournament Details', 'My Team'],
    );
  }

  Widget _buildMyTeamTabContent(
    BuildContext context,
    RegisteredTournamentModel registeredTournament,
  ) {
    return SingleChildScrollView(
      key: const PageStorageKey('my_team_scroll'),
      controller: _myTeamScrollController,
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.only(top: _expandedTotalHeight),
      child: Column(
        children: [
          _MyTeamTab(
            registration: widget.registration,
            tournamentId: widget.registration.tournamentId,
          ),
          SizedBox(height: AppResponsive.sh(context, 100)),
        ],
      ),
    );
  }

  Widget _buildTournamentDetailsTabContent(
    BuildContext context,
    RegisteredTournamentModel registeredTournament,
  ) {
    return SingleChildScrollView(
      key: const PageStorageKey('tournament_details_scroll'),
      controller: _tournamentDetailsScrollController,
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.only(top: _expandedTotalHeight),
      child: Column(
        children: [
          _TournamentDetailsTab(
            registeredTournament: registeredTournament,
            registration: widget.registration,
            tournamentId: widget.registration.tournamentId,
            showPriceBreakup: _showPriceBreakup,
            onTogglePriceBreakup: () {
              setState(() => _showPriceBreakup = !_showPriceBreakup);
            },
            isInviteOnly: !widget.event.openOrClose,
          ),
          SizedBox(height: AppResponsive.sh(context, 100)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tournamentAsync =
        ref.watch(tournamentDetailsProvider(widget.registration.tournamentId));

    return tournamentAsync.when(
      data: (tournament) {
        final registeredTournament = tournament != null
            ? RegisteredTournamentModel.fromTournament(
                tournament: tournament,
                registration: widget.registration,
                event: widget.event,
              )
            : _createFallbackModel();
        return _buildContent(context, registeredTournament);
      },
      loading: () => Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            _HeroImageSection(event: widget.event),
            const Center(
              child: CircularProgressIndicator(color: AppColors.accentBlue),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              left: 16,
              child: const AppBackButton(),
            ),
          ],
        ),
      ),
      error: (error, stack) {
        final fallbackModel = _createFallbackModel();
        return _buildContent(context, fallbackModel);
      },
    );
  }

  RegisteredTournamentModel _createFallbackModel() {
    final locationParts = [
      if (widget.registration.tournamentCity != null &&
          widget.registration.tournamentCity!.isNotEmpty)
        widget.registration.tournamentCity!,
      if (widget.registration.tournamentState != null &&
          widget.registration.tournamentState!.isNotEmpty)
        widget.registration.tournamentState!,
    ];
    final locationAddress =
        locationParts.isNotEmpty ? locationParts.join(', ') : 'Location TBA';

    return RegisteredTournamentModel(
      event: widget.event,
      registeredId: '#${widget.registration.id}',
      registeredDate: _formatDate(widget.registration.creationTimestamp),
      registeredTime: _formatTime(widget.registration.creationTimestamp),
      teammates: const [],
      priceWithTax: widget.registration.tournamentFeesAmount ?? 0,
      serviceFee: 0,
      totalAmount: widget.registration.paymentAmount ??
          widget.registration.tournamentFeesAmount ??
          0,
      registrationStartDate: '',
      registrationEndDate: '',
      startDate: widget.registration.tournamentDate != null
          ? _formatDate(widget.registration.tournamentDate!)
          : '',
      startTime: widget.registration.tournamentDate != null
          ? _formatTime(widget.registration.tournamentDate!)
          : '',
      endTime: widget.registration.tournamentEndDate != null
          ? _formatTime(widget.registration.tournamentEndDate!)
          : '',
      locationAddress: locationAddress,
      aboutEvent:
          'Tournament details will be available soon. Contact the organizer for more information.',
      scoringStructure: 'Contact organizer for scoring details',
      equipmentRequired:
          'Equipment as per ${widget.registration.tournamentSport ?? 'tournament'} requirements',
      rules: ['Tournament rules will be provided by the organizer'],
      tournamentSponsorsList: const [],
      currentRegistered: widget.event.registeredCount,
      maximumRegistrationsCount: widget.event.maxParticipants,
    );
  }

  Widget _buildContent(
    BuildContext context,
    RegisteredTournamentModel registeredTournament,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: IndexedStack(
              index: _tabController.index,
              children: [
                _buildTournamentDetailsTabContent(
                    context, registeredTournament),
                _buildMyTeamTabContent(context, registeredTournament),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCollapsibleHeader(context, registeredTournament),
                // if (registeredTournament.tournamentSponsorsList.isNotEmpty)
                //   Container(
                //     color: Colors.white,
                //     child: _RegisteredSponsorsSection(
                //       registeredTournament: registeredTournament,
                //     ),
                //   ),
                _buildTabBar(context),
              ],
            ),
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
                      offset: Offset(0, AppResponsive.s(context, -2)),
                    ),
                  ],
                ),
                child: AppButton(
                  text: 'View All Matches',
                  onPressed: () {
                    Navigator.pushNamed(context, AppRouter.matchDetails,
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

class _HeroImageSection extends ConsumerWidget {
  const _HeroImageSection({required this.event});
  final EventModel event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: AppResponsive.sh(context, 300),
      child: Stack(
        children: [
          Positioned.fill(
            child: event.imageUrl.startsWith('http')
                ? Image.network(
                    event.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFF1A3A3A),
                        child: Center(
                            child: Icon(Icons.image_not_supported,
                                color: Colors.white54,
                                size: AppResponsive.icon(context, 48))),
                      );
                    },
                  )
                : Image.asset(
                    event.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(color: const Color(0xFF1A3A3A));
                    },
                  ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.transparent,
                    Colors.black.withOpacity(0.75)
                  ],
                  stops: const [0.0, 0.3, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: AppResponsive.s(context, 16),
            left: AppResponsive.s(context, 20),
            right: AppResponsive.s(context, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: AppResponsive.paddingSymmetric(context,
                      horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: AppResponsive.borderRadius(context, 16),
                  ),
                  child: Text(event.category,
                      style: TextStyle(
                          fontSize: AppResponsive.font(context, 12),
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
                AppResponsive.verticalSpace(context, 10),
                Text(event.title,
                    style: TextStyle(
                        fontSize: AppResponsive.font(context, 24),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2)),
                AppResponsive.verticalSpace(context, 8),
                if (event.openOrClose)
                  Text(
                    event.price == '0' || event.price == '0.0'
                        ? 'Free'
                        : 'INR ${event.price}',
                    style: TextStyle(
                        fontSize: AppResponsive.font(context, 17),
                        fontWeight: FontWeight.w600,
                        color: AppColors.accentBlue),
                  )
                else
                  Container(
                    padding: AppResponsive.paddingSymmetric(context,
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                        borderRadius: AppResponsive.borderRadius(context, 16),
                        color: const Color(0xFFCDFE00)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_outline,
                            size: AppResponsive.icon(context, 14),
                            color: Colors.black),
                        AppResponsive.horizontalSpace(context, 4),
                        Text('Invite Only',
                            style: TextStyle(
                                fontSize: AppResponsive.font(context, 12),
                                fontWeight: FontWeight.w700,
                                color: Colors.black)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top +
                AppResponsive.s(context, 12),
            left: AppResponsive.s(context, 16),
            child: const AppBackButton(),
          ),
        ],
      ),
    );
  }
}

class _MyTeamTab extends ConsumerWidget {
  const _MyTeamTab({
    required this.registration,
    required this.tournamentId,
  });

  final TournamentRegistrationModel registration;
  final int tournamentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myTeamAsync = ref.watch(myTeamProvider(tournamentId));

    return myTeamAsync.when(
      data: (team) {
        if (team == null) {
          return _buildNotAllocated(context);
        }
        return _buildTeamContent(context, ref, team);
      },
      loading: () => Padding(
        padding: AppResponsive.padding(context, horizontal: 20, top: 40),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.accentBlue),
        ),
      ),
      error: (error, _) => Padding(
        padding: AppResponsive.padding(context, horizontal: 20, top: 40),
        child: SectionCard(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: AppResponsive.s(context, 20)),
                Icon(
                  Icons.error_outline,
                  color: Colors.red.shade400,
                  size: AppResponsive.icon(context, 32),
                ),
                SizedBox(height: AppResponsive.s(context, 12)),
                Text(
                  'Failed to load team',
                  style: TextStyle(
                    fontFamily: 'SFProRounded',
                    fontSize: AppResponsive.font(context, 14),
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                SizedBox(height: AppResponsive.s(context, 20)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotAllocated(BuildContext context) {
    return Padding(
      padding: AppResponsive.padding(context, horizontal: 20, top: 40),
      child: SectionCard(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: AppResponsive.s(context, 20)),
              Container(
                width: AppResponsive.s(context, 64),
                height: AppResponsive.s(context, 64),
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.groups_outlined,
                  color: AppColors.accentBlue,
                  size: AppResponsive.icon(context, 32),
                ),
              ),
              SizedBox(height: AppResponsive.s(context, 16)),
              Text(
                'Team Not Allocated',
                style: TextStyle(
                  fontFamily: 'SFProRounded',
                  fontSize: AppResponsive.font(context, 18),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              SizedBox(height: AppResponsive.s(context, 8)),
              Text(
                'Team has not been allocated yet.\nPlease check back later.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'SFProRounded',
                  fontSize: AppResponsive.font(context, 13),
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF9E9E9E),
                  height: 1.5,
                ),
              ),
              SizedBox(height: AppResponsive.s(context, 20)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamContent(
      BuildContext context, WidgetRef ref, MyTeamModel team) {
    final activePlayers =
        team.teamPlayersList.where((p) => !p.deleted).toList();
    final currentCount = activePlayers.length;
    final isFull = currentCount >= team.maxTeamSize;

    return Padding(
      padding: AppResponsive.padding(context, horizontal: 20, top: 20),
      child: SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  team.name,
                  style: TextStyle(
                    fontFamily: 'SFProRounded',
                    fontSize: AppResponsive.font(context, 18),
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                Container(
                  padding: AppResponsive.paddingSymmetric(
                    context,
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isFull
                        ? Colors.red.shade50
                        : AppColors.accentBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    '$currentCount / ${team.maxTeamSize} Players',
                    style: TextStyle(
                      fontFamily: 'SFProRounded',
                      fontSize: AppResponsive.font(context, 12),
                      fontWeight: FontWeight.w600,
                      color:
                          isFull ? Colors.red.shade600 : AppColors.accentBlue,
                    ),
                  ),
                ),
              ],
            ),
            if (activePlayers.isEmpty) ...[
              SizedBox(height: AppResponsive.s(context, 16)),
              Center(
                child: Text(
                  'No players in team yet',
                  style: TextStyle(
                    fontFamily: 'SFProRounded',
                    fontSize: AppResponsive.font(context, 14),
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ),
              SizedBox(height: AppResponsive.s(context, 16)),
            ] else ...[
              SizedBox(height: AppResponsive.s(context, 16)),
              ...activePlayers.map(
                (player) => _TeamPlayerCard(
                  player: player,
                  isCaptainPlayer: player.playerUserId == team.captainUserId,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Individual team player card (view-only)
class _TeamPlayerCard extends ConsumerWidget {
  const _TeamPlayerCard({
    required this.player,
    this.isCaptainPlayer = false,
  });

  final MyTeamPlayerModel player;
  final bool isCaptainPlayer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Padding(
          padding: AppResponsive.padding(context, vertical: 12),
          child: Row(
            children: [
              // Avatar
              Container(
                width: AppResponsive.s(context, 50),
                height: AppResponsive.s(context, 50),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade200,
                ),
                child: ClipOval(child: _buildAvatar(context, ref)),
              ),
              SizedBox(width: AppResponsive.s(context, 12)),
              // Player Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            player.player,
                            style: TextStyle(
                              fontFamily: 'SFProRounded',
                              fontSize: AppResponsive.font(context, 15),
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (player.proficiencyLevel != null &&
                            player.proficiencyLevel!.isNotEmpty) ...[
                          SizedBox(width: AppResponsive.s(context, 8)),
                          Container(
                            padding: AppResponsive.paddingSymmetric(context,
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.accentBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text(
                              player.proficiencyLevel!,
                              style: TextStyle(
                                fontFamily: 'SFProRounded',
                                fontSize: AppResponsive.font(context, 11),
                                fontWeight: FontWeight.w600,
                                color: AppColors.accentBlue,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: AppResponsive.s(context, 4)),
                    if (isCaptainPlayer)
                      Text(
                        'Captain',
                        style: TextStyle(
                          fontFamily: 'SFProRounded',
                          fontSize: AppResponsive.font(context, 13),
                          fontWeight: FontWeight.w600,
                          color: AppColors.accentBlue,
                        ),
                      )
                    else
                      Text(
                        player.inviteStatusText,
                        style: TextStyle(
                          fontFamily: 'SFProRounded',
                          fontSize: AppResponsive.font(context, 13),
                          fontWeight: FontWeight.w500,
                          color: _statusColor(player.inviteStatus),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: AppResponsive.s(context, 8)),
              // Status icon
              if (isCaptainPlayer)
                Icon(Icons.star,
                    size: AppResponsive.icon(context, 22),
                    color: AppColors.accentBlue)
              else
                _statusIcon(context, player.inviteStatus),
            ],
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: const Color(0xFF0A1217).withOpacity(0.1),
        ),
      ],
    );
  }

  Widget _buildAvatar(BuildContext context, WidgetRef ref) {
    if (player.imageFile != null && player.imageFile!.isNotEmpty) {
      final apiClient = ref.watch(apiClientProvider);
      final imageUrl =
          '${apiClient.baseUrl}${ApiEndpoints.usersUploads}${player.imageFile}';
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => _placeholder(context),
        errorWidget: (context, url, error) => _placeholder(context),
      );
    }
    return _placeholder(context);
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Icon(Icons.person,
            size: AppResponsive.s(context, 24), color: Colors.grey.shade400),
      ),
    );
  }

  Widget _statusIcon(BuildContext context, int? status) {
    IconData icon;
    Color color;
    switch (status) {
      case 1:
        icon = Icons.check_circle;
        color = const Color(0xFF4CAF50);
        break;
      case 2:
        icon = Icons.cancel;
        color = const Color(0xFFE53935);
        break;
      default:
        icon = Icons.schedule;
        color = const Color(0xFFFF9800);
        break;
    }
    return Icon(icon, size: AppResponsive.icon(context, 22), color: color);
  }

  Color _statusColor(int? status) {
    switch (status) {
      case 1:
        return const Color(0xFF4CAF50);
      case 2:
        return const Color(0xFFE53935);
      default:
        return const Color(0xFFFF9800);
    }
  }
}

class _TournamentDetailsTab extends ConsumerWidget {
  const _TournamentDetailsTab({
    required this.registeredTournament,
    required this.registration,
    required this.tournamentId,
    required this.showPriceBreakup,
    required this.onTogglePriceBreakup,
    this.isInviteOnly = false,
  });

  final RegisteredTournamentModel registeredTournament;
  final TournamentRegistrationModel registration;
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
          // Registration Info Card
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoRowWithIcon(
                    icon: Icons.confirmation_number_outlined,
                    title: 'Registration Id',
                    value: '#${registration.id}'),
                SizedBox(height: AppResponsive.s(context, 16)),
                InfoRowWithIcon(
                    icon: Icons.calendar_today_outlined,
                    title: 'Registered Date & Time',
                    value: registration.creationTimestamp),
                SizedBox(height: AppResponsive.s(context, 16)),
                InfoRowWithIcon(
                  icon: Icons.payment_outlined,
                  title: 'Payment',
                  value: registration.paymentStatusId != 1
                      ? 'Paid'
                      : (registration.paymentStatus ?? 'Pending'),
                ),
              ],
            ),
          ),
          SizedBox(height: AppResponsive.s(context, 16)),
          // Tournament Info Container
          _TournamentInfoContainer(registeredTournament: registeredTournament),
          SizedBox(height: AppResponsive.s(context, 16)),
          // // Enrolled Players Section
          // enrolledPlayersAsync.when(
          //   data: (players) {
          //     final uniquePlayers = <String, Map<String, dynamic>>{};
          //     for (final player in players) {
          //       final id = player['id']?.toString() ?? '';
          //       if (id.isNotEmpty && !uniquePlayers.containsKey(id))
          //         uniquePlayers[id] = player;
          //     }
          //     final filteredPlayers = uniquePlayers.values.toList();
          //     if (filteredPlayers.isEmpty) return const SizedBox.shrink();
          //     final enrolledDisplayList = filteredPlayers
          //         .map(
          //           (player) => TeammateDisplayModel(
          //             id: player['id']?.toString() ?? '',
          //             name: _constructPlayerName(player),
          //             role: null,
          //             avatarUrl: player['imageFile'] != null &&
          //                     player['imageFile'].toString().isNotEmpty
          //                 ? '${apiClient.baseUrl}${ApiEndpoints.usersUploads}${player['imageFile']}'
          //                 : null,
          //           ),
          //         )
          //         .toList();
          //     return Column(
          //       children: [
          //         TeammatesSection(
          //             title: 'Enrolled Players',
          //             playerCount: filteredPlayers.length,
          //             teammates: enrolledDisplayList,
          //             maxVisibleTeammates: 6,
          //             showCheckIcon: false),
          //         SizedBox(height: AppResponsive.s(context, 16)),
          //       ],
          //     );
          //   },
          //   loading: () => Padding(
          //       padding: AppResponsive.padding(context, vertical: 20),
          //       child: Center(
          //           child: AppLoading.circular(color: AppColors.accentBlue))),
          //   error: (error, stack) => Padding(
          //     padding: AppResponsive.padding(context, vertical: 20),
          //     child: Center(
          //         child: Text('Failed to load enrolled players',
          //             style: TextStyle(
          //                 fontFamily: 'SFProRounded',
          //                 fontSize: AppResponsive.font(context, 14),
          //                 color: Colors.grey.shade600))),
          //   ),
          // ),
          // About Event
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'ABOUT EVENT'),
                SizedBox(height: AppResponsive.s(context, 10)),
                Text(registeredTournament.aboutEvent,
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
          // Scoring Structure
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionWithIconInline(
                    icon: AppAssets.trophyIcon,
                    iconColor: Color(0xFFFFF8E1),
                    title: 'SCORING STRUCTURE'),
                SizedBox(height: AppResponsive.s(context, 12)),
                Text(registeredTournament.scoringStructure,
                    style: TextStyle(
                        fontFamily: 'SFProRounded',
                        fontSize: AppResponsive.font(context, 14),
                        height: 1.5,
                        color: const Color(0xFF424242))),
              ],
            ),
          ),
          SizedBox(height: AppResponsive.s(context, 16)),
          // Equipment Required
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionWithIconInline(
                    icon: Icons.description_outlined,
                    iconColor: Color(0xFFE3F2FD),
                    title: 'EQUIPMENT REQUIRED'),
                SizedBox(height: AppResponsive.s(context, 12)),
                Text(registeredTournament.equipmentRequired,
                    style: TextStyle(
                        fontFamily: 'SFProRounded',
                        fontSize: AppResponsive.font(context, 14),
                        height: 1.5,
                        color: const Color(0xFF424242))),
              ],
            ),
          ),
          SizedBox(height: AppResponsive.s(context, 16)),
          // Rules & Regulations
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'RULES & REGULATIONS'),
                SizedBox(height: AppResponsive.s(context, 16)),
                ...registeredTournament.rules.map(
                  (rule) => Padding(
                    padding:
                        EdgeInsets.only(bottom: AppResponsive.s(context, 14)),
                    child: RuleItem(text: rule),
                  ),
                ),
              ],
            ),
          ),
          // Price Section
          if (!isInviteOnly) ...[
            SizedBox(height: AppResponsive.s(context, 16)),
            PriceSection(
                priceWithTax: registration.tournamentFeesAmount ?? 0,
                serviceFee: 0,
                totalAmount: registration.tournamentFeesAmount ?? 0,
                showBreakup: showPriceBreakup,
                onToggleBreakup: onTogglePriceBreakup),
          ],
        ],
      ),
    );
  }
}

class _TournamentInfoContainer extends StatelessWidget {
  const _TournamentInfoContainer({required this.registeredTournament});

  final RegisteredTournamentModel registeredTournament;

  @override
  Widget build(BuildContext context) {
    final progress = registeredTournament.maximumRegistrationsCount > 0
        ? registeredTournament.currentRegistered /
            registeredTournament.maximumRegistrationsCount
        : 0.0;

    return SectionCard(
      child: Column(
        children: [
          InfoRowWithIcon(
            icon: Icons.calendar_today_outlined,
            title: 'Registration Start Date & End Date',
            value:
                '${registeredTournament.registrationStartDate}  to  ${registeredTournament.registrationEndDate}',
          ),
          SizedBox(height: AppResponsive.s(context, 18)),
          _DetailInfoRowWithDetail(
            icon: Icons.calendar_today_outlined,
            title: 'Start Date & Time',
            subtitle: registeredTournament.startDate,
            detail:
                '${registeredTournament.startTime} - ${registeredTournament.endTime}',
          ),
          SizedBox(height: AppResponsive.s(context, 18)),
          _DetailInfoRowWithDetail(
              icon: Icons.location_on_outlined,
              title: 'Location',
              subtitle: registeredTournament.locationAddress),
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
                      '${registeredTournament.currentRegistered}/${registeredTournament.maximumRegistrationsCount} Players Registered',
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
class _RegisteredSponsorsSection extends ConsumerWidget {
  const _RegisteredSponsorsSection({
    required this.registeredTournament,
  });

  final RegisteredTournamentModel registeredTournament;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sponsorsData = registeredTournament.tournamentSponsorsList;

    if (kDebugMode) {
      print('👁️ [_RegisteredSponsorsSection] Building sponsors section');
      print('   Tournament: ${registeredTournament.event.title}');
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
