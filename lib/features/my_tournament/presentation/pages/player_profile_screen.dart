import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors_new.dart';
import '../../../../core/theme/app_responsive.dart';
import '../../../../core/widgets/global_app_bar.dart';
import '../../../auth/presentation/providers/onboarding_providers.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import 'live_match_screen.dart';

class PlayerMatchHistoryModel {
  final String id;
  final String roundName;
  final String team1Name;
  final String team1Group;
  final String? team1AvatarUrl;
  final int team1Score;
  final String team2Name;
  final String team2Group;
  final String? team2AvatarUrl;
  final int team2Score;
  final String matchDate;
  final String? winnerTeam;

  const PlayerMatchHistoryModel({
    required this.id,
    required this.roundName,
    required this.team1Name,
    required this.team1Group,
    this.team1AvatarUrl,
    required this.team1Score,
    required this.team2Name,
    required this.team2Group,
    this.team2AvatarUrl,
    required this.team2Score,
    required this.matchDate,
    this.winnerTeam,
  });
}

class PlayerProfileScreen extends ConsumerStatefulWidget {
  const PlayerProfileScreen(
      {super.key, required this.player, this.isOwnProfile = false});
  final PlayerModel player;
  final bool isOwnProfile;

  @override
  ConsumerState<PlayerProfileScreen> createState() =>
      _PlayerProfileScreenState();
}

class _PlayerProfileScreenState extends ConsumerState<PlayerProfileScreen> {
  int _selectedTabIndex = 0;
  late List<PlayerMatchHistoryModel> _matchHistory;

