import 'package:flutter/material.dart';

import '../../../../core/theme/app_responsive.dart';
import 'bid_model.dart';

/// Dark-blue gradient card showing the current (highest) bid.
/// Left side: points + timestamp. Right side: team name + owner name.
class CurrentBidCard extends StatelessWidget {
  const CurrentBidCard({super.key, required this.bid});

  final BidModel bid;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0000FF), Color(0xFF040273)],
        ),
        borderRadius: AppResponsive.borderRadius(context, 18),
      ),
      child: Row(
        children: [
          // ── Points + timestamp ────────────────────────────────────────
          Expanded(
            flex: 2,
            child: Padding(
              padding: AppResponsive.padding(context, all: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${bid.points} ',
                          style: TextStyle(
                            fontFamily: 'SFProRounded',
                            fontSize: AppResponsive.font(context, 28),
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text: 'pt',
                          style: TextStyle(
                            fontFamily: 'SFProRounded',
                            fontSize: AppResponsive.font(context, 16),
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppResponsive.s(context, 6)),
                  Text(
                    bid.timestamp,
                    style: TextStyle(
                      fontFamily: 'SFProRounded',
                      fontSize: AppResponsive.font(context, 11),
                      color: Colors.white.withOpacity(0.7),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Semi-transparent vertical divider ─────────────────────────
          Container(
            width: 1,
            height: AppResponsive.s(context, 70),
            color: Colors.white.withOpacity(0.3),
          ),

          // ── Team + owner ──────────────────────────────────────────────
          Expanded(
            flex: 3,
            child: Padding(
              padding: AppResponsive.padding(context, all: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bid.teamName,
                    style: TextStyle(
                      fontFamily: 'SFProRounded',
                      fontSize: AppResponsive.font(context, 17),
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: AppResponsive.s(context, 4)),
                  Text(
                    bid.ownerName,
                    style: TextStyle(
                      fontFamily: 'SFProRounded',
                      fontSize: AppResponsive.font(context, 13),
                      color: Colors.white.withOpacity(0.75),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
