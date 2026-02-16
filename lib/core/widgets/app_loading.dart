import 'package:flutter/material.dart';
import '../theme/app_colors_new.dart';
import '../theme/app_responsive.dart';

/// Global loading widget system for consistent loading states across the app
/// Main colors: Accent Blue (#3B82F6) and White
class AppLoading {
  AppLoading._();

  // ============================================================
  // CIRCULAR LOADING INDICATORS
  // ============================================================

  /// Standard circular loading indicator - Accent Blue
  static Widget circular({
    double size = 40.0,
    double strokeWidth = 3.0,
    Color? color,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppColors.accentBlue,
        ),
        strokeCap: StrokeCap.round,
      ),
    );
  }

  /// Small circular loading indicator (for buttons, cards, etc.)
  static Widget circularSmall({
    double size = 20.0,
    double strokeWidth = 1.0,
    Color? color,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppColors.accentBlue,
        ),
        strokeCap: StrokeCap.round,
      ),
    );
  }

  /// Large circular loading indicator (for page loading)
  static Widget circularLarge({
    double size = 60.0,
    double strokeWidth = 4.0,
    Color? color,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppColors.accentBlue,
        ),
      ),
    );
  }

  /// White circular loading indicator (for dark backgrounds)
  static Widget circularWhite({
    double size = 40.0,
    double strokeWidth = 3.0,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }

  // ============================================================
  // CENTERED LOADING WIDGETS
  // ============================================================

  /// Centered circular loading indicator with optional message
  static Widget center({
    String? message,
    double size = 40.0,
    Color? color,
    TextStyle? messageStyle,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          circular(size: size, color: color),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: messageStyle ??
                  const TextStyle(
                    fontSize: 14,
                    color: AppColors.accentBlue,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  /// Centered loading for full page
  static Widget page({
    String? message,
    Color? backgroundColor,
  }) {
    return Container(
      color: backgroundColor ?? Colors.white,
      child: center(
        message: message,
        size: 48.0,
      ),
    );
  }

  // ============================================================
  // LINEAR PROGRESS INDICATORS
  // ============================================================

  /// Linear progress indicator with accent blue
  static Widget linear({
    double? value,
    double height = 4.0,
    Color? color,
    Color? backgroundColor,
    BorderRadius? borderRadius,
  }) {
    final indicator = LinearProgressIndicator(
      value: value,
      backgroundColor: backgroundColor ?? const Color(0xFFE8EAF6),
      valueColor: AlwaysStoppedAnimation<Color>(
        color ?? AppColors.accentBlue,
      ),
      minHeight: height,
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: indicator,
      );
    }

    return indicator;
  }

  /// Rounded linear progress indicator
  static Widget linearRounded({
    double? value,
    double height = 8.0,
    double borderRadius = 8.0,
    Color? color,
    Color? backgroundColor,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: LinearProgressIndicator(
        value: value,
        backgroundColor: backgroundColor ?? const Color(0xFFE8EAF6),
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppColors.accentBlue,
        ),
        minHeight: height,
      ),
    );
  }

  // ============================================================
  // LOADING DIALOGS
  // ============================================================

  /// Show loading dialog (non-dismissible)
  static void showDialog(
    BuildContext context, {
    String message = 'Loading...',
    bool barrierDismissible = false,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return PopScope(
          canPop: barrierDismissible,
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: _LoadingDialogContent(message: message),
          ),
        );
      },
    );
  }

  /// Dismiss loading dialog
  static void dismissDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  // ============================================================
  // OVERLAY LOADING
  // ============================================================

  /// Show loading overlay on top of content
  static Widget overlay({
    required Widget child,
    required bool isLoading,
    String? message,
    Color? overlayColor,
  }) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: overlayColor ?? Colors.black.withOpacity(0.3),
              child: center(
                message: message,
                size: 48.0,
                color: Colors.white,
                messageStyle: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // IMAGE PLACEHOLDER LOADING
  // ============================================================

  /// Loading placeholder for images with circular indicator
  static Widget imagePlaceholder({
    double? width,
    double? height,
    Color? backgroundColor,
    double indicatorSize = 24.0,
  }) {
    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? Colors.grey[200],
      child: Center(
        child: circular(
          size: indicatorSize,
          strokeWidth: 2.0,
          color: AppColors.accentBlue,
        ),
      ),
    );
  }

  /// Loading placeholder with white indicator (for dark backgrounds)
  static Widget imagePlaceholderDark({
    double? width,
    double? height,
    Color? backgroundColor,
    double indicatorSize = 24.0,
  }) {
    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? const Color(0xFF1A3A3A),
      child: Center(
        child: circularWhite(
          size: indicatorSize,
          strokeWidth: 2.0,
        ),
      ),
    );
  }

  // ============================================================
  // SHIMMER LOADING (SKELETON)
  // ============================================================

  /// Shimmer loading effect
  static Widget shimmer({
    required Widget child,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return _ShimmerLoading(
      baseColor: baseColor ?? Colors.grey[300]!,
      highlightColor: highlightColor ?? Colors.grey[100]!,
      child: child,
    );
  }

  /// Shimmer box (for skeleton screens)
  static Widget shimmerBox({
    double? width,
    double? height,
    BorderRadius? borderRadius,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return shimmer(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }

  // ============================================================
  // ADAPTIVE LOADING (Responsive)
  // ============================================================

  /// Responsive circular loading that adapts to screen size
  static Widget adaptive(
    BuildContext context, {
    String? message,
    bool small = false,
  }) {
    final size =
        small ? AppResponsive.s(context, 20) : AppResponsive.s(context, 40);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: small ? 2.0 : 3.0,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.accentBlue,
              ),
            ),
          ),
          if (message != null) ...[
            SizedBox(height: AppResponsive.s(context, 12)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppResponsive.font(context, 14),
                color: AppColors.accentBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // BUTTON LOADING
  // ============================================================

  /// Loading indicator for buttons
  static Widget button({
    double size = 20.0,
    Color? color,
  }) {
    return _SpinningArc(
      size: size,
      color: color ?? Colors.white,
    );
  }

  // ============================================================
  // DROPDOWN/LIST LOADING
  // ============================================================

  /// Loading indicator for dropdowns
  static Widget dropdown({String label = 'Loading...'}) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        circularSmall(size: 20.0, strokeWidth: 2.0),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

/// Custom spinning arc widget for visible loading animation
class _SpinningArc extends StatefulWidget {
  final double size;
  final Color color;

  const _SpinningArc({
    required this.size,
    required this.color,
  });

  @override
  State<_SpinningArc> createState() => _SpinningArcState();
}

class _SpinningArcState extends State<_SpinningArc>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: RotationTransition(
        turns: _controller,
        child: CustomPaint(
          painter: _ArcPainter(
            color: widget.color,
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// LOADING DIALOG CONTENT
// ============================================================

class _LoadingDialogContent extends StatelessWidget {
  const _LoadingDialogContent({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppResponsive.s(context, 32),
        vertical: AppResponsive.s(context, 32),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppResponsive.radius(context, 20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: AppResponsive.s(context, 48),
            height: AppResponsive.s(context, 48),
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.accentBlue,
              ),
            ),
          ),
          SizedBox(height: AppResponsive.s(context, 20)),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'SFProRounded',
              fontSize: AppResponsive.font(context, 16),
              fontWeight: FontWeight.w500,
              color: AppColors.accentBlue,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SHIMMER LOADING WIDGET
// ============================================================

class _ShimmerLoading extends StatefulWidget {
  const _ShimmerLoading({
    required this.child,
    required this.baseColor,
    required this.highlightColor,
  });

  final Widget child;
  final Color baseColor;
  final Color highlightColor;

  @override
  State<_ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<_ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: [
                0.0,
                0.5,
                1.0,
              ],
              transform: GradientRotation(_animation.value),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Custom painter for drawing a partial arc (3/4 circle)
class _ArcPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _ArcPainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw 270 degrees (3/4 of circle) starting from top
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2, // Start from top (-90 degrees)
      3.14159 * 1.5, // Draw 270 degrees (3/4 circle)
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}