  @override
  void initState() {
    super.initState();
    _matchHistory = [
      const PlayerMatchHistoryModel(
          id: '1',
          roundName: 'Round -1',
          team1Name: 'Team A',
          team1Group: 'Group A',
          team1Score: 21,
          team2Name: 'Team B',
          team2Group: 'Group B',
          team2Score: 19,
          matchDate: '15 Dec 2025',
          winnerTeam: 'Team A'),
      const PlayerMatchHistoryModel(
          id: '2',
          roundName: 'Round -1',
          team1Name: 'Team A',
          team1Group: 'Group A',
          team1Score: 21,
          team2Name: 'Team B',
          team2Group: 'Group B',
          team2Score: 19,
          matchDate: '15 Dec 2025',
          winnerTeam: 'Team A'),
    ];
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
                title: 'Player Profile',
                titleFontSize: AppResponsive.s(context, 20),
                showBackButton: true,
                showDivider: true),
            Expanded(
              child: Column(
                children: [
                  SizedBox(height: AppResponsive.s(context, 16)),
                  _PlayerProfileHeader(player: widget.player),
                  SizedBox(height: AppResponsive.s(context, 20)),
                  if (widget.isOwnProfile)
                    _ProfileTabBar(
                        selectedIndex: _selectedTabIndex,
                        onTabChanged: (index) {
                          setState(() {
                            _selectedTabIndex = index;
                          });
                        }),
                  SizedBox(height: AppResponsive.s(context, 16)),
                  Expanded(child: _buildTabContent()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    if (!widget.isOwnProfile) return _MatchesTab(matchHistory: _matchHistory);
    if (_selectedTabIndex == 0) return const _GeneralsTab();
    return _MatchesTab(matchHistory: _matchHistory);
  }
}

class _PlayerProfileHeader extends ConsumerWidget {
  const _PlayerProfileHeader({required this.player});
  final PlayerModel player;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: AppResponsive.paddingSymmetric(context, horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF90D5FF), Color(0xFF0000FF), Color(0xFF040273)],
          ),
          borderRadius: AppResponsive.borderRadius(context, 33),
        ),
        child: Column(
          children: [
            Padding(
              padding: AppResponsive.padding(context,
                  horizontal: 20, top: 20, bottom: 15),
              child: Row(
                children: [
                  Container(
                    width: AppResponsive.s(context, 72),
                    height: AppResponsive.s(context, 72),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3)),
                    child: ClipOval(
                      child: player.avatarUrl != null &&
                              player.avatarUrl!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: ref
                                  .read(profileRepositoryProvider)
                                  .getUserImageUrl(player.avatarUrl),
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) =>
                                  _buildPlaceholder(context),
                            )
                          : _buildPlaceholder(context),
                    ),
                  ),
                  SizedBox(width: AppResponsive.s(context, 16)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(player.name,
                            style: TextStyle(
                                fontFamily: 'SFProRounded',
                                fontSize: AppResponsive.font(context, 18),
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                        Text(player.email ?? '',
                            style: TextStyle(
                                fontFamily: 'SFProRounded',
                                fontSize: AppResponsive.font(context, 13),
                                fontWeight: FontWeight.w500,
                                color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin:
                  AppResponsive.padding(context, horizontal: 16, bottom: 20),
              padding:
                  AppResponsive.padding(context, vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppResponsive.borderRadius(context, 23)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const _StatItem(value: '67 %', label: 'Win Rate'),
                  Container(
                      width: 1,
                      height: AppResponsive.s(context, 32),
                      color: const Color(0xFFE5E5E5)),
                  const _StatItem(value: '675', label: 'Total Matches'),
                  Container(
                      width: 1,
                      height: AppResponsive.s(context, 32),
                      color: const Color(0xFFE5E5E5)),
                  const _StatItem(value: '675', label: 'Total Matches'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: Image.asset(
        'assets/images/defaultProfile.png',
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Icon(Icons.person,
            size: AppResponsive.icon(context, 36), color: Colors.grey[400]),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontFamily: 'SFProRounded',
                fontSize: AppResponsive.font(context, 16),
                fontWeight: FontWeight.w700,
                color: Colors.black)),
        SizedBox(height: AppResponsive.s(context, 2)),
        Text(label,
            style: TextStyle(
                fontFamily: 'SFProRounded',
                fontSize: AppResponsive.font(context, 12),
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6F6F6F))),
      ],
    );
  }
}

class _ProfileTabBar extends StatelessWidget {
  const _ProfileTabBar(
      {required this.selectedIndex, required this.onTabChanged});
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppResponsive.paddingSymmetric(context, horizontal: 20),
      child: Container(
        padding: AppResponsive.padding(context, all: 6),
        decoration: BoxDecoration(
            color: const Color(0xFFEBECF0),
            borderRadius: AppResponsive.borderRadius(context, 30)),
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
                      borderRadius: AppResponsive.borderRadius(context, 26),
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
                          padding: AppResponsive.padding(context, vertical: 14),
                          child: Text(
                            'Generals',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'SFProRounded',
                              fontSize: AppResponsive.font(context, 16),
                              fontWeight: selectedIndex == 0
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: selectedIndex == 0
                                  ? Colors.black
                                  : const Color(0xFF5C5C5C),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => onTabChanged(1),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: AppResponsive.padding(context, vertical: 14),
                          child: Text(
                            'Matches',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'SFProRounded',
                              fontSize: AppResponsive.font(context, 16),
                              fontWeight: selectedIndex == 1
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: selectedIndex == 1
                                  ? Colors.black
                                  : const Color(0xFF5C5C5C),
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

class _GeneralsTab extends ConsumerStatefulWidget {
  const _GeneralsTab();
  @override
  ConsumerState<_GeneralsTab> createState() => _GeneralsTabState();
}

class _GeneralsTabState extends ConsumerState<_GeneralsTab>
    with AutomaticKeepAliveClientMixin {
  bool _vitalsExpanded = false;
  bool _addressExpanded = false;
  bool _sportsExpanded = false;
  bool _isLoadingProfile = false;
  Map<String, dynamic>? _profileData;
  bool _isLoadingAddress = false;
  Map<String, dynamic>? _addressData;
  bool _isLoadingSports = false;
  List<Map<String, String>> _sportsPreferences = [];
  bool _dataLoaded = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    if (_dataLoaded) return;
    await Future.wait(
        [_loadProfileData(), _loadAddressData(), _loadSportsPreferences()]);
    _dataLoaded = true;
  }

  Future<void> _loadProfileData() async {
    if (_profileData == null)
      setState(() {
        _isLoadingProfile = true;
      });
    try {
      final profileRepo = ref.read(profileRepositoryProvider);
      final profile = await profileRepo.getProfile();
      if (!mounted) return;
      setState(() {
        _profileData = {
          'gender': profile.gender ?? 'Not specified',
          'bloodGroup': profile.bloodGroup ?? 'Not specified',
          'height':
              profile.height != null ? '${profile.height} cm' : 'Not specified',
          'weight':
              profile.weight != null ? '${profile.weight} kg' : 'Not specified',
          'tshirtSize': profile.tshirtSize ?? 'Not specified',
        };
        _isLoadingProfile = false;
      });
    } catch (e) {
      if (mounted)
        setState(() {
          _isLoadingProfile = false;
        });
    }
  }

  Future<void> _loadAddressData() async {
    if (_addressData == null)
      setState(() {
        _isLoadingAddress = true;
      });
    try {
      final profileRepo = ref.read(profileRepositoryProvider);
      final profile = await profileRepo.getProfile();
      if (!mounted) return;
      final parts = <String>[];
      if (profile.street?.isNotEmpty == true) parts.add(profile.street!);
      if (profile.city?.isNotEmpty == true) parts.add(profile.city!);
      if (profile.district?.isNotEmpty == true) parts.add(profile.district!);
      if (profile.state?.isNotEmpty == true) parts.add(profile.state!);
      if (profile.country?.isNotEmpty == true) parts.add(profile.country!);
      if (profile.pincode?.isNotEmpty == true) parts.add(profile.pincode!);
      setState(() {
        _addressData = {
          'fullAddress':
              parts.isNotEmpty ? parts.join(', ') : 'Address not specified'
        };
        _isLoadingAddress = false;
      });
    } catch (e) {
      if (mounted)
        setState(() {
          _isLoadingAddress = false;
        });
    }
  }

  Future<void> _loadSportsPreferences() async {
    if (_sportsPreferences.isEmpty)
      setState(() {
        _isLoadingSports = true;
      });
    try {
      final profileRepo = ref.read(profileRepositoryProvider);
      final profile = await profileRepo.getProfile();
      final userId = int.parse(profile.id);
      final onboardingRepo = ref.read(onboardingRepositoryProvider);
      final preferences = await onboardingRepo.getPlayerSportsPreferencesList(
          playerUserId: userId);
      if (!mounted) return;
      final sportsList = await ref.read(sportsListProvider.future);
      final proficiencyLevels =
          await ref.read(proficiencyLevelsProvider.future);
      if (!mounted) return;
      final mappedPreferences = <Map<String, String>>[];
      for (final pref in preferences) {
        final sportId = pref['sportId'] as int?;
        final levelId = pref['levelId'] as int?;
        if (sportId != null && levelId != null) {
          String sportName = 'Unknown Sport';
          try {
            final sport = sportsList
                .firstWhere((s) => (s as dynamic).sportsId == sportId);
            sportName = (sport as dynamic).sportsName as String;
          } catch (_) {}
          String levelName = 'Unknown';
          try {
            final level = proficiencyLevels.firstWhere((l) => l.id == levelId);
            levelName = level.name;
          } catch (_) {}
          mappedPreferences.add({'name': sportName, 'level': levelName});
        }
      }
      setState(() {
        _sportsPreferences = mappedPreferences;
        _isLoadingSports = false;
      });
    } catch (e) {
      if (mounted)
        setState(() {
          _isLoadingSports = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: AppResponsive.paddingSymmetric(context, horizontal: 20),
        child: Column(
          children: [
            _ExpandableSection(
              title: 'View Vitals',
              isExpanded: _vitalsExpanded,
              onTap: () => setState(() => _vitalsExpanded = !_vitalsExpanded),
              child: _buildDataContent(
                context,
                _isLoadingProfile,
                _profileData,
                (data) => Container(
                  margin: EdgeInsets.only(top: AppResponsive.s(context, 8)),
                  padding: AppResponsive.padding(context, all: 16),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF7F8FA),
                      borderRadius: AppResponsive.borderRadius(context, 16)),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: _VitalItem(
                                  label: 'Gender',
                                  value: data['gender'] ?? 'Not specified')),
                          Expanded(
                              child: _VitalItem(
                                  label: 'Blood Group',
                                  value:
                                      data['bloodGroup'] ?? 'Not specified')),
                          Expanded(
                              child: _VitalItem(
                                  label: 'Height (cm)',
                                  value: data['height'] ?? 'Not specified')),
                        ],
                      ),
                      SizedBox(height: AppResponsive.s(context, 16)),
                      Row(
                        children: [
                          Expanded(
                              child: _VitalItem(
                                  label: 'Weight (kg)',
                                  value: data['weight'] ?? 'Not specified')),
                          Expanded(
                              child: _VitalItem(
                                  label: 'T-shirt Size',
                                  value:
                                      data['tshirtSize'] ?? 'Not specified')),
                          const Expanded(child: SizedBox()),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: AppResponsive.s(context, 12)),
            _ExpandableSection(
              title: 'View Address',
              isExpanded: _addressExpanded,
              onTap: () => setState(() => _addressExpanded = !_addressExpanded),
              child: _buildSimpleContent(context, _isLoadingAddress,
                  _addressData?['fullAddress'] ?? 'Address not specified'),
            ),
            SizedBox(height: AppResponsive.s(context, 12)),
            _ExpandableSection(
              title: 'View Sports & Proficiency',
              isExpanded: _sportsExpanded,
              onTap: () => setState(() => _sportsExpanded = !_sportsExpanded),
              child: _buildSportsContent(context),
            ),
            SizedBox(height: AppResponsive.s(context, 20)),
          ],
        ),
      ),
    );
  }

  Widget _buildDataContent(
      BuildContext context,
      bool isLoading,
      Map<String, dynamic>? data,
      Widget Function(Map<String, dynamic>) builder) {
    if (isLoading) {
      return Container(
        margin: EdgeInsets.only(top: AppResponsive.s(context, 8)),
        padding: AppResponsive.padding(context, all: 16),
        decoration: BoxDecoration(
            color: const Color(0xFFF7F8FA),
            borderRadius: AppResponsive.borderRadius(context, 16)),
        child: Center(
            child: SizedBox(
                width: AppResponsive.s(context, 24),
                height: AppResponsive.s(context, 24),
                child: const CircularProgressIndicator(strokeWidth: 2))),
      );
    }
    if (data == null) {
      return Container(
        margin: EdgeInsets.only(top: AppResponsive.s(context, 8)),
        padding: AppResponsive.padding(context, all: 16),
        decoration: BoxDecoration(
            color: const Color(0xFFF7F8FA),
            borderRadius: AppResponsive.borderRadius(context, 16)),
        child: Text('No data available',
            style: TextStyle(
                fontFamily: 'SFProRounded',
                fontSize: AppResponsive.font(context, 14),
                fontWeight: FontWeight.w500,
                color: const Color(0xFF9E9E9E))),
      );
    }
    return builder(data);
  }

  Widget _buildSimpleContent(
      BuildContext context, bool isLoading, String text) {
    if (isLoading) {
      return Container(
        margin: EdgeInsets.only(top: AppResponsive.s(context, 8)),
        padding: AppResponsive.padding(context, all: 16),
        decoration: BoxDecoration(
            color: const Color(0xFFF7F8FA),
            borderRadius: AppResponsive.borderRadius(context, 16)),
        child: Center(
            child: SizedBox(
                width: AppResponsive.s(context, 24),
                height: AppResponsive.s(context, 24),
                child: const CircularProgressIndicator(strokeWidth: 2))),
      );
    }
    return Container(
      margin: EdgeInsets.only(top: AppResponsive.s(context, 8)),
      padding: AppResponsive.padding(context, all: 16),
      decoration: BoxDecoration(
          color: const Color(0xFFF7F8FA),
          borderRadius: AppResponsive.borderRadius(context, 16)),
      child: Text(text,
          style: TextStyle(
              fontFamily: 'SFProRounded',
              fontSize: AppResponsive.font(context, 14),
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1A1A1A))),
    );
  }

  Widget _buildSportsContent(BuildContext context) {
    if (_isLoadingSports) {
      return Container(
        margin: EdgeInsets.only(top: AppResponsive.s(context, 8)),
        padding: AppResponsive.padding(context, all: 16),
        decoration: BoxDecoration(
            color: const Color(0xFFF7F8FA),
            borderRadius: AppResponsive.borderRadius(context, 16)),
        child: Center(
            child: SizedBox(
                width: AppResponsive.s(context, 24),
                height: AppResponsive.s(context, 24),
                child: const CircularProgressIndicator(strokeWidth: 2))),
      );
    }
    if (_sportsPreferences.isEmpty) {
      return Container(
        margin: EdgeInsets.only(top: AppResponsive.s(context, 8)),
        padding: AppResponsive.padding(context, all: 16),
        decoration: BoxDecoration(
            color: const Color(0xFFF7F8FA),
            borderRadius: AppResponsive.borderRadius(context, 16)),
        child: Text('No sports preferences added yet',
            style: TextStyle(
                fontFamily: 'SFProRounded',
                fontSize: AppResponsive.font(context, 14),
                fontWeight: FontWeight.w500,
                color: const Color(0xFF9E9E9E))),
      );
    }
    return Container(
      margin: EdgeInsets.only(top: AppResponsive.s(context, 8)),
      padding: AppResponsive.padding(context, all: 16),
      decoration: BoxDecoration(
          color: const Color(0xFFF7F8FA),
          borderRadius: AppResponsive.borderRadius(context, 16)),
      child: Column(
        children: _sportsPreferences.asMap().entries.map((entry) {
          final sport = entry.value;
          final isLast = entry.key == _sportsPreferences.length - 1;
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(sport['name']!,
                      style: TextStyle(
                          fontFamily: 'SFProRounded',
                          fontSize: AppResponsive.font(context, 14),
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1A1A1A))),
                  Text(sport['level']!,
                      style: TextStyle(
                          fontFamily: 'SFProRounded',
                          fontSize: AppResponsive.font(context, 14),
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF3B82F6))),
                ],
              ),
              if (!isLast) SizedBox(height: AppResponsive.s(context, 12)),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _ExpandableSection extends StatelessWidget {
  const _ExpandableSection(
      {required this.title,
      required this.isExpanded,
      required this.onTap,
      required this.child});
  final String title;
  final bool isExpanded;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding:
                AppResponsive.padding(context, horizontal: 11, vertical: 11),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppResponsive.borderRadius(context, 46),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: AppResponsive.s(context, 48),
                  height: AppResponsive.s(context, 48),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF7F8FA),
                      borderRadius: AppResponsive.borderRadius(context, 46)),
                ),
                SizedBox(width: AppResponsive.s(context, 10)),
                Expanded(
                    child: Text(title,
                        style: TextStyle(
                            fontFamily: 'SFProRounded',
                            fontSize: AppResponsive.font(context, 16),
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A1A1A)))),
                Padding(
                  padding: EdgeInsets.only(left: AppResponsive.s(context, 8)),
                  child: AnimatedRotation(
                    turns: isExpanded ? 0 : 0.5,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.keyboard_arrow_up,
                        size: AppResponsive.icon(context, 28),
                        color: const Color(0xFF9CA3AF)),
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: isExpanded ? child : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _VitalItem extends StatelessWidget {
  const _VitalItem({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontFamily: 'SFProRounded',
                fontSize: AppResponsive.font(context, 11),
                fontWeight: FontWeight.w400,
                color: const Color(0xFF9E9E9E))),
        SizedBox(height: AppResponsive.s(context, 4)),
        Text(value,
            style: TextStyle(
                fontFamily: 'SFProRounded',
                fontSize: AppResponsive.font(context, 15),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A))),
      ],
    );
  }
}

class _MatchesTab extends StatelessWidget {
  const _MatchesTab({required this.matchHistory});
  final List<PlayerMatchHistoryModel> matchHistory;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          ...matchHistory.map((match) => _MatchHistoryCard(match: match)),
          SizedBox(height: AppResponsive.s(context, 20)),
        ],
      ),
    );
  }
}

