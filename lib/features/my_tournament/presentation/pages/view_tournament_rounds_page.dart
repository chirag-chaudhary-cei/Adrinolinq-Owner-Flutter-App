import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors_new.dart';
import '../../../../core/theme/app_responsive.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/routing/app_router.dart';
import '../../../home/data/models/tournament_model.dart';
import '../../../home/presentation/providers/tournaments_providers.dart';
import '../../../../core/widgets/event_card.dart';

/// Dotted border painter
class _DottedBorderPainter extends CustomPainter {
  _DottedBorderPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.gap = 6.0,
    this.dash = 6.0,
    this.radius = 12.0,
  });
  final Color color;
  final double strokeWidth;
  final double gap;
  final double dash;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    final PathMetrics metrics = path.computeMetrics();
    for (final PathMetric metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final len = (distance + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, len), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DottedBorderPainter oldDelegate) => false;
}

/// View-only page for displaying tournament rounds structure
class ViewTournamentRoundsPage extends ConsumerStatefulWidget {
  const ViewTournamentRoundsPage({
    super.key,
    required this.tournamentId,
    required this.event,
  });

  final int tournamentId;
  final EventModel event;

  @override
  ConsumerState<ViewTournamentRoundsPage> createState() =>
      _ViewTournamentRoundsPageState();
}

