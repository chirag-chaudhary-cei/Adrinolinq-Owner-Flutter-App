import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors_new.dart';
import '../../../../core/theme/app_responsive.dart';
import '../../../../core/widgets/global_app_bar.dart';
import '../../../../core/widgets/event_card.dart';
import '../../../../core/widgets/match_card.dart';
import '../../../../core/routing/app_router.dart';
import '../../../home/presentation/providers/tournaments_providers.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../auth/presentation/providers/onboarding_providers.dart';

class PlayerModel {
  final String id;
  final String name;
  final String role;
  final String skillLevel;
  final String? avatarUrl;
  final String? email;

  const PlayerModel(
      {required this.id,
      required this.name,
      required this.role,
      this.skillLevel = '',
      this.avatarUrl,
      this.email});

  factory PlayerModel.fromApiJson(Map<String, dynamic> json) {
    final firstName = json['firstName'] as String? ?? '';
    final lastName = json['lastName'] as String? ?? '';
    final fullName = '$firstName $lastName'.trim();
    // API may return proficiency as 'proficiencyLevel' or 'proficiency'
    final skillLevel = json['proficiencyLevel'] as String? ??
        json['proficiency'] as String? ??
        '';
    return PlayerModel(
      id: (json['id'] ?? json['userId'] ?? 0).toString(),
      name: fullName.isNotEmpty ? fullName : 'Unknown User',
      role: 'Player',
      skillLevel: skillLevel,
      avatarUrl: json['imageFile'] as String?,
      email: json['email'] as String?,
    );
  }
}

class LiveMatchModel {
  final String id;
  final String setNumber;
  final String team1Name;
  final String team1Section;
  final String? team1AvatarUrl;
  final int team1Score;
  final String team2Name;
  final String team2Section;
  final String? team2AvatarUrl;
  final int team2Score;
  final bool isLive;
  final List<MatchStatistic> statistics;
  final List<PlayerModel> team1Players;
  final List<PlayerModel> team2Players;

  const LiveMatchModel({
    required this.id,
    required this.setNumber,
    required this.team1Name,
    required this.team1Section,
    this.team1AvatarUrl,
    required this.team1Score,
    required this.team2Name,
    required this.team2Section,
    this.team2AvatarUrl,
    required this.team2Score,
    this.isLive = false,
    this.statistics = const [],
    this.team1Players = const [],
    this.team2Players = const [],
  });
}

class MatchStatistic {
  final String name;
  final String team1Value;
  final String team2Value;
  const MatchStatistic(
      {required this.name, required this.team1Value, required this.team2Value});
}

class LiveMatchScreen extends ConsumerStatefulWidget {
  const LiveMatchScreen({super.key, required this.event});
  final EventModel event;

  @override
  ConsumerState<LiveMatchScreen> createState() => _LiveMatchScreenState();
}

class _LiveMatchScreenState extends ConsumerState<LiveMatchScreen> {
  int _selectedTabIndex = 0;
  int _selectedTeamTab = 0;
  late LiveMatchModel _liveMatch;
  List<PlayerModel> _apiPlayers = [];
  bool _isLoadingPlayers = false;
  String? _currentUserId;

  final List<String> _tabs = ['OVERVIEW', 'ROUND', 'PLAYERS', 'OTHER MATCHES'];

  @override
  void initState() {
    super.initState();
    _initializeMockData();
    _fetchPlayersFromApi();
  }

