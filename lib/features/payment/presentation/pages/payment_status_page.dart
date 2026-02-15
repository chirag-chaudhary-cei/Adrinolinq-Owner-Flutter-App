import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors_new.dart';
import '../../../../core/theme/app_responsive.dart';
import '../../../../core/widgets/event_card.dart';
import '../../../../core/routing/app_router.dart';
import '../../../my_tournament/presentation/providers/my_tournament_providers.dart';

enum PaymentStatus {
  success,
  failed,
  pending,
}

class PaymentStatusPage extends ConsumerStatefulWidget {
  final PaymentStatus status;
  final EventModel? event;
  final int? tournamentId;

  const PaymentStatusPage({
    super.key,
    this.status = PaymentStatus.success,
    this.event,
    this.tournamentId,
  });

  @override
  ConsumerState<PaymentStatusPage> createState() => _PaymentStatusPageState();
}

class _PaymentStatusPageState extends ConsumerState<PaymentStatusPage>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                EdgeInsets.symmetric(vertical: AppResponsive.p(context, 8)),
            child: Column(
              children: [
                SizedBox(height: AppResponsive.p(context, 24)),
                // Illustration
                Center(
                  child: SizedBox(
                    height: 300,
                    width: 300,
                    child: _getStatusImage(),
                  ),
                ),
                const SizedBox(height: 32),

                // Status Card
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _getStatusTitle(),
                          style: TextStyle(
                            color: _getStatusTextColor(),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'SFProRounded',
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (!_expanded) ...[
                          const Text(
                            'Join the most prestigious badminton tournament of the season. Experience world-class competition and connect with elite players.',
                            style: TextStyle(
                              color: AppColors.textTertiaryLight,
                              fontSize: 14,
                              height: 1.5,
                              fontFamily: 'SFProRounded',
                            ),
                          ),
                        ] else ...[
                          const SizedBox(height: 8),
                          const Text(
                            'Transaction ID',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'SFProRounded',
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '548451515841518152',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                              fontFamily: 'SFProRounded',
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Tournament ID',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'SFProRounded',
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '548451515841518152',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                              fontFamily: 'SFProRounded',
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Tournament Name',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'SFProRounded',
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Elite Badminton Championship',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                              fontFamily: 'SFProRounded',
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Description',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'SFProRounded',
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Join the most prestigious badminton tournament of the season. Experience world-class competition and connect with elite players.',
                            style: TextStyle(
                              color: AppColors.textTertiaryLight,
                              fontSize: 14,
                              height: 1.5,
                              fontFamily: 'SFProRounded',
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        const _DashedLine(),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: () => setState(() => _expanded = !_expanded),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _expanded ? 'View Less' : 'View More',
                                  style: TextStyle(
                                    color: _getStatusTextColor(),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'SFProRounded',
                                  ),
                                ),
                                const SizedBox(width: 4),
                                RotatedBox(
                                  quarterTurns: _expanded ? 2 : 0,
                                  child: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: _getStatusTextColor(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: AppResponsive.p(context, 48)),

                // Action Button
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (widget.status == PaymentStatus.success) {
                          if (widget.event != null) {
                            try {
                              ref.invalidate(myTournamentRegistrationsProvider);
                              await ref.read(
                                myTournamentRegistrationsProvider.future,
                              );
                              if (!mounted) return;
                              Navigator.pushReplacementNamed(
                                context,
                                AppRouter.registeredTournamentDetail,
                                arguments: widget.event,
                              );
                            } catch (e) {
                              if (mounted) {
                                Navigator.pushReplacementNamed(
                                  context,
                                  AppRouter.registeredTournamentDetail,
                                  arguments: widget.event,
                                );
                              }
                            }
                          } else {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              AppRouter.home,
                              (route) => false,
                            );
                          }
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getButtonColor(),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _getButtonText(),
                        style: TextStyle(
                          color: widget.status == PaymentStatus.success
                              ? Colors.black
                              : Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'SFProRounded',
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getStatusImage() {
    switch (widget.status) {
      case PaymentStatus.success:
        return Image.asset(
          'assets/images/payment-success.png',
          height: 300,
          width: 300,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Icon(Icons.check_circle_outline,
                size: 100, color: AppColors.success),
          ),
        );
      case PaymentStatus.failed:
        return Image.asset(
          'assets/images/payment-fail.png',
          height: 300,
          width: 300,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Icon(Icons.error_outline, size: 100, color: AppColors.error),
          ),
        );
      case PaymentStatus.pending:
        return Image.asset(
          'assets/images/payment-pending.png',
          height: 300,
          width: 300,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Icon(Icons.schedule, size: 100, color: AppColors.warning),
          ),
        );
    }
  }

  Color _getStatusColor() {
    switch (widget.status) {
      case PaymentStatus.success:
        return AppColors.success;
      case PaymentStatus.failed:
        return AppColors.error;
      case PaymentStatus.pending:
        return AppColors.warning;
    }
  }

  Color _getStatusTextColor() {
    switch (widget.status) {
      case PaymentStatus.success:
        return const Color(0xFF004EA6);
      case PaymentStatus.failed:
        return AppColors.error;
      case PaymentStatus.pending:
        return AppColors.warning;
    }
  }

  String _getStatusTitle() {
    switch (widget.status) {
      case PaymentStatus.success:
        return 'Payment Successful!';
      case PaymentStatus.failed:
        return 'Payment Failed!! Try again';
      case PaymentStatus.pending:
        return 'Payment Pending';
    }
  }

  Color _getButtonColor() {
    switch (widget.status) {
      case PaymentStatus.success:
        return AppColors.primary;
      case PaymentStatus.failed:
        return AppColors.error;
      case PaymentStatus.pending:
        return AppColors.warning;
    }
  }

  String _getButtonText() {
    switch (widget.status) {
      case PaymentStatus.success:
        return 'Go to Tournament';
      case PaymentStatus.failed:
        return 'Try Again !';
      case PaymentStatus.pending:
        return 'Check Status';
    }
  }
}

class _DashedLine extends StatelessWidget {
  const _DashedLine();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 4.0;
        const dashHeight = 1.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return const SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.black26),
              ),
            );
          }),
        );
      },
    );
  }
}
