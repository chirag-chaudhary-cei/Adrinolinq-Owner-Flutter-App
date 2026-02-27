import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors_new.dart';
import '../../../../core/theme/app_responsive.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/global_app_bar.dart';
import '../providers/my_tournament_providers.dart';
import '../widgets/bid_model.dart';
import '../widgets/current_bid_card.dart';
import '../widgets/player_profile_card.dart';
import '../widgets/previous_bid_row.dart';

// ─────────────────────────────────────────────
// Page
// ─────────────────────────────────────────────

/// Player bid/auction page (Owner App).
/// Shows player profile card + current bid + previous bids + place bid button.
/// Receives enrolled player data as [Map<String, dynamic>] from the
/// [ViewEnrolledPlayersPage] list.
class PlayerBidPage extends ConsumerStatefulWidget {
  const PlayerBidPage({
    super.key,
    this.player = const {},
    this.eventTitle = '',
    this.eventSport = '',
    this.tournamentId = 0,
    this.tournamentTeamId = 0,
  });

  /// Raw player map from the enrolled-players API.
  final Map<String, dynamic> player;

  /// Tournament / event title shown in the app-bar.
  final String eventTitle;

  /// Sport name shown in the app-bar subtitle.
  final String eventSport;

  final int tournamentId;

  /// The tournament team ID used to fetch auction bids for this player.
  final int tournamentTeamId;

  @override
  ConsumerState<PlayerBidPage> createState() => _PlayerBidPageState();
}

class _PlayerBidPageState extends ConsumerState<PlayerBidPage> {
  // ── Local bid state (populated from API, updated on place-bid) ──────────
  bool _bidsInitialized = false;
  int? _currentBidPoints = 0;
  int _baseBid = 0;
  int _bidGap = 0; // Default bid gap
  List<BidModel> _previousBids = [];
  BidModel? _currentBid;
  Map<String, dynamic>? _auctionItem;

  // ── Local player state ──────────────────────────────────────────────────
  late Map<String, dynamic> _player;

  @override
  void initState() {
    super.initState();
    _player = Map.from(widget.player); // Copy the initial player data
  }

  // ── Map a raw API bid map → BidModel ────────────────────────────────────
  BidModel _mapBid(Map<String, dynamic> raw) {
    final points = (raw['points'] ?? 0) as int;
    final teamName = 'Team ${raw['tournamentTeamId'] ?? 'Unknown'}';
    final ownerName = 'Owner ${raw['createdById'] ?? 'Unknown'}';
    final ts = (raw['creationTimestamp'] ?? '') as String;
    return BidModel(
      points: points,
      teamName: teamName,
      ownerName: ownerName,
      timestamp: ts,
    );
  }

void _initBidsFromApi(List<Map<String, dynamic>> rawAuctionItems) {
  if (_bidsInitialized) return;

  // Match auction item by playerUserId (user ID) OR tournamentRegistrationId
  final playerId = _player['id'] ?? _player['playerUserId'];
  final registrationId = _player['tournamentRegistrationId'];

  print(
      'Initializing bids for playerId: $playerId, registrationId: $registrationId');
  if (rawAuctionItems.isEmpty) {
    setState(() => _bidsInitialized = true);
    return;
  }

  final auctionItem = rawAuctionItems.first;
  print('Received auction item: $auctionItem');

    // Store auction item for saving (id = playerAuctionId)
    _auctionItem = auctionItem;

    // Fetch user details in background using playerUserId from auction item
    final playerUserId = auctionItem['playerUserId'] as int?;
    if (playerUserId != null) {
      ref.read(userDetailsProvider(playerUserId).future).then((userDetails) {
        if (mounted) {
          setState(() => _player = Map.from(userDetails));
        }
      }).catchError((e) {
        if (kDebugMode) print('Failed to fetch user details: $e');
      });
    }

    // Get the bids list from the auction item
    final playerAuctionBidsList =
        (auctionItem['playerAuctionBidsList'] as List<dynamic>? ?? [])
            .map((e) => e as Map<String, dynamic>)
            .toList();
    // if (auctionItem['points'] == null) {
    setState(() {
      _bidsInitialized = true;

      _currentBidPoints = auctionItem['points'];

      _baseBid = auctionItem['baseBid'];

      _bidGap = auctionItem['bidGap'];
    });
    return;
    // }

    // Sort bids by id descending (highest id = most recent)
    playerAuctionBidsList
        .sort((a, b) => (b['id'] as int? ?? 0).compareTo(a['id'] as int? ?? 0));

    final allBids = playerAuctionBidsList.map(_mapBid).toList();

    setState(() {
      _bidsInitialized = true;
      _currentBid = allBids.first;
      _currentBidPoints = allBids.first.points;
      _bidGap = auctionItem['bidGap'] as int? ?? 10;
      _previousBids = allBids.length > 1 ? allBids.sublist(1) : [];
    });
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  String _playerName() {
    final first = _player['firstName'] as String? ?? '';
    final last = _player['lastName'] as String? ?? '';
    final full = '$first $last'.trim();
    return full.isNotEmpty ? full : 'Serena Pretty';
  }

  String _email() => (_player['email'] as String? ?? 'serenapretty@gmail.com');

  String _phone() => (_player['mobile'] as String? ??
      _player['phone'] as String? ??
      'XXXXX XXXXX');

  String _gender() {
    final g = (_player['gender'] as String? ?? '').trim();
    return g.isNotEmpty ? g : 'Male';
  }

  String _age() {
    final age = _player['age'];
    if (age == null) return 'Age : 25';
    return 'Age : $age';
  }

  String _proficiency() => (_player['sportPreferenceLevel'] as String? ??
      _player['proficiency'] as String? ??
      _player['proficiencyLevel'] as String? ??
      'Expert');

  String _winRate() {
    final wr = _player['winRate'] ?? _player['win_rate'];
    if (wr == null) return '67 %';
    return '$wr %';
  }

  String _totalMatches() {
    final tm = _player['totalMatches'] ?? _player['total_matches'];
    if (tm == null) return '675';
    return tm.toString();
  }

  String? _imageFile() => _player['imageFile'] as String?;

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _onRefresh() async {
    setState(() {
      _bidsInitialized = false;
      _currentBid = null;
      _previousBids = [];
      _currentBidPoints = 0;
      _bidGap = 100;
      _auctionItem = null;
    });
    await ref.refresh(
      playerAuctionBidsProvider(widget.tournamentId).future,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bidsAsync = ref.watch(
      playerAuctionBidsProvider(widget.tournamentId),
    );

    // Initialise local bid state once data arrives
    bidsAsync.whenData((rawBids) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _initBidsFromApi(rawBids);
      });
    });