  Future<void> _fetchPlayersFromApi() async {
    setState(() => _isLoadingPlayers = true);
    try {
      final dataSource = ref.read(tournamentsRemoteDataSourceProvider);
      final onboardingRepo = ref.read(onboardingRepositoryProvider);
      final profileRepo = ref.read(profileRepositoryProvider);

      // ── Step 1: Parallel – users list + proficiency levels + current profile
      final step1 = await Future.wait([
        dataSource.getUsersList(deleted: false, status: true, roleId: 4),
        ref.read(proficiencyLevelsProvider.future),
        profileRepo.getProfile(),
      ]);

      final users = step1[0] as List<Map<String, dynamic>>;
      final proficiencyLevels = step1[1] as List<dynamic>;
      final currentProfile = step1[2] as dynamic;

      final currentUserId = currentProfile.id.toString();
      _currentUserId = currentUserId;

      // Helper: resolve integer levelId → display name
      String levelNameById(int? levelId) {
        if (levelId == null || levelId == 0) return '';
        try {
          final match =
              proficiencyLevels.firstWhere((l) => (l as dynamic).id == levelId);
          return (match as dynamic).name as String? ?? '';
        } catch (_) {
          return '';
        }
      }

      // ── Step 2: Extract ordered user IDs (parallel index = prefs index)
      final userIds = users
          .map((u) =>
              int.tryParse((u['id'] ?? u['userId'] ?? 0).toString()) ?? 0)
          .toList();

      // ── Step 3: Fetch sports preferences for EVERY user in parallel
      //    Each future is at the same index as the user in [users]
      final prefsFutures = userIds.map((uid) async {
        if (uid <= 0) return <Map<String, dynamic>>[];
        try {
          return await onboardingRepo.getPlayerSportsPreferencesList(
              playerUserId: uid);
        } catch (_) {
          return <Map<String, dynamic>>[];
        }
      }).toList(); // .toList() materialises eager – avoids lazy-eval issues

      final allPrefs = await Future.wait(prefsFutures);

      // ── Step 4: Resolve skill level for a user by its index in [users]
      final sportId = widget.event.sportId;

      String resolveSkillForIndex(int index) {
        if (index < 0 || index >= allPrefs.length) return '';
        final prefs = allPrefs[index];
        if (prefs.isEmpty) return '';
        final matched = sportId != null
            ? prefs.firstWhere(
                (p) => p['sportId'] == sportId,
                orElse: () => prefs.first,
              )
            : prefs.first;
        return levelNameById(matched['levelId'] as int?);
      }

      // ── Step 5: Build PlayerModel list
      final players = List.generate(users.length, (i) {
        final json = users[i];
        final rawName =
            '${json['firstName'] ?? ''} ${json['lastName'] ?? ''}'.trim();
        return PlayerModel(
          id: userIds[i].toString(),
          name: rawName.isNotEmpty ? rawName : 'Unknown User',
          role: 'Player',
          skillLevel: resolveSkillForIndex(i),
          avatarUrl: json['imageFile'] as String?,
          email: json['email'] as String?,
        );
      });

      // ── Step 6: Replace / insert current user entry with profile data
      final currentUserIdInt = int.tryParse(currentUserId) ?? 0;
      final currentUserIndex = userIds.indexOf(currentUserIdInt);
      final currentUserSkillLevel = resolveSkillForIndex(currentUserIndex);

      final currentUserPlayer = PlayerModel(
        id: currentUserId,
        name:
            '${currentProfile.firstName ?? ''} ${currentProfile.lastName ?? ''}'
                .trim(),
        role: 'Player',
        skillLevel: currentUserSkillLevel,
        avatarUrl: currentProfile.imageFile as String?,
        email: currentProfile.email as String?,
      );

      final existingIndex = players.indexWhere((p) => p.id == currentUserId);
      if (existingIndex >= 0) {
        players[existingIndex] = currentUserPlayer;
      } else {
        players.insert(0, currentUserPlayer);
      }

      if (mounted)
        setState(() {
          _apiPlayers = players;
          _isLoadingPlayers = false;
        });
    } catch (e) {
      print('❌ [LiveMatchScreen] Error fetching players: $e');
      if (mounted) setState(() => _isLoadingPlayers = false);
    }
  }

