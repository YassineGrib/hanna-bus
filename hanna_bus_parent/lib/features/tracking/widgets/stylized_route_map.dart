import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/hanna_tokens.dart';
import '../../../core/theme/hanna_typography.dart';

class StylizedRouteMap extends StatelessWidget {
  const StylizedRouteMap({
    super.key,
    required this.progress,
    required this.busNumber,
    required this.streetLabel,
    this.speedKmh = 38,
    this.waypoints = const [
      Offset(0.14, 0.78),
      Offset(0.36, 0.56),
      Offset(0.60, 0.44),
      Offset(0.84, 0.22),
    ],
    this.height = 320,
    this.replayMode = false,
    this.homeStopLabel = 'Hay El Nasr (07:16)',
    this.schoolStopLabel = 'El Wiam School (ETA 07:40)',
    this.onRecenter,
  });

  final double progress;
  final String busNumber;
  final String streetLabel;
  final int speedKmh;
  final List<Offset> waypoints;
  final double height;
  final bool replayMode;
  final String homeStopLabel;
  final String schoolStopLabel;
  final VoidCallback? onRecenter;

  @override
  Widget build(BuildContext context) {
    final t = HannaTokens.of(context);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: t.mapBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: t.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(
              painter: _CityMapPainter(
                tokens: t,
                progress: progress,
                waypoints: waypoints,
                replayMode: replayMode,
              ),
            ),

            // Origin Home Stop Tag (bottom-left)
            Positioned(
              left: 14,
              bottom: replayMode ? 54 : 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: t.surface,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: t.border),
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(0, 2),
                      blurRadius: 6,
                      color: t.text.withValues(alpha: 0.06),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.mapPin, size: 13, color: t.text),
                    const SizedBox(width: 5),
                    Text(
                      homeStopLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: t.text,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Destination School Tag (top-right)
            Positioned(
              right: 14,
              top: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: t.surface,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: t.border),
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(0, 2),
                      blurRadius: 6,
                      color: t.text.withValues(alpha: 0.06),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.graduationCap, size: 13, color: t.actionPrimary),
                    const SizedBox(width: 5),
                    Text(
                      schoolStopLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: t.text,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Live GPS Pill (top-left) - shown when not in replay mode
            if (!replayMode)
              Positioned(
                left: 14,
                top: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: t.surface,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: t.border),
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(0, 2),
                        blurRadius: 6,
                        color: t.text.withValues(alpha: 0.06),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: t.actionDestructive,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'LIVE GPS · 4s ago',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: t.text,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Recenter Compass Button (bottom-right) - shown when not in replay mode
            if (!replayMode)
              Positioned(
                right: 14,
                bottom: 14,
                child: GestureDetector(
                  onTap: onRecenter,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: t.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: t.border),
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(0, 2),
                          blurRadius: 8,
                          color: t.text.withValues(alpha: 0.1),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(LucideIcons.compass, size: 18, color: t.text),
                    ),
                  ),
                ),
              ),

            // Replay Player Bar (bottom) - shown in replay mode
            if (replayMode)
              Positioned(
                left: 14,
                right: 14,
                bottom: 12,
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: t.text,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Icon(LucideIcons.play, size: 16, color: t.surface),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: 0.72,
                            backgroundColor: t.heroAccent,
                            valueColor: AlwaysStoppedAnimation<Color>(t.actionPrimary),
                            minHeight: 4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '24:10',
                        style: HannaTypography.mono(
                          size: 11,
                          weight: FontWeight.w700,
                          color: t.surface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CityMapPainter extends CustomPainter {
  const _CityMapPainter({
    required this.tokens,
    required this.progress,
    required this.waypoints,
    required this.replayMode,
  });

  final HannaTokens tokens;
  final double progress;
  final List<Offset> waypoints;
  final bool replayMode;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Urban green park blocks (#DDE7DC style)
    final parkPaint = Paint()..color = const Color(0xFFDDE7DC);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.08, h * 0.08, w * 0.28, h * 0.24),
        const Radius.circular(14),
      ),
      parkPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.65, h * 0.62, w * 0.28, h * 0.26),
        const Radius.circular(14),
      ),
      parkPaint,
    );

    // 2. City building blocks (#E6E1D2 style)
    final blockPaint = Paint()..color = const Color(0xFFE6E1D2);
    final blocks = [
      Rect.fromLTWH(w * 0.40, h * 0.08, w * 0.30, h * 0.18),
      Rect.fromLTWH(w * 0.10, h * 0.40, w * 0.28, h * 0.24),
      Rect.fromLTWH(w * 0.48, h * 0.35, w * 0.46, h * 0.22),
    ];
    for (final b in blocks) {
      canvas.drawRRect(RRect.fromRectAndRadius(b, const Radius.circular(10)), blockPaint);
    }

    // 3. White arterial roads
    final roadPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Horizontal roads
    canvas.drawRect(Rect.fromLTWH(0, h * 0.30, w, 14), roadPaint);
    canvas.drawRect(Rect.fromLTWH(0, h * 0.68, w, 12), roadPaint);
    // Vertical roads
    canvas.drawRect(Rect.fromLTWH(w * 0.36, 0, 14, h), roadPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.72, 0, 12, h), roadPaint);

    // 4. Route Polyline connecting Origin -> Waypoints -> Destination
    final pts = waypoints.length >= 2
        ? waypoints
        : const [
            Offset(0.18, 0.82),
            Offset(0.38, 0.68),
            Offset(0.55, 0.42),
            Offset(0.74, 0.32),
            Offset(0.86, 0.18),
          ];

    final scaled = pts.map((p) => Offset(p.dx * w, p.dy * h)).toList();

    final routePath = Path()..moveTo(scaled.first.dx, scaled.first.dy);
    for (var i = 1; i < scaled.length; i++) {
      final prev = scaled[i - 1];
      final curr = scaled[i];
      final mid = Offset((prev.dx + curr.dx) / 2, (prev.dy + curr.dy) / 2);
      routePath.quadraticBezierTo(prev.dx, prev.dy, mid.dx, mid.dy);
    }
    routePath.lineTo(scaled.last.dx, scaled.last.dy);

    // Full corridor background line
    canvas.drawPath(
      routePath,
      Paint()
        ..color = tokens.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Active route line in PRIMARY (actionPrimary)
    final metric = routePath.computeMetrics().firstOrNull;
    Offset busPos = scaled[scaled.length ~/ 2];
    if (metric != null) {
      final frac = (replayMode ? 1.0 : progress).clamp(0.05, 1.0);
      final doneLen = metric.length * frac;
      final sub = metric.extractPath(0, doneLen);
      canvas.drawPath(
        sub,
        Paint()
          ..color = tokens.actionPrimary
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
      final tangent = metric.getTangentForOffset(doneLen);
      if (tangent != null) {
        busPos = tangent.position;
      }
    }

    // Origin Pin (Home)
    _drawStopPin(canvas, scaled.first, tokens.surface, tokens.actionPrimary, isSchool: false);

    // Destination Pin (School)
    _drawStopPin(canvas, scaled.last, tokens.actionPrimary, tokens.surface, isSchool: true);

    if (!replayMode) {
      // Live Pulsing Halo around Bus
      canvas.drawCircle(
        busPos,
        24,
        Paint()..color = tokens.actionPrimary.withValues(alpha: 0.22),
      );
      // Bus Badge Circle
      canvas.drawCircle(
        busPos,
        14,
        Paint()..color = tokens.text,
      );
      canvas.drawCircle(
        busPos,
        14,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      // Inner dot
      canvas.drawCircle(
        busPos,
        5,
        Paint()..color = tokens.actionPrimary,
      );
    }
  }

  void _drawStopPin(
    Canvas canvas,
    Offset center,
    Color bg,
    Color border, {
    required bool isSchool,
  }) {
    canvas.drawCircle(center, 12, Paint()..color = bg);
    canvas.drawCircle(
      center,
      12,
      Paint()
        ..color = border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    canvas.drawCircle(
      center,
      5,
      Paint()..color = border,
    );
  }

  @override
  bool shouldRepaint(covariant _CityMapPainter oldDelegate) {
    return oldDelegate.tokens != tokens ||
        oldDelegate.progress != progress ||
        oldDelegate.replayMode != replayMode;
  }
}

extension _IterableFirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;
    return iterator.current;
  }
}
