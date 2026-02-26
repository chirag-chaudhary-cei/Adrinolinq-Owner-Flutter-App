import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors_new.dart';
import '../../../../core/theme/app_responsive.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/global_app_bar.dart';
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
  });

  /// Raw player map from the enrolled-players API.
  final Map<String, dynamic> player;

  /// Tournament / event title shown in the app-bar.
  final String eventTitle;

  /// Sport name shown in the app-bar subtitle.
  final String eventSport;

  final int tournamentId;

  @override
  ConsumerState<PlayerBidPage> createState() => _PlayerBidPageState();
}

class _PlayerBidPageState extends ConsumerState<PlayerBidPage> {
  // ── Mock bid data — replace with real API when available. ──────────────
  int _currentBidPoints = 900;

  final List<BidModel> _previousBids = [
    const BidModel(
      points: 800,
      teamName: 'Team A',
      ownerName: 'Team A Owner Name',
      timestamp: '12:52:54\n21 Oct 2025',
    ),
    const BidModel(
      points: 700,
      teamName: 'Team B',
      ownerName: 'Team B Owner Name',
      timestamp: '12:52:54\n21 Oct 2025',
    ),
    const BidModel(
      points: 600,
      teamName: 'Team A',
      ownerName: 'Team A Owner Name',
      timestamp: '12:52:54\n21 Oct 2025',
    ),
  ];

  BidModel _currentBid = const BidModel(
    points: 900,
    teamName: 'Mumbai Indians',
    ownerName: 'Owner Name',
    timestamp: '12:52:54\n21 Oct 2025',
  );

  // ── Helpers ─────────────────────────────────────────────────────────────

  String _playerName() {
    final first = widget.player['firstName'] as String? ?? '';
    final last = widget.player['lastName'] as String? ?? '';
    final full = '$first $last'.trim();
    return full.isNotEmpty ? full : 'Unknown Player';
  }

  String _email() => (widget.player['email'] as String? ?? '');

  String _phone() => (widget.player['mobile'] as String? ??
      widget.player['phone'] as String? ??
      '');

  String _gender() => (widget.player['gender'] as String? ?? '').trim();

  String _age() {
    final age = widget.player['age'];
    if (age == null) return '';
    return 'Age : $age';
  }

  String _proficiency() => (widget.player['sportPreferenceLevel'] as String? ??
      widget.player['proficiency'] as String? ??
      widget.player['proficiencyLevel'] as String? ??
      '');

  String _winRate() {
    final wr = widget.player['winRate'] ?? widget.player['win_rate'];
    if (wr == null) return '—';
    return '$wr %';
  }

  String _totalMatches() {
    final tm = widget.player['totalMatches'] ?? widget.player['total_matches'];
    if (tm == null) return '—';
    return tm.toString();
  }

  String? _imageFile() => widget.player['imageFile'] as String?;

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final nextBid = _currentBidPoints + 100;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────────
            GlobalAppBar(
              title: widget.eventTitle,
              subtitle: widget.eventSport,
              showBackButton: true,
              showDivider: true,
              titleFontSize: AppResponsive.font(context, 18),
            ),

            // ── Scrollable body ───────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(
                  bottom: AppResponsive.s(context, 120),
                ),
                children: [
                  SizedBox(height: AppResponsive.s(context, 16)),

                  // ── Player profile card ──────────────────────────────────
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

                  SizedBox(height: AppResponsive.s(context, 20)),

                  // ── Current Bid ──────────────────────────────────────────
                  Padding(
                    padding:
                        AppResponsive.paddingSymmetric(context, horizontal: 20),
                    child: Text(
                      'Current Bid',
                      style: TextStyle(
                        fontFamily: 'SFProRounded',
                        fontSize: AppResponsive.font(context, 16),
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  SizedBox(height: AppResponsive.s(context, 10)),
                  Padding(
                    padding:
                        AppResponsive.paddingSymmetric(context, horizontal: 20),
                    child: CurrentBidCard(bid: _currentBid),
                  ),

                  SizedBox(height: AppResponsive.s(context, 20)),

                  // ── Previous Bids ────────────────────────────────────────
                  Padding(
                    padding:
                        AppResponsive.paddingSymmetric(context, horizontal: 20),
                    child: Text(
                      'Previous Bids',
                      style: TextStyle(
                        fontFamily: 'SFProRounded',
                        fontSize: AppResponsive.font(context, 16),
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  SizedBox(height: AppResponsive.s(context, 8)),
                  ..._previousBids.map((bid) => PreviousBidRow(bid: bid)),
                ],
              ),
            ),
          ],
        ),
      ),

      // ── Sticky "Place Bid" button ──────────────────────────────────────
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: AppResponsive.padding(context,
              horizontal: 20, vertical: 16, bottom: 16),
          child: AppButton(
            text: 'Place Bid  $nextBid PT',
            onPressed: _onPlaceBid,
            backgroundColor: AppColors.primary, // lime green
            textColor: Colors.black,
            width: double.infinity,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  void _onPlaceBid() {
    final nextBid = _currentBidPoints + 100;
    setState(() {
      _previousBids.insert(0, _currentBid);
      _currentBid = BidModel(
        points: nextBid,
        teamName: 'My Team',
        ownerName: 'You',
        timestamp: TimeOfDay.now().format(context),
      );
      _currentBidPoints = nextBid;
    });

    // Show confirmation snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Bid placed: $nextBid PT',
          style: const TextStyle(
            fontFamily: 'SFProRounded',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.accentBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: AppResponsive.padding(context, horizontal: 20, bottom: 16),
      ),
    );
  }
}