    // No bids → button shows baseBid; bids exist → currentBid + bidGap
    final nextBid =
        _currentBidPoints == 0 ? _baseBid : _currentBidPoints! + _bidGap;
    print("nextBid: $nextBid");
    print(
        "_currentBidPoints: $_currentBidPoints, _baseBid: $_baseBid, _bidGap: $_bidGap");

    // Show full-screen loader until data AND local state are both ready
    final isLoading =
        bidsAsync.isLoading || (!_bidsInitialized && !bidsAsync.hasError);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // ── Header ────────────────────────────────────────────────────
                GlobalAppBar(
                  title: widget.eventTitle.isNotEmpty
                      ? widget.eventTitle
                      : 'Elite Badminton Championship',
                  subtitle: widget.eventSport.isNotEmpty
                      ? widget.eventSport
                      : 'Football',
                  showBackButton: true,
                  showDivider: true,
                  titleFontSize: AppResponsive.font(context, 18),
                ),

                // ── Scrollable body ───────────────────────────────────────────
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : bidsAsync.hasError
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  'Failed to load bids.\n${bidsAsync.error}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: 'SFProRounded',
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _onRefresh,
                              color: AppColors.accentBlue,
                              child: ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: EdgeInsets.only(
                                  bottom: AppResponsive.s(context, 120),
                                ),
                                children: [
                                  SizedBox(
                                      height: AppResponsive.s(context, 16)),

                                  // ── Player profile card ────────────────────────
                                  PlayerProfileCard(
                                    playerName: _playerName(),
                                    email: _email(),
                                    phone: _phone(),
                                    gender: _gender(),
                                    age: _age(),
                                    proficiency: _proficiency(),
                                    winRate: _winRate(),
                                    totalMatches: _totalMatches(),
                                    imageFile: _imageFile(),
                                  ),
                                  SizedBox(
                                      height: AppResponsive.s(context, 20)),

                                  // ── No bids empty state ────────────────────────
                                  if (_currentBid == null &&
                                      _previousBids.isEmpty) ...[
                                    SizedBox(
                                        height: AppResponsive.s(context, 40)),
                                    Icon(
                                      Icons.gavel_rounded,
                                      size: AppResponsive.s(context, 56),
                                      color: const Color(0xFF1A1A1A)
                                          .withOpacity(0.15),
                                    ),
                                    SizedBox(
                                        height: AppResponsive.s(context, 16)),
                                    Center(
                                      child: Text(
                                        'No Bids Yet',
                                        style: TextStyle(
                                          fontFamily: 'SFProRounded',
                                          fontSize:
                                              AppResponsive.font(context, 16),
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF1A1A1A)
                                              .withOpacity(0.45),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                        height: AppResponsive.s(context, 8)),
                                    Center(
                                      child: Text(
                                        'No auction bids have been\nplaced for this player yet.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'SFProRounded',
                                          fontSize:
                                              AppResponsive.font(context, 13),
                                          fontWeight: FontWeight.w400,
                                          color: const Color(0xFF1A1A1A)
                                              .withOpacity(0.35),
                                        ),
                                      ),
                                    ),
                                  ],

                                  // ── Current Bid ────────────────────────────────
                                  if (_currentBid != null) ...[
                                    Padding(
                                      padding: AppResponsive.paddingSymmetric(
                                          context,
                                          horizontal: 20),
                                      child: Text(
                                        'Current Bid',
                                        style: TextStyle(
                                          fontFamily: 'SFProRounded',
                                          fontSize:
                                              AppResponsive.font(context, 16),
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF1A1A1A),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                        height: AppResponsive.s(context, 10)),
                                    Padding(
                                      padding: AppResponsive.paddingSymmetric(
                                          context,
                                          horizontal: 20),
                                      child: CurrentBidCard(bid: _currentBid!),
                                    ),
                                    SizedBox(
                                        height: AppResponsive.s(context, 20)),
                                  ],

                                  // ── Previous Bids ──────────────────────────────
                                  if (_previousBids.isNotEmpty) ...[
                                    Padding(
                                      padding: AppResponsive.paddingSymmetric(
                                          context,
                                          horizontal: 20),
                                      child: Text(
                                        'Previous Bids',
                                        style: TextStyle(
                                          fontFamily: 'SFProRounded',
                                          fontSize:
                                              AppResponsive.font(context, 16),
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF1A1A1A),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                        height: AppResponsive.s(context, 8)),
                                    ..._previousBids
                                        .map((bid) => PreviousBidRow(bid: bid)),
                                  ],
                                ],
                              ),
                            ),
                ),
              ],
            ),

            // ── Sticky "Place Bid" button with gradient ────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: Colors.transparent,
                padding: AppResponsive.padding(
                  context,
                  horizontal: 20,
                  top: 24,
                  bottom: 16,
                ),
                child: AppButton(
                  text: 'Place Bid  $nextBid PT',
                  onPressed: (_bidsInitialized && _auctionItem != null)
                      ? _onPlaceBid
                      : null,
                  backgroundColor: AppColors.primary,
                  textColor: Colors.black,
                  width: double.infinity,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onPlaceBid() async {
    // if (_rawPlayerBids.isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('No auction data available'),
    //       backgroundColor: Colors.red,
    //     ),
    //   );
    //   return;
    // }

    // First bid = baseBid; subsequent bids = currentBid + bidGap
    final buttonAmount =
        _currentBidPoints == 0 ? _baseBid : _currentBidPoints! + _bidGap;
    final playerAuctionId = _auctionItem!['id'] as int;

    // Optimistic update
    setState(() {
      if (_currentBid != null) {
        _previousBids.insert(0, _currentBid!);
      }
      _currentBid = BidModel(
        points: buttonAmount,
        teamName: 'My Team',
        ownerName: 'You',
        timestamp: TimeOfDay.now().format(context),
      );
      _currentBidPoints = buttonAmount;
    });

    try {
      await ref.read(
        savePlayerAuctionBidProvider((
          playerAuctionId: playerAuctionId,
          points: buttonAmount,
          tournamentTeamId: widget.tournamentTeamId
        )).future,
      );

      // Show confirmation snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Bid placed: $buttonAmount PT',
            style: const TextStyle(
              fontFamily: 'SFProRounded',
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: AppColors.accentBlue,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: AppResponsive.padding(context, horizontal: 20, bottom: 16),
        ),
      );
    } catch (e) {
      // Revert optimistic update on error
      setState(() {
        _currentBid =
            _previousBids.isNotEmpty ? _previousBids.removeAt(0) : null;
        _currentBidPoints = _currentBid?.points ?? 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to place bid: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: AppResponsive.padding(context, horizontal: 20, bottom: 16),
        ),
      );
    }
  }
}
