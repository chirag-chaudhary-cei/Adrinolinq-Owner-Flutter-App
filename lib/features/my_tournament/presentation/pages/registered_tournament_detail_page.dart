import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  final ScrollController _yourDetailsScrollController = ScrollController();
  final ScrollController _tournamentDetailsScrollController =
      ScrollController();

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
        ? _yourDetailsScrollController
        : _tournamentDetailsScrollController;

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

  void _onYourDetailsScroll() {
    if (!_yourDetailsScrollController.hasClients) return;
    if (_tabController.index != 0) return;
    _updateHeaderOffset(_yourDetailsScrollController);
  }

  void _onTournamentDetailsScroll() {
    if (!_tournamentDetailsScrollController.hasClients) return;
    if (_tabController.index != 1) return;
    _updateHeaderOffset(_tournamentDetailsScrollController);
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
    _yourDetailsScrollController.addListener(_onYourDetailsScroll);
    _tournamentDetailsScrollController.addListener(_onTournamentDetailsScroll);

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
    _yourDetailsScrollController.removeListener(_onYourDetailsScroll);
    _yourDetailsScrollController.dispose();
    _tournamentDetailsScrollController
        .removeListener(_onTournamentDetailsScroll);
    _tournamentDetailsScrollController.dispose();
    super.dispose();
  }

  Widget _buildCollapsibleHeader(BuildContext context) {
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
      tabs: const ['Your Details', 'Tournament Details'],
    );
  }

  Widget _buildYourDetailsTabContent(
    BuildContext context,
    RegisteredTournamentModel registeredTournament,
  ) {
    return SingleChildScrollView(
      key: const PageStorageKey('your_details_scroll'),
      controller: _yourDetailsScrollController,
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.only(top: _expandedTotalHeight),
      child: Column(
        children: [
          _YourDetailsTab(
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
            tournamentId: widget.registration.tournamentId,
          ),
          SizedBox(height: AppResponsive.sh(context, 100)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tournamentAsync =
        ref.watch(tournamentByIdProvider(widget.registration.tournamentId));

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
                _buildYourDetailsTabContent(context, registeredTournament),
                _buildTournamentDetailsTabContent(
                    context, registeredTournament),
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
                _buildCollapsibleHeader(context),
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
                Consumer(
                  builder: (context, ref, child) {
                    final sportsAsync = ref.watch(sportsListProvider);
                    final sportName = sportsAsync.maybeWhen(
                      data: (sports) {
                        if (event.sportId != null) {
                          try {
                            for (final s in sports) {
                              if (s is Map<String, dynamic>) {
                                final id = s['sportsId'] ?? s['id'];
                                if (id == event.sportId)
                                  return (s['sportsName'] ??
                                      s['name'] ??
                                      event.category) as String;
                              } else {
                                try {
                                  final id = (s as dynamic).sportsId ??
                                      (s as dynamic).id;
                                  if (id == event.sportId)
                                    return ((s as dynamic).sportsName ??
                                        (s as dynamic).name ??
                                        event.category) as String;
                                } catch (_) {}
                              }
                            }
                          } catch (_) {}
                        }
                        return event.category;
                      },
                      orElse: () => event.category,
                    );
                    return Container(
                      padding: AppResponsive.paddingSymmetric(context,
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: AppResponsive.borderRadius(context, 16),
                      ),
                      child: Text(sportName,
                          style: TextStyle(
                              fontSize: AppResponsive.font(context, 12),
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    );
                  },
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

class _YourDetailsTab extends ConsumerWidget {
  const _YourDetailsTab({
    required this.registration,
    required this.tournamentId,
    required this.showPriceBreakup,
    required this.onTogglePriceBreakup,
    this.isInviteOnly = false,
  });

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
          enrolledPlayersAsync.when(
            data: (players) {
              final uniquePlayers = <String, Map<String, dynamic>>{};
              for (final player in players) {
                final id = player['id']?.toString() ?? '';
                if (id.isNotEmpty && !uniquePlayers.containsKey(id))
                  uniquePlayers[id] = player;
              }
              final filteredPlayers = uniquePlayers.values.toList();
              if (filteredPlayers.isEmpty) return const SizedBox.shrink();
              final enrolledDisplayList = filteredPlayers
                  .map(
                    (player) => TeammateDisplayModel(
                      id: player['id']?.toString() ?? '',
                      name: _constructPlayerName(player),
                      role: null,
                      avatarUrl: player['imageFile'] != null &&
                              player['imageFile'].toString().isNotEmpty
                          ? '${apiClient.baseUrl}${ApiEndpoints.usersUploads}${player['imageFile']}'
                          : null,
                    ),
                  )
                  .toList();
              return Column(
                children: [
                  TeammatesSection(
                      title: 'Enrolled Players',
                      playerCount: filteredPlayers.length,
                      teammates: enrolledDisplayList,
                      maxVisibleTeammates: 6,
                      showCheckIcon: false),
                  SizedBox(height: AppResponsive.s(context, 16)),
                ],
              );
            },
            loading: () => Padding(
                padding: AppResponsive.padding(context, vertical: 20),
                child: Center(
                    child: AppLoading.circular(color: AppColors.accentBlue))),
            error: (error, stack) => Padding(
              padding: AppResponsive.padding(context, vertical: 20),
              child: Center(
                  child: Text('Failed to load enrolled players',
                      style: TextStyle(
                          fontFamily: 'SFProRounded',
                          fontSize: AppResponsive.font(context, 14),
                          color: Colors.grey.shade600))),
            ),
          ),
          if (!isInviteOnly)
            PriceSection(
                priceWithTax: registration.tournamentFeesAmount ?? 0,
                serviceFee: 0,
                totalAmount: registration.tournamentFeesAmount ?? 0,
                showBreakup: showPriceBreakup,
                onToggleBreakup: onTogglePriceBreakup),
        ],
      ),
    );
  }
}

class _TournamentDetailsTab extends ConsumerWidget {
  const _TournamentDetailsTab(
      {required this.registeredTournament, required this.tournamentId});

  final RegisteredTournamentModel registeredTournament;
  final int tournamentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enrolledPlayersAsync =
        ref.watch(enrolledPlayersProvider(tournamentId));

    return enrolledPlayersAsync.when(
      data: (players) {
        return Padding(
          padding: AppResponsive.padding(context, horizontal: 20, top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TournamentInfoContainer(
                  registeredTournament: registeredTournament,
                  enrolledPlayersCount: players.length),
              SizedBox(height: AppResponsive.s(context, 20)),
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
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: 'RULES & REGULATIONS'),
                    SizedBox(height: AppResponsive.s(context, 16)),
                    ...registeredTournament.rules.map(
                      (rule) => Padding(
                        padding: EdgeInsets.only(
                            bottom: AppResponsive.s(context, 14)),
                        child: RuleItem(text: rule),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Padding(
          padding: AppResponsive.padding(context, horizontal: 20, top: 20),
          child: const Center(child: CircularProgressIndicator())),
      error: (error, stack) => Padding(
        padding: AppResponsive.padding(context, horizontal: 20, top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TournamentInfoContainer(
                registeredTournament: registeredTournament,
                enrolledPlayersCount:
                    registeredTournament.event.registeredCount),
            SizedBox(height: AppResponsive.s(context, 20)),
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
          ],
        ),
      ),
    );
  }
}

class _TournamentInfoContainer extends StatelessWidget {
  const _TournamentInfoContainer(
      {required this.registeredTournament, required this.enrolledPlayersCount});

  final RegisteredTournamentModel registeredTournament;
  final int enrolledPlayersCount;

  @override
  Widget build(BuildContext context) {
    final progress = registeredTournament.event.maxParticipants > 0
        ? enrolledPlayersCount / registeredTournament.event.maxParticipants
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
                      '$enrolledPlayersCount/${registeredTournament.event.maxParticipants} Players',
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
