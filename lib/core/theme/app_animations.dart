import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Animation duration constants for consistent timing across the app
class AppDurations {
  AppDurations._();

  /// Extra fast animations (50ms) - micro interactions
  static const Duration microFast = Duration(milliseconds: 50);

  /// Fast animations (100ms) - button presses, quick feedback
  static const Duration buttonPress = Duration(milliseconds: 100);

  /// Quick animations (150ms) - small state changes
  static const Duration quick = Duration(milliseconds: 150);

  /// Normal animations (200ms) - standard transitions
  static const Duration normal = Duration(milliseconds: 200);

  /// Medium animations (300ms) - page transitions, modals
  static const Duration medium = Duration(milliseconds: 300);

  /// Slow animations (400ms) - complex animations
  static const Duration slow = Duration(milliseconds: 400);

  /// Extra slow animations (500ms) - elaborate effects
  static const Duration extraSlow = Duration(milliseconds: 500);

  /// Hero animations (600ms) - cross-page hero transitions
  static const Duration hero = Duration(milliseconds: 600);

  /// Stagger delay between items in lists
  static const Duration staggerDelay = Duration(milliseconds: 50);

  /// Ripple effect duration
  static const Duration ripple = Duration(milliseconds: 250);

  /// Tooltip show duration
  static const Duration tooltip = Duration(milliseconds: 1500);

  /// Snackbar duration
  static const Duration snackbar = Duration(seconds: 4);
}

/// Animation curves for smooth, consistent motion
class AppCurves {
  AppCurves._();

  /// Standard curve for most animations (Material Design 3 standard)
  static const Curve standard = Curves.easeInOutCubicEmphasized;

  /// Decelerate curve for entering elements
  static const Curve decelerate = Curves.easeOutCubic;

  /// Accelerate curve for exiting elements
  static const Curve accelerate = Curves.easeInCubic;

  /// Emphasized curve for attention-grabbing animations
  static const Curve emphasized = Curves.easeInOutCubicEmphasized;

  /// Emphasized decelerate for entering with emphasis
  static const Curve emphasizedDecelerate = Curves.easeOutQuint;

  /// Emphasized accelerate for exiting with emphasis
  static const Curve emphasizedAccelerate = Curves.easeInQuint;

  /// Bounce curve for playful interactions
  static const Curve bounce = Curves.bounceOut;

  /// Elastic curve for springy effects
  static const Curve elastic = Curves.elasticOut;

  /// Overshoot curve for exaggerated motion
  static const Curve overshoot = Curves.easeOutBack;

  /// Linear curve for constant speed
  static const Curve linear = Curves.linear;

  /// Fast out, slow in (legacy Material curve)
  static const Curve fastOutSlowIn = Curves.fastOutSlowIn;

  /// Smooth step for gradual transitions
  static const Curve smoothStep = Curves.easeInOut;

  /// Spring curve simulation
  static Curve get spring => const _SpringCurve();
}

/// Custom spring curve for natural motion
class _SpringCurve extends Curve {
  const _SpringCurve();

  @override
  double transformInternal(double t) {
    // Critically damped spring simulation
    const c = 3.0;
    final value = 1.0 - (1.0 + c * t) * math.exp(-c * t);
    return value.clamp(0.0, 1.0);
  }
}

/// Extension for easy animation creation
extension AnimationExtensions on Duration {
  /// Create an animation controller with this duration
  AnimationController controller(TickerProvider vsync, {bool repeat = false}) {
    final controller = AnimationController(duration: this, vsync: vsync);
    if (repeat) controller.repeat();
    return controller;
  }
}

/// Animation presets for common use cases
class AppAnimations {
  AppAnimations._();

  /// Fade in animation tween
  static Tween<double> get fadeIn => Tween<double>(begin: 0.0, end: 1.0);

  /// Fade out animation tween
  static Tween<double> get fadeOut => Tween<double>(begin: 1.0, end: 0.0);

  /// Scale up animation tween
  static Tween<double> get scaleUp => Tween<double>(begin: 0.8, end: 1.0);

  /// Scale down animation tween (for press effects)
  static Tween<double> get scaleDown => Tween<double>(begin: 1.0, end: 0.95);

  /// Slide up animation
  static Tween<Offset> get slideUp => Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      );

  /// Slide down animation
  static Tween<Offset> get slideDown => Tween<Offset>(
        begin: const Offset(0, -0.3),
        end: Offset.zero,
      );

  /// Slide left animation
  static Tween<Offset> get slideLeft => Tween<Offset>(
        begin: const Offset(0.3, 0),
        end: Offset.zero,
      );

  /// Slide right animation
  static Tween<Offset> get slideRight => Tween<Offset>(
        begin: const Offset(-0.3, 0),
        end: Offset.zero,
      );

  /// Rotation animation (full turn)
  static Tween<double> get rotate => Tween<double>(begin: 0, end: 1);

  /// Half rotation animation
  static Tween<double> get rotateHalf => Tween<double>(begin: 0, end: 0.5);

  /// Color transition between two colors
  static ColorTween colorTransition(Color begin, Color end) =>
      ColorTween(begin: begin, end: end);
}

/// Page transition builders
class AppPageTransitions {
  AppPageTransitions._();

  /// Fade transition
  static Widget fadeTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation.drive(CurveTween(curve: AppCurves.standard)),
      child: child,
    );
  }

  /// Slide up transition
  static Widget slideUpTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: AppCurves.emphasized,
      ),),
      child: child,
    );
  }

  /// Slide horizontal transition
  static Widget slideHorizontalTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: AppCurves.emphasized,
      ),),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  /// Scale and fade transition
  static Widget scaleTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.9,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: AppCurves.emphasized,
      ),),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
}

/// Staggered animation helper
class StaggeredAnimation {
  StaggeredAnimation({
    required this.itemCount,
    required this.controller,
    this.itemDelay = 0.1,
  });

  final int itemCount;
  final AnimationController controller;
  final double itemDelay;

  /// Get animation for item at index
  Animation<double> animationForIndex(int index) {
    final startInterval = (index * itemDelay).clamp(0.0, 0.9);
    final endInterval = (startInterval + 0.3).clamp(0.0, 1.0);

    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          startInterval,
          endInterval,
          curve: AppCurves.emphasizedDecelerate,
        ),
      ),
    );
  }
}