class _ViewTournamentRoundsPageState
    extends ConsumerState<ViewTournamentRoundsPage> {
  int _selectedRoundIndex = 0;
  TournamentModel? _tournamentDetails;
  bool _isLoading = true;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _fetchTournamentDetails();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchTournamentDetails() async {
    try {
      final dataSource = ref.read(tournamentsRemoteDataSourceProvider);
      final details = await dataSource.getTournamentById(widget.tournamentId);
      if (mounted) {
        setState(() {
          _tournamentDetails = details;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _parseRoundsData() {
    final rounds = _tournamentDetails?.tournamentRoundsList;
    if (rounds == null || rounds.isEmpty) return [];

    List<Map<String, dynamic>> parsedRounds = [];

    for (int i = 0; i < rounds.length; i++) {
      final round = rounds[i];
      final title = round['title'] ?? 'Round ${i + 1}';
      final groups = round['tournamentRoundGroupsList'] as List? ?? [];
      final numberOfGroups = groups.length;

      int teamsInRound = 0;
      if (numberOfGroups > 0) {
        for (var group in groups) {
          final teamSlots =
              group['tournamentRoundGroupTeamsList'] as List? ?? [];
          teamsInRound += teamSlots.length;
        }
        if (teamsInRound == 0) {
          int totalMatchTeams = 0;
          int firstGroupMatchCount = 0;
          for (int gi = 0; gi < groups.length; gi++) {
            final matches =
                groups[gi]['tournamentRoundMatchesList'] as List? ?? [];
            totalMatchTeams += matches.length * 2;
            if (gi == 0) firstGroupMatchCount = matches.length;
          }
          if (firstGroupMatchCount > 0) {
            teamsInRound = totalMatchTeams ~/ firstGroupMatchCount;
          }
          if (teamsInRound == 0) {
            teamsInRound = numberOfGroups * 4;
          }
        }
      } else {
        if (title.toLowerCase().contains('final') &&
            !title.toLowerCase().contains('semi')) {
          teamsInRound = 2;
        } else if (title.toLowerCase().contains('semi')) {
          teamsInRound = 4;
        } else {
          teamsInRound = 8;
        }
      }

      parsedRounds.add({
        'title': title,
        'numberOfGroups': numberOfGroups,
        'teamsInRound': teamsInRound,
        'groups': groups,
        'roundIndex': i,
        'roundId': round['id'],
        'isGroupStage': numberOfGroups > 0,
      });
    }

    return parsedRounds;
  }

  @override
  Widget build(BuildContext context) {
    final rounds = _parseRoundsData();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(AppResponsive.s(context, 84)),
        child: const SafeArea(
          bottom: false,
          child: AppHeader(
            title: 'Tournament Rounds',
            showBackButton: true,
            iconColor: Colors.black,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accentBlue),
            )
          : rounds.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No rounds configured yet',
                          style: TextStyle(
                            fontFamily: 'SFProRounded',
                            fontSize: AppResponsive.font(context, 16),
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRoundTabs(rounds),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) =>
                            setState(() => _selectedRoundIndex = index),
                        itemCount: rounds.length,
                        itemBuilder: (context, index) {
                          return SingleChildScrollView(
                            padding: EdgeInsets.fromLTRB(
                              AppResponsive.p(context, 20),
                              AppResponsive.p(context, 16),
                              AppResponsive.p(context, 20),
                              AppResponsive.p(context, 32) +
                                  MediaQuery.of(context).padding.bottom,
                            ),
                            child: Column(
                              children: [
                                _buildRoundContent(rounds[index]),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildRoundTabs(List<Map<String, dynamic>> rounds) {
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(
        horizontal: AppResponsive.p(context, 20),
        vertical: AppResponsive.p(context, 16),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(rounds.length, (index) {
            final isSelected = index == _selectedRoundIndex;
            return Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedRoundIndex = index);
                  _pageController.jumpToPage(index);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.accentBlue
                        : const Color(0xFFE0E4E7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    rounds[index]['title'] as String,
                    style: TextStyle(
                      color:
                          isSelected ? Colors.white : const Color(0xFF000000),
                      fontWeight: FontWeight.w600,
                      fontSize: AppResponsive.font(context, 12),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildRoundContent(Map<String, dynamic> round) {
    final title = round['title'] as String;
    final isGroupStage = round['isGroupStage'] as bool;
    final numberOfGroups = round['numberOfGroups'] as int;
    final teamsInRound = round['teamsInRound'] as int;
    final groups = round['groups'] as List;

    final isWinner = title.toLowerCase() == 'winner';
    final isFinal = title.toLowerCase() == 'final';
    final isSemiFinal = title.toLowerCase().contains('semi');

    if (isWinner) return _buildWinnerContent(title);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRoundColumn(
          title: title,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isGroupStage
                      ? 'League Round'
                      : (isSemiFinal
                          ? 'Semi Final Round'
                          : (isFinal ? 'Final Round' : 'Knockout Round')),
                  style: TextStyle(
                    color: AppColors.accentBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: AppResponsive.font(context, 12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (!isGroupStage && teamsInRound > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    '$teamsInRound Teams → ${(teamsInRound ~/ 2).clamp(1, teamsInRound)} '
                    '${isFinal ? 'Winner' : 'Teams advance'}',
                    style: TextStyle(
                      color: AppColors.accentBlue,
                      fontSize: AppResponsive.font(context, 12),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (isGroupStage && groups.isNotEmpty)
                ...List.generate(groups.length, (gi) {
                  final group = groups[gi] as Map<String, dynamic>;
                  final groupName = group['title'] as String? ??
                      'Group ${String.fromCharCode(65 + gi)}';
                  final teamSlots =
                      group['tournamentRoundGroupTeamsList'] as List? ?? [];
                  final teamsPerGroup =
                      numberOfGroups > 0 ? teamsInRound ~/ numberOfGroups : 0;
                  return _buildGroupCard(
                    groupName: groupName,
                    teamCount:
                        teamSlots.isNotEmpty ? teamSlots.length : teamsPerGroup,
                    teamSlots: teamSlots,
                  );
                }),
              if (!isGroupStage && teamsInRound > 0)
                ...List.generate((teamsInRound ~/ 2).clamp(1, teamsInRound),
                    (m) {
                  return _buildGroupCard(
                    groupName: 'Match ${m + 1}',
                    teamCount: 2,
                    isKnockout: true,
                  );
                }),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppButton(
          text: 'View Matches',
          onPressed: () {
            Navigator.pushNamed(
              context,
              AppRouter.matchDetails,
              arguments: widget.event,
            );
          },
          isOutlined: true,
          leadingIcon: Icons.sports_soccer,
          borderColor: AppColors.accentBlue,
          textColor: AppColors.accentBlue,
          width: double.infinity,
        ),
      ],
    );
  }

  Widget _buildWinnerContent(String title) {
    return _buildRoundColumn(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFCDFE00),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events, color: Colors.black, size: 32),
                const SizedBox(width: 12),
                Text(
                  'Winner: 1 Team',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: AppResponsive.font(context, 18),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'The champion will be decided!',
            style: TextStyle(
              color: const Color(0xFF6F6F6F),
              fontSize: AppResponsive.font(context, 14),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildRoundColumn({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE0E4E7)),
                ),
                child: Icon(
                  Icons.emoji_events_outlined,
                  size: 16,
                  color: AppColors.accentBlue,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: AppResponsive.font(context, 16),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF212121),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        CustomPaint(
          painter: _DottedBorderPainter(
            color: const Color(0xFF212121),
            strokeWidth: 1.0,
            gap: 6.0,
            dash: 6.0,
            radius: 12.0,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ],
    );
  }

  Widget _buildGroupCard({
    required String groupName,
    required int teamCount,
    bool isKnockout = false,
    List teamSlots = const [],
  }) {
    final String countLabel = isKnockout ? 'Team vs Team' : '$teamCount teams';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE0E4E7).withOpacity(0.5)),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    groupName,
                    style: TextStyle(
                      color: AppColors.accentBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: AppResponsive.font(context, 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFD3DBE2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Team No.',
                      style: TextStyle(
                        color: const Color(0xFF212121),
                        fontWeight: FontWeight.w500,
                        fontSize: AppResponsive.font(context, 14),
                      ),
                    ),
                    Text(
                      countLabel,
                      style: TextStyle(
                        color: const Color(0xFF212121),
                        fontWeight: FontWeight.w600,
                        fontSize: AppResponsive.font(context, 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!isKnockout)
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => _showGroupInfoBottomSheet(
                  groupName: groupName,
                  teamCount: teamCount,
                  teamSlots: teamSlots.cast<Map<String, dynamic>>().toList(),
                ),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFE0E4E7).withOpacity(0.6),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Color(0xFF6F6F6F),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showGroupInfoBottomSheet({
    required String groupName,
    required int teamCount,
    required List<Map<String, dynamic>> teamSlots,
  }) {
    final sorted = [...teamSlots]..sort((a, b) =>
        (a['positionNo'] as int? ?? 0).compareTo(b['positionNo'] as int? ?? 0));

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.65,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            SizedBox(height: AppResponsive.p(context, 16)),
            Center(
              child: Container(
                width: AppResponsive.p(context, 70),
                height: AppResponsive.p(context, 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF929292),
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
            SizedBox(height: AppResponsive.p(context, 8)),
            Text(
              groupName,
              style: TextStyle(
                fontSize: AppResponsive.font(context, 20),
                fontWeight: FontWeight.w600,
                color: AppColors.accentBlue,
              ),
            ),
            SizedBox(height: AppResponsive.p(context, 24)),
            Expanded(
              child: sorted.isNotEmpty
                  ? ListView.builder(
                      padding: EdgeInsets.symmetric(
                          horizontal: AppResponsive.p(context, 24)),
                      itemCount: sorted.length,
                      itemBuilder: (ctx, i) {
                        final slot = sorted[i];
                        final teamId =
                            slot['tournamentTeamId']?.toString() ?? '–';
                        final teamName = slot['tournamentTeam']?.toString() ??
                            'Team $teamId';
                        final pos = slot['positionNo'] as int? ?? (i + 1);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD3DBE2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    teamName,
                                    style: TextStyle(
                                      fontSize: AppResponsive.font(context, 16),
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Position: $pos',
                                    style: TextStyle(
                                      fontSize: AppResponsive.font(context, 12),
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF6F6F6F),
                                    ),
                                  ),
                                ],
                              ),
                              const Icon(Icons.keyboard_arrow_down,
                                  color: Color(0xFF6F6F6F)),
                            ],
                          ),
                        );
                      },
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(
                          horizontal: AppResponsive.p(context, 24)),
                      itemCount: teamCount,
                      itemBuilder: (ctx, i) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD3DBE2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Team ${i + 1}',
                                  style: TextStyle(
                                    fontSize: AppResponsive.font(context, 16),
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Slot ${i + 1}',
                                  style: TextStyle(
                                    fontSize: AppResponsive.font(context, 12),
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF6F6F6F),
                                  ),
                                ),
                              ],
                            ),
                            const Icon(Icons.keyboard_arrow_down,
                                color: Color(0xFF6F6F6F)),
                          ],
                        ),
                      ),
                    ),
            ),
            SizedBox(height: AppResponsive.p(context, 16)),
          ],
        ),
      ),
    );
  }
}
