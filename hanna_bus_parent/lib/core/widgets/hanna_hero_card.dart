import 'package:flutter/material.dart';
import '../theme/hanna_tokens.dart';

class HannaHeroCard extends StatelessWidget {
  const HannaHeroCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(HannaSpace.lg),
    this.borderRadius = HannaRadius.xl,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final tokens = HannaTokens.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Container(
      decoration: BoxDecoration(
        color: tokens.heroSurface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: tokens.heroAccent.withValues(alpha: tokens.isDark ? 0.25 : 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: tokens.isDark ? 0.35 : 0.14),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _HeroAbstractPainter(tokens: tokens, isRtl: isRtl),
                ),
              ),
            ),
            Padding(
              padding: padding,
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroAbstractPainter extends CustomPainter {
  const _HeroAbstractPainter({
    required this.tokens,
    required this.isRtl,
  });

  final HannaTokens tokens;
  final bool isRtl;

  @override
  void paint(Canvas canvas, Size size) {
    double mx(double x) => isRtl ? size.width - x : x;

    // Stacked translucent corner arcs
    final outerCircle = Paint()
      ..color = tokens.heroAccent.withValues(alpha: 0.14)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(mx(size.width * 0.94), -size.height * 0.10), size.height * 0.52, outerCircle);

    final innerRing = Paint()
      ..color = tokens.onHero.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawCircle(Offset(mx(size.width * 0.94), -size.height * 0.10), size.height * 0.72, innerRing);

    // Diagonal transit band across bottom trailing edge
    final band = Path()
      ..moveTo(mx(size.width * 0.56), size.height)
      ..lineTo(mx(size.width * 0.88), size.height * 0.36)
      ..lineTo(mx(size.width * 1.04), size.height * 0.42)
      ..lineTo(mx(size.width * 0.72), size.height)
      ..close();
    canvas.drawPath(
      band,
      Paint()..color = tokens.heroAccent.withValues(alpha: 0.08),
    );

    // Subtle geometric waypoint arc
    final routeArc = Path()
      ..moveTo(mx(0), size.height * 0.82)
      ..quadraticBezierTo(
        mx(size.width * 0.36),
        size.height * 0.62,
        mx(size.width * 0.78),
        size.height * 0.88,
      );
    canvas.drawPath(
      routeArc,
      Paint()
        ..color = tokens.onHero.withValues(alpha: 0.07)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant _HeroAbstractPainter oldDelegate) {
    return oldDelegate.tokens != tokens || oldDelegate.isRtl != isRtl;
  }
}
