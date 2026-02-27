import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_responsive.dart';

/// Blue-gradient player profile card used in the bid/auction screen.
/// Displays avatar, name, email, phone, gender pill, age, and a stats bar.
class PlayerProfileCard extends ConsumerWidget {
  const PlayerProfileCard({
    super.key,
    required this.playerName,
    required this.email,
    required this.phone,
    required this.gender,
    required this.age,
    required this.proficiency,
    required this.winRate,
    required this.totalMatches,
    this.imageFile,
  });

  final String playerName;
  final String email;
  final String phone;
  final String gender;
  final String age;
  final String proficiency;
  final String winRate;
  final String totalMatches;
  final String? imageFile;

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
          borderRadius: AppResponsive.borderRadius(context, 24),
        ),
        child: Column(
          children: [
            // ── Top row: avatar + info ──────────────────────────────────
            Padding(
              padding: AppResponsive.padding(context,
                  horizontal: 20, top: 20, bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar circle
                  Container(
                    width: AppResponsive.s(context, 72),
                    height: AppResponsive.s(context, 72),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: ClipOval(child: _buildAvatar(context, ref)),
                  ),
                  SizedBox(width: AppResponsive.s(context, 14)),

                  // Name + contact details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          playerName,
                          style: TextStyle(
                            fontFamily: 'SFProRounded',
                            fontSize: AppResponsive.font(context, 17),
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        if (email.isNotEmpty) ...[
                          SizedBox(height: AppResponsive.s(context, 2)),
                          Text(
                            email,
                            style: TextStyle(
                              fontFamily: 'SFProRounded',
                              fontSize: AppResponsive.font(context, 12),
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),
                        ],
                        if (phone.isNotEmpty) ...[
                          SizedBox(height: AppResponsive.s(context, 2)),
                          Text(
                            '+91 $phone',
                            style: TextStyle(
                              fontFamily: 'SFProRounded',
                              fontSize: AppResponsive.font(context, 12),
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),
                        ],
                        SizedBox(height: AppResponsive.s(context, 6)),
                        // Gender badge + age
                        Row(
                          children: [
                            if (gender.isNotEmpty) ...[
                              Container(
                                padding: AppResponsive.paddingSymmetric(context,
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  gender,
                                  style: TextStyle(
                                    fontFamily: 'SFProRounded',
                                    fontSize: AppResponsive.font(context, 11),
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1A1A1A),
                                  ),
                                ),
                              ),
                              SizedBox(width: AppResponsive.s(context, 8)),
                            ],
                            if (age.isNotEmpty)
                              Text(
                                age,
                                style: TextStyle(
                                  fontFamily: 'SFProRounded',
                                  fontSize: AppResponsive.font(context, 12),
                                  color: Colors.white.withOpacity(0.85),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Stats bar (white pill) ───────────────────────────────────
            Container(
              margin:
                  AppResponsive.padding(context, horizontal: 16, bottom: 16),
              padding:
                  AppResponsive.padding(context, vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppResponsive.borderRadius(context, 20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  BidStatItem(value: winRate, label: 'Win Rate'),
                  const BidStatDivider(),
                  BidStatItem(value: totalMatches, label: 'Total Matches'),
                  const BidStatDivider(),
                  BidStatItem(
                    value: proficiency.isNotEmpty ? proficiency : '—',
                    label: 'Proficiency',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, WidgetRef ref) {
    if (imageFile != null && imageFile!.isNotEmpty) {
      final apiClient = ref.watch(apiClientProvider);
      final url = '${apiClient.baseUrl}${ApiEndpoints.usersUploads}$imageFile';
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (_, __) => _placeholder(context),
        errorWidget: (_, __, ___) => _placeholder(context),
      );
    }
    return _placeholder(context);
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      color: Colors.grey.shade300,
      child: Center(
        child: Icon(
          Icons.person,
          color: Colors.grey.shade500,
          size: AppResponsive.s(context, 32),
        ),
      ),
    );
  }
}

// ─── Stat item inside the white pill ────────────────────────────────────────

class BidStatItem extends StatelessWidget {
  const BidStatItem({super.key, required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'SFProRounded',
            fontSize: AppResponsive.font(context, 16),
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        SizedBox(height: AppResponsive.s(context, 2)),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'SFProRounded',
            fontSize: AppResponsive.font(context, 11),
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6F6F6F),
          ),
        ),
      ],
    );
  }
}

// ─── Thin vertical divider between stat items ───────────────────────────────

class BidStatDivider extends StatelessWidget {
  const BidStatDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: AppResponsive.s(context, 32),
      color: const Color(0xFFE5E5E5),
    );
  }
}
