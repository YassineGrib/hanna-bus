import 'package:flutter/material.dart';

/// Emil Kowalski motion tokens & widgets:
/// - Fast, crisp, sub-300ms transitions with exponential deceleration (`easeOutExpo`).
/// - GPU-only transforms and opacity; never `scale(0)`.
/// - Full `disableAnimationsOf(context)` accessibility compliance.
abstract final class HannaMotion {
  static const Curve easeOutExpo = Cubic(0.16, 1, 0.3, 1);
  static const Curve easeOutQuint = Cubic(0.22, 1, 0.36, 1);

  static const Duration durationFast = Duration(milliseconds: 110);
  static const Duration durationControl = Duration(milliseconds: 180);
  static const Duration durationRoute = Duration(milliseconds: 250);

  static const double pressScale = 0.97;
  static const double entryScale = 0.96;

  static Duration effectiveDuration(BuildContext context, Duration normal) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return Duration.zero;
    }
    return normal;
  }

  static PageRoute<T> route<T>(Widget page) {
    return PageRouteBuilder<T>(
      transitionDuration: durationRoute,
      reverseTransitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        if (MediaQuery.disableAnimationsOf(context)) {
          return child;
        }
        final curved = CurvedAnimation(
          parent: animation,
          curve: easeOutExpo,
          reverseCurve: easeOutQuint,
        );
        final isRtl = Directionality.of(context) == TextDirection.rtl;
        final beginOffset = Offset(isRtl ? -0.04 : 0.04, 0);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(begin: beginOffset, end: Offset.zero).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}

class HannaMotionEntrance extends StatefulWidget {
  const HannaMotionEntrance({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offsetY = 8,
    this.withScale = false,
  });

  final Widget child;
  final Duration delay;
  final double offsetY;
  final bool withScale;

  @override
  State<HannaMotionEntrance> createState() => _HannaMotionEntranceState();
}

class _HannaMotionEntranceState extends State<HannaMotionEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _curved;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: HannaMotion.durationRoute,
    );
    _curved = CurvedAnimation(parent: _controller, curve: HannaMotion.easeOutExpo);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
      return;
    }
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future<void>.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return widget.child;
    }
    return AnimatedBuilder(
      animation: _curved,
      child: widget.child,
      builder: (context, child) {
        final v = _curved.value;
        final dy = (1 - v) * widget.offsetY;
        final scale = widget.withScale
            ? HannaMotion.entryScale + (1 - HannaMotion.entryScale) * v
            : 1.0;
        return Opacity(
          opacity: v.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, dy),
            child: widget.withScale ? Transform.scale(scale: scale, child: child) : child,
          ),
        );
      },
    );
  }
}

class HannaPressable extends StatefulWidget {
  const HannaPressable({
    super.key,
    required this.child,
    this.onTap,
    this.enabled = true,
    this.borderRadius,
    this.semanticLabel,
    this.semanticButton = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool enabled;
  final BorderRadius? borderRadius;
  final String? semanticLabel;
  final bool semanticButton;

  @override
  State<HannaPressable> createState() => _HannaPressableState();
}

class _HannaPressableState extends State<HannaPressable> {
  bool _pressed = false;

  bool get _interactive => widget.enabled && widget.onTap != null;

  @override
  Widget build(BuildContext context) {
    final duration = HannaMotion.effectiveDuration(context, HannaMotion.durationFast);
    return Semantics(
      button: widget.semanticButton,
      enabled: _interactive,
      label: widget.semanticLabel,
      child: AnimatedScale(
        scale: _pressed && _interactive ? HannaMotion.pressScale : 1.0,
        duration: duration,
        curve: HannaMotion.easeOutExpo,
        child: Material(
          color: Colors.transparent,
          borderRadius: widget.borderRadius,
          child: InkWell(
            onTap: _interactive ? widget.onTap : null,
            borderRadius: widget.borderRadius,
            onHighlightChanged: (value) {
              if (!_interactive || !mounted) return;
              if (_pressed != value) {
                setState(() => _pressed = value);
              }
            },
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