  void _initializeMockData() {
    _liveMatch = const LiveMatchModel(
      id: '1',
      setNumber: 'Set - 3',
      team1Name: 'Man Utd',
      team1Section: 'Section A',
      team1Score: 1,
      team2Name: 'Chelsea',
      team2Section: 'Section B',
      team2Score: 1,
      isLive: true,
      statistics: [
        MatchStatistic(name: 'Shots', team1Value: '6', team2Value: '6'),
        MatchStatistic(
            name: 'Shots on Target', team1Value: '7', team2Value: '4'),
        MatchStatistic(name: 'Corners', team1Value: '5', team2Value: '5'),
        MatchStatistic(
            name: 'Fouls Commited', team1Value: '6', team2Value: '8'),
        MatchStatistic(name: 'Offsides', team1Value: '4', team2Value: '7'),
        MatchStatistic(
            name: 'Ball Possession', team1Value: '65%', team2Value: '35%'),
        MatchStatistic(name: 'Yellow Card', team1Value: '3', team2Value: '4'),
        MatchStatistic(name: 'Red Card', team1Value: '0', team2Value: '1'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light));
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            GlobalAppBar(
                title: widget.event.title,
                titleFontSize: AppResponsive.s(context, 20),
                subtitle: widget.event.category,
                subtitleFontSize: AppResponsive.s(context, 16),
                showBackButton: true,
                showDivider: true),
            _BannerImage(imageUrl: widget.event.imageUrl),
            _TabNavigation(
                tabs: _tabs,
                selectedIndex: _selectedTabIndex,
                onTabSelected: (index) {
                  setState(() {
                    _selectedTabIndex = index;
                  });
                }),
            Expanded(child: _buildTabContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _ScoreboardTab(liveMatch: _liveMatch);
      case 1:
        return _OverviewTab(liveMatch: _liveMatch);
      case 2:
        return _PlayersTab(
          liveMatch: _liveMatch,
          selectedTeamTab: _selectedTeamTab,
          onTeamTabChanged: (index) {
            setState(() {
              _selectedTeamTab = index;
            });
          },
          apiPlayers: _apiPlayers,
          isLoadingPlayers: _isLoadingPlayers,
          currentUserId: _currentUserId,
        );
      case 3:
        return _OtherMatchesTab();
      default:
        return const SizedBox.shrink();
    }
  }
}

class _BannerImage extends StatelessWidget {
  const _BannerImage({required this.imageUrl});
  final String imageUrl;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppResponsive.padding(context, horizontal: 20, top: 8),
      height: AppResponsive.sh(context, 180),
      decoration: BoxDecoration(
          borderRadius: AppResponsive.borderRadius(context, 46),
          color: const Color(0xFF1A3A3A)),
      child: ClipRRect(
        borderRadius: AppResponsive.borderRadius(context, 16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            imageUrl.startsWith('http')
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                        color: const Color(0xFF1A3A3A),
                        child: Icon(Icons.image_not_supported,
                            color: Colors.white54,
                            size: AppResponsive.icon(context, 48))),
                  )
                : Image.asset(imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: const Color(0xFF1A3A3A))),
            Center(
              child: Container(
                width: AppResponsive.s(context, 48),
                height: AppResponsive.s(context, 48),
                decoration: BoxDecoration(
                    color: const Color(0xFF9ACD32).withOpacity(0.9),
                    shape: BoxShape.circle),
                child: Icon(Icons.play_arrow,
                    color: Colors.white, size: AppResponsive.icon(context, 28)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabNavigation extends StatelessWidget {
  const _TabNavigation(
      {required this.tabs,
      required this.selectedIndex,
      required this.onTabSelected});
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          AppResponsive.padding(context, horizontal: 20, top: 16, bottom: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: tabs.asMap().entries.map((entry) {
            final index = entry.key;
            final tab = entry.value;
            final isSelected = index == selectedIndex;
            return Padding(
              padding: EdgeInsets.only(right: AppResponsive.s(context, 8)),
              child: GestureDetector(
                onTap: () => onTabSelected(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: AppResponsive.paddingSymmetric(context,
                      horizontal: 18, vertical: 9),
                  decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.accentBlue
                          : const Color(0xFFEBECF0),
                      borderRadius: AppResponsive.borderRadius(context, 20)),
                  child: Text(tab,
                      style: TextStyle(
                          fontFamily: 'SFProRounded',
                          fontSize: AppResponsive.font(context, 13),
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.black)),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.liveMatch});
  final LiveMatchModel liveMatch;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding:
          AppResponsive.padding(context, horizontal: 20, top: 8, bottom: 20),
      child: Column(
        children: [
          MatchCardNew(
            team1Name: liveMatch.team1Name,
            team1Section: liveMatch.team1Section,
            team2Name: liveMatch.team2Name,
            team2Section: liveMatch.team2Section,
            headerLabel: 'Set - 3',
            showScore: true,
            team1Score: 1,
            team2Score: 1,
            isLive: true,
            showLiveBadge: true,
            actionButtonText: 'Watch Live',
            onActionButtonTap: () {},
            margin: EdgeInsets.zero,
            enableShadow: false,
          ),
          SizedBox(height: AppResponsive.s(context, 12)),
          MatchCardNew(
            team1Name: liveMatch.team1Name,
            team1Section: liveMatch.team1Section,
            team2Name: liveMatch.team2Name,
            team2Section: liveMatch.team2Section,
            headerLabel: 'Set - 2',
            showScore: true,
            team1Score: 21,
            team2Score: 19,
            statusType: MatchStatusType.completed,
            statusText: 'Team A Is Winner',
            matchDate: '15 Dec 2025',
            margin: EdgeInsets.zero,
            enableShadow: false,
          ),
          SizedBox(height: AppResponsive.s(context, 12)),
          MatchCardNew(
            team1Name: liveMatch.team1Name,
            team1Section: liveMatch.team1Section,
            team2Name: liveMatch.team2Name,
            team2Section: liveMatch.team2Section,
            headerLabel: 'Set - 1',
            showScore: false,
            actionButtonText: 'Assign Player',
            onActionButtonTap: () {},
            matchDate: '15 Dec 2025',
            matchTime: '8:00 PM',
            margin: EdgeInsets.zero,
            enableShadow: false,
          ),
        ],
      ),
    );
  }
}

class _ScoreboardTab extends StatelessWidget {
  const _ScoreboardTab({required this.liveMatch});
  final LiveMatchModel liveMatch;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding:
          AppResponsive.padding(context, horizontal: 20, top: 8, bottom: 20),
      child: Column(
        children: [
          Text('Scoreboard coming soon',
              style: TextStyle(
                  fontFamily: 'SFProRounded',
                  fontSize: AppResponsive.font(context, 16),
                  color: AppColors.textSecondaryLight)),
        ],
      ),
    );
  }
}

class _PlayersTab extends StatelessWidget {
  const _PlayersTab(
      {required this.liveMatch,
      required this.selectedTeamTab,
      required this.onTeamTabChanged,
      required this.apiPlayers,
      required this.isLoadingPlayers,
      this.currentUserId});

  final LiveMatchModel liveMatch;
  final int selectedTeamTab;
  final ValueChanged<int> onTeamTabChanged;
  final List<PlayerModel> apiPlayers;
  final bool isLoadingPlayers;
  final String? currentUserId;

  @override
  Widget build(BuildContext context) {
    final halfIndex = (apiPlayers.length / 2).ceil();
    final team1Players = apiPlayers.isNotEmpty
        ? apiPlayers.sublist(0, halfIndex)
        : <PlayerModel>[];
    final team2Players = apiPlayers.length > halfIndex
        ? apiPlayers.sublist(halfIndex)
        : <PlayerModel>[];
    final players = selectedTeamTab == 0 ? team1Players : team2Players;

    return Column(
      children: [
        _TeamTabs(
            selectedIndex: selectedTeamTab, onTabChanged: onTeamTabChanged),
        Expanded(
          child: isLoadingPlayers
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                          color: AppColors.accentBlue),
                      SizedBox(height: AppResponsive.s(context, 12)),
                      Text('Loading players...',
                          style: TextStyle(
                              fontFamily: 'SFProRounded',
                              fontSize: AppResponsive.font(context, 14),
                              color: AppColors.textSecondaryLight)),
                    ],
                  ),
                )
              : players.isEmpty
                  ? Center(
                      child: Text('No players found',
                          style: TextStyle(
                              fontFamily: 'SFProRounded',
                              fontSize: AppResponsive.font(context, 16),
                              color: AppColors.textSecondaryLight)))
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: AppResponsive.padding(context,
                          horizontal: 20, top: 8, bottom: 20),
                      itemCount: players.length,
                      itemBuilder: (context, index) {
                        final player = players[index];
                        return _PlayerListItem(
                          player: player,
                          onTap: () {
                            final isOwnProfile = currentUserId != null &&
                                player.id == currentUserId;
                            Navigator.pushNamed(
                                context, AppRouter.playerProfile, arguments: {
                              'player': player,
                              'isOwnProfile': isOwnProfile
                            });
                          },
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

class _TeamTabs extends StatelessWidget {
  const _TeamTabs({required this.selectedIndex, required this.onTabChanged});
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFEBECF0),
      padding: AppResponsive.padding(context, horizontal: 16),
      child: Container(
        padding: AppResponsive.padding(context, all: 4),
        decoration: BoxDecoration(
            color: const Color(0xFFEBECF0),
            borderRadius: AppResponsive.borderRadius(context, 40)),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tabWidth = (constraints.maxWidth - 8) / 2;
            return Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  left: selectedIndex == 0 ? 0 : tabWidth + 8,
                  top: 0,
                  bottom: 0,
                  width: tabWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppResponsive.borderRadius(context, 36),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 3))
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => onTabChanged(0),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: AppResponsive.padding(context, vertical: 16),
                          child: Text(
                            'Team A',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'SFProRounded',
                              fontSize: AppResponsive.font(context, 16),
                              fontWeight: selectedIndex == 0
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: selectedIndex == 0
                                  ? AppColors.textPrimaryLight
                                  : const Color(0xFF9E9E9E),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: AppResponsive.s(context, 8)),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => onTabChanged(1),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: AppResponsive.padding(context, vertical: 16),
                          child: Text(
                            'Team B',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'SFProRounded',
                              fontSize: AppResponsive.font(context, 16),
                              fontWeight: selectedIndex == 1
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: selectedIndex == 1
                                  ? AppColors.textPrimaryLight
                                  : const Color(0xFF9E9E9E),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PlayerListItem extends ConsumerWidget {
  const _PlayerListItem({required this.player, this.onTap});
  final PlayerModel player;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarUrl = player.avatarUrl != null && player.avatarUrl!.isNotEmpty
        ? ref.read(profileRepositoryProvider).getUserImageUrl(player.avatarUrl)
        : null;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: AppResponsive.padding(context, vertical: 12),
        decoration: const BoxDecoration(
            border:
                Border(bottom: BorderSide(color: Color(0xFFF0F0F0), width: 1))),
        child: Row(
          children: [
            Container(
              width: AppResponsive.s(context, 48),
              height: AppResponsive.s(context, 48),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentBlue.withOpacity(0.1)),
              child: ClipOval(
                child: avatarUrl != null && avatarUrl.isNotEmpty
                    ? CachedNetworkImage(imageUrl: avatarUrl, fit: BoxFit.cover)
                    : Icon(Icons.person,
                        size: AppResponsive.icon(context, 24),
                        color: AppColors.accentBlue),
              ),
            ),
            SizedBox(width: AppResponsive.s(context, 12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(player.name,
                          style: TextStyle(
                              fontFamily: 'SFProRounded',
                              fontSize: AppResponsive.font(context, 16),
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimaryLight)),
                      SizedBox(width: AppResponsive.s(context, 8)),
                      if (player.skillLevel.isNotEmpty)
                        Container(
                          padding: AppResponsive.paddingSymmetric(context,
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: const Color(0xFFF0F0F0),
                              borderRadius:
                                  AppResponsive.borderRadius(context, 6)),
                          child: Text(player.skillLevel,
                              style: TextStyle(
                                  fontFamily: 'SFProRounded',
                                  fontSize: AppResponsive.font(context, 11),
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF616161))),
                        ),
                    ],
                  ),
                  SizedBox(height: AppResponsive.s(context, 2)),
                  Text(
                    player.role,
                    style: TextStyle(
                      fontFamily: 'SFProRounded',
                      fontSize: AppResponsive.font(context, 13),
                      fontWeight: FontWeight.w500,
                      color: player.role == 'Captain'
                          ? AppColors.accentBlue
                          : const Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OtherMatchesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Text('Other matches coming soon',
            style: TextStyle(
                fontFamily: 'SFProRounded',
                fontSize: AppResponsive.font(context, 16),
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondaryLight)));
  }
}
