import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_colors_new.dart';
import '../../../../core/theme/app_responsive.dart';
import '../../../../core/widgets/global_app_bar.dart' hide AppSearchBar;
import '../../../../core/widgets/app_search_bar.dart';
import '../../../../core/routing/app_router.dart';
import '../providers/my_tournament_providers.dart';

/// View Enrolled Players Page (Owner App)
///
/// Shows all players enrolled in a tournament — read-only, no invite actions.
/// Used when playerAllocation == 2 in the My Team tab.
class ViewEnrolledPlayersPage extends ConsumerStatefulWidget {
  const ViewEnrolledPlayersPage({
    super.key,
    required this.tournamentId,
    required this.tournamentName,
    this.eventSport = '',
    this.openFirst = false,
  });

  final int tournamentId;
  final String tournamentName;
  final String eventSport;
  final bool openFirst;

  @override
  ConsumerState<ViewEnrolledPlayersPage> createState() =>
      _ViewEnrolledPlayersPageState();
}

class _ViewEnrolledPlayersPageState
    extends ConsumerState<ViewEnrolledPlayersPage> {
  String _searchQuery = '';
  bool _openedFirst = false;

  Future<void> _refresh() async {
    ref.invalidate(enrolledPlayersProvider(widget.tournamentId));
  }

  @override
  Widget build(BuildContext context) {
    final playersAsync =
        ref.watch(enrolledPlayersProvider(widget.tournamentId));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // App bar header
            GlobalAppBar(
              title: widget.tournamentName,
              subtitle: 'All Players',
              showBackButton: true,
            ),

            // Search bar
            Padding(
              padding: AppResponsive.padding(
                context,
                horizontal: 20,
                top: 8,
                bottom: 12,
              ),
              child: AppSearchBar(
                hintText: 'Search players...',
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),

            // Player list
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                color: AppColors.accentBlue,
                child: playersAsync.when(
                  data: (players) {
                    if (players.isEmpty) {
                      return _buildEmpty(context, 'No players enrolled yet.');
                    }

                    // Filter by name
                    final query = _searchQuery.toLowerCase().trim();
                    final filtered = query.isEmpty
                        ? players
                        : players.where((p) {
                            final first =
                                (p['firstName'] as String? ?? '').toLowerCase();
                            final last =
                                (p['lastName'] as String? ?? '').toLowerCase();
                            return first.contains(query) ||
                                last.contains(query);
                          }).toList();

                    if (filtered.isEmpty) {
                      return _buildEmpty(
                        context,
                        'No players match "$_searchQuery".',
                      );
                    }

                    // If requested, open the first player's bid page automatically
                    if (widget.openFirst &&
                        !_openedFirst &&
                        filtered.isNotEmpty) {
                      _openedFirst = true;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.of(context).pushNamed(
                          AppRouter.playerBid,
                          arguments: {
                            'player': filtered.first,
                            'eventTitle': widget.tournamentName,
                            'eventSport': widget.eventSport,
                            'tournamentId': widget.tournamentId,
                          },
                        );
                      });
                    }

                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: AppResponsive.padding(
                        context,
                        horizontal: 20,
                        bottom: 24,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        return _EnrolledPlayerCard(
                          player: filtered[index],
                          onTap: () => Navigator.of(context).pushNamed(
                            AppRouter.playerBid,
                            arguments: {
                              'player': filtered[index],
                              'eventTitle': widget.tournamentName,
                              'eventSport': widget.eventSport,
                              'tournamentId': widget.tournamentId,
                            },
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.accentBlue),
                  ),
                  error: (error, _) => ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.25),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red.shade400,
                            size: AppResponsive.icon(context, 48),
                          ),
                          SizedBox(height: AppResponsive.s(context, 12)),
                          Text(
                            'Failed to load players',
                            style: TextStyle(
                              fontFamily: 'SFProRounded',
                              fontSize: AppResponsive.font(context, 16),
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimaryLight,
                            ),
                          ),
                          SizedBox(height: AppResponsive.s(context, 6)),
                          Text(
                            error.toString().replaceFirst('Exception: ', ''),
                            style: TextStyle(
                              fontFamily: 'SFProRounded',
                              fontSize: AppResponsive.font(context, 13),
                              color: AppColors.textSecondaryLight,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: AppResponsive.s(context, 16)),
                          TextButton(
                            onPressed: _refresh,
                            child: const Text(
                              'Retry',
                              style: TextStyle(
                                fontFamily: 'SFProRounded',
                                color: AppColors.accentBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ), // closes RefreshIndicator
            ), // closes Expanded
          ], // closes Column children
        ), // closes Column
      ), // closes SafeArea
    ); // closes Scaffold
  }

  Widget _buildEmpty(BuildContext context, String message) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_outline,
                size: AppResponsive.icon(context, 56),
                color: Colors.grey.shade300,
              ),
              SizedBox(height: AppResponsive.s(context, 16)),
              Text(
                message,
                style: TextStyle(
                  fontFamily: 'SFProRounded',
                  fontSize: AppResponsive.font(context, 15),
                  color: AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Read-only player card — shows avatar, name, proficiency badge, and sport role.
/// Tapping navigates to the [PlayerBidPage] for this player.
class _EnrolledPlayerCard extends ConsumerWidget {
  const _EnrolledPlayerCard({required this.player, this.onTap});

  final Map<String, dynamic> player;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firstName = player['firstName'] as String? ?? '';
    final lastName = player['lastName'] as String? ?? '';
    final fullName = '$firstName $lastName'.trim();
    final imageFile = player['imageFile'] as String?;
    final proficiency = ((player['sportPreferenceLevel'] as String? ??
            player['proficiency'] as String? ??
            '') as String)
        .trim();
    final sportRole = (player['sportRole'] as String? ?? '').trim();
    final playerCategory =
        (player['tournamentPlayerCategory'] as String? ?? '').trim();

    final subtitleParts = [
      if (sportRole.isNotEmpty) sportRole,
      if (playerCategory.isNotEmpty) playerCategory,
    ];
    final subtitle = subtitleParts.join('  ·  ');

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Padding(
            padding: AppResponsive.padding(context, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                Container(
                  width: AppResponsive.s(context, 48),
                  height: AppResponsive.s(context, 48),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFF0F0F0),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _buildAvatar(context, ref, imageFile),
                ),
                SizedBox(width: AppResponsive.s(context, 12)),

                // Info column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + proficiency pill
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              fullName.isNotEmpty ? fullName : 'Unknown Player',
                              style: TextStyle(
                                fontFamily: 'SFProRounded',
                                fontSize: AppResponsive.font(context, 15),
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1A1A1A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (proficiency.isNotEmpty) ...[
                            SizedBox(width: AppResponsive.s(context, 6)),
                            Container(
                              padding: AppResponsive.paddingSymmetric(
                                context,
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text(
                                proficiency,
                                style: TextStyle(
                                  fontFamily: 'SFProRounded',
                                  fontSize: AppResponsive.font(context, 11),
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF5C5C5C),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      // Subtitle: sportRole · playerCategory
                      if (subtitle.isNotEmpty) ...[
                        SizedBox(height: AppResponsive.s(context, 3)),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontFamily: 'SFProRounded',
                            fontSize: AppResponsive.font(context, 12),
                            fontWeight: FontWeight.w400,
                            color: Colors.grey.shade500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: const Color(0xFF0A1217).withOpacity(0.1),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, WidgetRef ref, String? imageFile) {
    if (imageFile != null && imageFile.isNotEmpty) {
      final apiClient = ref.watch(apiClientProvider);
      final imageUrl =
          '${apiClient.baseUrl}${ApiEndpoints.usersUploads}$imageFile';
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (_, __) => _placeholder(context),
        errorWidget: (_, __, ___) => _placeholder(context),
      );
    }
    return _placeholder(context);
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Icon(
          Icons.person,
          size: AppResponsive.s(context, 24),
          color: Colors.grey.shade400,
        ),
      ),
    );
  }
}
