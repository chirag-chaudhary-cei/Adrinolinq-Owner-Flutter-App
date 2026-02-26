import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors_new.dart';
import '../../../../core/theme/app_responsive.dart';
import 'bid_model.dart';

/// Row widget for a single previous bid in the bid history list.
/// Shows a blue oval pill with the bid amount, timestamp below,
/// and team/owner info to the right.
class PreviousBidRow extends StatelessWidget {
  const PreviousBidRow({super.key, required this.bid});

  final BidModel bid;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: AppResponsive.padding(context, horizontal: 20, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Oval bid pill + timestamp ─────────────────────────────
              Column(
                children: [
                  Container(
                    width: AppResponsive.s(context, 60),
                    padding: AppResponsive.padding(context, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.accentBlue,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      '${bid.points}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'SFProRounded',
                        fontSize: AppResponsive.font(context, 16),
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: AppResponsive.s(context, 4)),
                  Text(
                    bid.timestamp,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'SFProRounded',
                      fontSize: AppResponsive.font(context, 10),
                      color: Colors.grey.shade500,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
              SizedBox(width: AppResponsive.s(context, 16)),

              // ── Team + owner ──────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bid.teamName,
                      style: TextStyle(
                        fontFamily: 'SFProRounded',
                        fontSize: AppResponsive.font(context, 15),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    SizedBox(height: AppResponsive.s(context, 3)),
                    Text(
                      bid.ownerName,
                      style: TextStyle(
                        fontFamily: 'SFProRounded',
                        fontSize: AppResponsive.font(context, 13),
                        color: AppColors.accentBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
          indent: AppResponsive.s(context, 20),
          endIndent: AppResponsive.s(context, 20),
          color: const Color(0xFF0A1217).withOpacity(0.08),
        ),
      ],
    );
  }
}