class _MatchHistoryCard extends StatelessWidget {
  const _MatchHistoryCard({required this.match});
  final PlayerMatchHistoryModel match;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppResponsive.padding(context, horizontal: 20, bottom: 16),
      padding: AppResponsive.padding(context, all: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF90D5FF), Color(0xFF4A90E2), Color(0xFF5B9FED)],
        ),
        borderRadius: AppResponsive.borderRadius(context, 20),
      ),
      child: Column(
        children: [
          Text(match.roundName,
              style: TextStyle(
                  fontFamily: 'SFProRounded',
                  fontSize: AppResponsive.font(context, 14),
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.9))),
          SizedBox(height: AppResponsive.s(context, 12)),
          Row(
            children: [
              Expanded(
                  child: _MatchTeamColumn(
                      teamName: match.team1Name,
                      groupName: match.team1Group,
                      avatarUrl: match.team1AvatarUrl)),
              Column(
                children: [
                  Text('${match.team1Score} : ${match.team2Score}',
                      style: TextStyle(
                          fontFamily: 'SFProRounded',
                          fontSize: AppResponsive.font(context, 28),
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  SizedBox(height: AppResponsive.s(context, 4)),
                  Text(match.matchDate,
                      style: TextStyle(
                          fontFamily: 'SFProRounded',
                          fontSize: AppResponsive.font(context, 12),
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.9))),
                  if (match.winnerTeam != null) ...[
                    SizedBox(height: AppResponsive.s(context, 8)),
                    Container(
                      padding: AppResponsive.paddingSymmetric(context,
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              AppResponsive.borderRadius(context, 12)),
                      child: Text('${match.winnerTeam} Is Winner',
                          style: TextStyle(
                              fontFamily: 'SFProRounded',
                              fontSize: AppResponsive.font(context, 11),
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1A1A1A))),
                    ),
                  ],
                ],
              ),
              Expanded(
                  child: _MatchTeamColumn(
                      teamName: match.team2Name,
                      groupName: match.team2Group,
                      avatarUrl: match.team2AvatarUrl)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MatchTeamColumn extends ConsumerWidget {
  const _MatchTeamColumn(
      {required this.teamName, required this.groupName, this.avatarUrl});
  final String teamName;
  final String groupName;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fullAvatarUrl = avatarUrl != null && avatarUrl!.isNotEmpty
        ? ref.read(profileRepositoryProvider).getUserImageUrl(avatarUrl)
        : null;
    return Column(
      children: [
        Container(
          width: AppResponsive.s(context, 48),
          height: AppResponsive.s(context, 48),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border:
                  Border.all(color: Colors.white.withOpacity(0.5), width: 2)),
          child: ClipOval(
            child: fullAvatarUrl != null && fullAvatarUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: fullAvatarUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Icon(Icons.person,
                        size: AppResponsive.icon(context, 24),
                        color: Colors.grey[400]))
                : Icon(Icons.person,
                    size: AppResponsive.icon(context, 24),
                    color: Colors.grey[400]),
          ),
        ),
        SizedBox(height: AppResponsive.s(context, 6)),
        Text(teamName,
            style: TextStyle(
                fontFamily: 'SFProRounded',
                fontSize: AppResponsive.font(context, 13),
                fontWeight: FontWeight.w700,
                color: Colors.white),
            textAlign: TextAlign.center),
        SizedBox(height: AppResponsive.s(context, 2)),
        Text(groupName,
            style: TextStyle(
                fontFamily: 'SFProRounded',
                fontSize: AppResponsive.font(context, 11),
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.8)),
            textAlign: TextAlign.center),
      ],
    );
  }
}
