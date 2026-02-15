import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_responsive.dart';
import '../theme/app_animations.dart';

/// Reusable sport selection card widget with selected state glow effect
class SportSelectionCard extends StatefulWidget {
  const SportSelectionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final Widget icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<SportSelectionCard> createState() => _SportSelectionCardState();
}

class _SportSelectionCardState extends State<SportSelectionCard> {
  @override
  Widget build(BuildContext context) {
    final borderRadius = AppResponsive.radius(context, 28);
    final innerBorderRadius = AppResponsive.radius(context, 14);
    final iconContainerSize = AppResponsive.s(context, 48);
    final glowSize = AppResponsive.s(context, 100);

    return GestureDetector(
        onTap: widget.onTap,
        child: AspectRatio(
          aspectRatio: 1.0, // Square shape as requested
          child: AnimatedContainer(
            duration: AppDurations.normal,
            curve: AppCurves.standard,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              // Base color/Image logic
              color: widget.isSelected
                  ? null // Image provided by decoration image
                  : const Color(0xFF1E1A2E).withValues(alpha: 0.6),
              image: widget.isSelected
                  ? const DecorationImage(
                      image:
                          AssetImage('assets/images/sportCardBackground.png'),
                      fit: BoxFit.fill,
                    )
                  : null,
              gradient: widget.isSelected
                  ? null // Image used
                  : const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF2A2640),
                        Color(0xFF1E1A2E),
                      ],
                    ),
              boxShadow: widget.isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF7F2BFF).withValues(alpha: 0.2),
                        blurRadius: AppResponsive.s(context, glowSize / 4),
                        spreadRadius: AppResponsive.s(context, glowSize / 15),
                        offset:
                            Offset(0, AppResponsive.s(context, glowSize / 5)),
                      ),
                    ]
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                child: CustomPaint(
                  // Original inner shadow painter for card depth
                  painter: _SportCardInnerShadowPainter(
                    isSelected: widget.isSelected,
                    borderRadius: borderRadius,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(borderRadius),
                      border: Border.all(
                        color: widget.isSelected
                            ? Colors.white.withValues(alpha: 0)
                            : Colors.white.withValues(alpha: 0.05),
                        width: AppResponsive.thickness(context, 1),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Inner icon container
                        CustomPaint(
                          painter: widget.isSelected
                              ? null
                              : _GradientBorderPainter(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color.fromRGBO(127, 43, 255, 0.5),
                                      Color.fromRGBO(162, 89, 255, 0.5),
                                    ],
                                  ),
                                  width: AppResponsive.thickness(context, 1),
                                  radius: innerBorderRadius,
                                ),
                          child: Container(
                            width: iconContainerSize,
                            height: iconContainerSize,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(innerBorderRadius),
                              color: widget.isSelected
                                  ? Colors.white.withValues(alpha: 0.3)
                                  : const Color(0xFF1E0446)
                                      .withValues(alpha: 0.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(
                                AppResponsive.s(context, 10),
                              ),
                              child: widget.icon,
                            ),
                          ),
                        ),
                        SizedBox(height: AppResponsive.s(context, 12)),
                        // Label
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppResponsive.s(context, 4),
                          ),
                          child: Text(
                            widget.label,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: AppResponsive.font(context, 14),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),);
  }
}

/// Custom painter for inner shadow effect on the card
class _SportCardInnerShadowPainter extends CustomPainter {
  final bool isSelected;
  final double borderRadius;

  _SportCardInnerShadowPainter({
    required this.isSelected,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final RRect rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(borderRadius),
    );

    // Create a path for the inner shadow
    final Path path = Path()..addRRect(rrect);

    // Create a larger path to cut out for inner shadow
    final Path hole = Path()
      ..addRect(Rect.fromLTWH(-20, -20, size.width + 40, size.height + 40))
      ..addRRect(rrect)
      ..fillType = PathFillType.evenOdd;

    // Inner shadow paint - light from top-left
    final Paint shadowPaint = Paint()
      ..color = isSelected
          ? Colors.white.withValues(alpha: 0.25)
          : Colors.white.withValues(alpha: 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    canvas.save();
    canvas.clipPath(path);
    canvas.translate(-6, -6); // Light coming from top-left
    canvas.drawPath(hole, shadowPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SportCardInnerShadowPainter oldDelegate) {
    return oldDelegate.isSelected != isSelected ||
        oldDelegate.borderRadius != borderRadius;
  }
}

/// Painter for drawing a gradient border
class _GradientBorderPainter extends CustomPainter {
  final Gradient gradient;
  final double width;
  final double radius;

  _GradientBorderPainter({
    required this.gradient,
    required this.width,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final RRect rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final Paint paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _GradientBorderPainter oldDelegate) {
    return oldDelegate.gradient != gradient ||
        oldDelegate.width != width ||
        oldDelegate.radius != radius;
  }
}
