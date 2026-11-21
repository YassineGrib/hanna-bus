import 'package:flutter/material.dart';
import '../theme/hanna_tokens.dart';

enum HannaBackgroundVariant { ambient, sweep, orbital, horizon, auth, dense }

class HannaBackground extends StatelessWidget {
  const HannaBackground({
    super.key,
    required this.child,
    this.variant = HannaBackgroundVariant.ambient,
  });

  final Widget child;
  final HannaBackgroundVariant variant;

  @override
  Widget build(BuildContext context) {
    final tokens = HannaTokens.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return ColoredBox(
      color: tokens.background,
      child: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _FigCraftBackgroundPainter(
                  tokens: tokens,
                  isRtl: isRtl,
                  variant: variant,
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _FigCraftBackgroundPainter extends CustomPainter {
  const _FigCraftBackgroundPainter({
    required this.tokens,
    required this.isRtl,
    required this.variant,
  });

  final HannaTokens tokens;
  final bool isRtl;
  final HannaBackgroundVariant variant;

  @override
  void paint(Canvas canvas, Size size) {
    const designW = 393.0;
    const designH = 852.0;

    final scaleX = size.width / designW;
    final scaleY = size.height / designH;
    final s = scaleX;

    canvas.save();
    canvas.clipRect(Offset.zero & size);

    double ax(double x, double w) => isRtl ? (designW - x - w) : x;

    void drawBlob(
      double x,
      double y,
      double w,
      double h,
      Color color,
      List<int> alphaStops,
    ) {
      final actualX = ax(x, w) * s;
      final actualY = y * scaleY;
      final actualW = w * s;
      final actualH = h * s;

      final rect = Rect.fromLTWH(actualX, actualY, actualW, actualH);

      final gradient = RadialGradient(
        stops: const [0.0, 0.5, 1.0],
        colors: [
          color.withValues(alpha: alphaStops[0] / 255.0),
          color.withValues(alpha: alphaStops[1] / 255.0),
          color.withValues(alpha: 0.0),
        ],
      );

      final paint = Paint()..shader = gradient.createShader(rect);
      canvas.drawOval(rect, paint);
    }

    void drawRing(
      double x,
      double y,
      double diam,
      Color color,
      double opacity, [
      double sw = 1.0,
    ]) {
      final actualX = ax(x, diam) * s;
      final actualY = y * scaleY;
      final actualDiam = diam * s;

      final rect = Rect.fromLTWH(actualX, actualY, actualDiam, actualDiam);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw * s
        ..color = color.withValues(alpha: opacity);

      canvas.drawOval(rect, paint);
    }

    void drawWave({
      required double y,
      required double h,
      required Color color,
      required double opacity,
      required Path Function(double w, double h) builder,
    }) {
      final actualY = (y / designH) * size.height;
      final actualH = (h / designH) * size.height;

      final p = builder(size.width, actualH);
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = color.withValues(alpha: opacity);

      canvas.save();
      canvas.translate(0, actualY);
      canvas.drawPath(p, paint);
      canvas.restore();
    }

    final effectiveVariant = (variant == HannaBackgroundVariant.auth)
        ? HannaBackgroundVariant.ambient
        : (variant == HannaBackgroundVariant.dense
              ? HannaBackgroundVariant.orbital
              : variant);

    switch (effectiveVariant) {
      case HannaBackgroundVariant.ambient:
        // Top Glow
        drawBlob(185, -95, 290, 290, tokens.accent, [0x50, 0x1A, 0x00]);
        // Top Rings
        drawRing(230, -55, 200, tokens.actionPrimary, 0.11, 1.0);
        drawRing(200, -85, 260, tokens.actionPrimary, 0.07, 1.0);
        // Bottom Glow
        drawBlob(-90, 560, 260, 260, tokens.border, [0x70, 0x24, 0x00]);
        // Bottom Wave: "M0,85 C105,15 245,115 393,30 L393,170 L0,170 Z"
        drawWave(
          y: 682,
          h: 170,
          color: tokens.accent,
          opacity: 0.14,
          builder: (w, h) {
            final path = Path();
            if (!isRtl) {
              path.moveTo(0, h * (85 / 170));
              path.cubicTo(
                w * (105 / 393),
                h * (15 / 170),
                w * (245 / 393),
                h * (115 / 170),
                w,
                h * (30 / 170),
              );
              path.lineTo(w, h);
              path.lineTo(0, h);
              path.close();
            } else {
              path.moveTo(w, h * (85 / 170));
              path.cubicTo(
                w * (1 - 105 / 393),
                h * (15 / 170),
                w * (1 - 245 / 393),
                h * (115 / 170),
                0,
                h * (30 / 170),
              );
              path.lineTo(0, h);
              path.lineTo(w, h);
              path.close();
            }
            return path;
          },
        );
        break;

      case HannaBackgroundVariant.sweep:
        drawBlob(-75, -75, 270, 270, tokens.accent, [0x48, 0x18, 0x00]);
        drawWave(
          y: 0,
          h: 130,
          color: tokens.border,
          opacity: 0.30,
          builder: (w, h) {
            final path = Path();
            if (!isRtl) {
              path.moveTo(0, 0);
              path.lineTo(w, 0);
              path.lineTo(w, h * (75 / 130));
              path.cubicTo(
                w * (265 / 393),
                h * (145 / 130),
                w * (130 / 393),
                h * (30 / 130),
                0,
                h * (115 / 130),
              );
              path.close();
            } else {
              path.moveTo(w, 0);
              path.lineTo(0, 0);
              path.lineTo(0, h * (75 / 130));
              path.cubicTo(
                w * (1 - 265 / 393),
                h * (145 / 130),
                w * (1 - 130 / 393),
                h * (30 / 130),
                w,
                h * (115 / 130),
              );
              path.close();
            }
            return path;
          },
        );
        drawBlob(195, 600, 270, 270, tokens.actionPrimary, [0x1C, 0x08, 0x00]);
        drawRing(250, 650, 170, tokens.accent, 0.25);
        drawRing(225, 625, 220, tokens.actionPrimary, 0.08);
        break;

      case HannaBackgroundVariant.orbital:
        drawBlob(46, -90, 300, 250, tokens.accent, [0x44, 0x16, 0x00]);
        drawRing(56, -135, 280, tokens.actionPrimary, 0.09);
        drawRing(26, -165, 340, tokens.actionPrimary, 0.06);
        drawBlob(195, 620, 260, 260, tokens.accent, [0x36, 0x12, 0x00]);
        drawWave(
          y: 687,
          h: 165,
          color: tokens.border,
          opacity: 0.35,
          builder: (w, h) {
            final path = Path();
            if (!isRtl) {
              path.moveTo(0, h * (110 / 165));
              path.cubicTo(
                w * (130 / 393),
                h * (30 / 165),
                w * (270 / 393),
                h * (120 / 165),
                w,
                h * (45 / 165),
              );
              path.lineTo(w, h);
              path.lineTo(0, h);
              path.close();
            } else {
              path.moveTo(w, h * (110 / 165));
              path.cubicTo(
                w * (1 - 130 / 393),
                h * (30 / 165),
                w * (1 - 270 / 393),
                h * (120 / 165),
                0,
                h * (45 / 165),
              );
              path.lineTo(0, h);
              path.lineTo(w, h);
              path.close();
            }
            return path;
          },
        );
        break;

      case HannaBackgroundVariant.horizon:
        drawBlob(195, -75, 260, 260, tokens.actionPrimary, [0x1E, 0x08, 0x00]);
        drawRing(235, -55, 190, tokens.accent, 0.30);
        drawBlob(-85, 250, 260, 260, tokens.accent, [0x3C, 0x14, 0x00]);
        drawWave(
          y: 687,
          h: 165,
          color: tokens.accent,
          opacity: 0.14,
          builder: (w, h) {
            final path = Path();
            if (!isRtl) {
              path.moveTo(0, h * (65 / 165));
              path.cubicTo(
                w * (140 / 393),
                h * (120 / 165),
                w * (260 / 393),
                h * (10 / 165),
                w,
                h * (65 / 165),
              );
              path.lineTo(w, h);
              path.lineTo(0, h);
              path.close();
            } else {
              path.moveTo(w, h * (65 / 165));
              path.cubicTo(
                w * (1 - 140 / 393),
                h * (120 / 165),
                w * (1 - 260 / 393),
                h * (10 / 165),
                0,
                h * (65 / 165),
              );
              path.lineTo(0, h);
              path.lineTo(w, h);
              path.close();
            }
            return path;
          },
        );
        break;

      default:
        break;
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FigCraftBackgroundPainter oldDelegate) {
    return oldDelegate.tokens != tokens ||
        oldDelegate.isRtl != isRtl ||
        oldDelegate.variant != variant;
  }
}
