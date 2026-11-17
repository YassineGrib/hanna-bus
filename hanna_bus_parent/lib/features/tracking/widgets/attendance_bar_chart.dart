import 'package:flutter/material.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/state/models.dart';
import '../../../core/theme/hanna_tokens.dart';

class AttendanceBarChart extends StatelessWidget {
  const AttendanceBarChart({
    super.key,
    required this.points,
    required this.morningLabel,
    required this.returnLabel,
  });

  final List<WeeklyRegularityPoint> points;
  final String morningLabel;
  final String returnLabel;

  String _formatDay(BuildContext context, String rawDay) {
    final s = AppStrings.of(context);
    switch (rawDay.toLowerCase()) {
      case 'sun':
        return s.chDSun;
      case 'mon':
        return s.chDMon;
      case 'tue':
        return s.chDTue;
      case 'wed':
        return s.chDWed;
      case 'thu':
        return s.chDThu;
      default:
        return rawDay.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = HannaTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _LegendDot(color: t.actionPrimary, label: morningLabel),
            const SizedBox(width: 16),
            _LegendDot(color: t.accent, label: returnLabel),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 156,
          child: Stack(
            children: [
              // Horizontal reference grid lines
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(4, (_) {
                      return Container(
                        height: 1,
                        color: t.border.withValues(alpha: 0.5),
                      );
                    }),
                  ),
                ),
              ),
              // Bars
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: points.map((p) {
                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _BarColumn(fraction: p.morning, color: t.actionPrimary),
                              const SizedBox(width: 6),
                              _BarColumn(fraction: p.returnTrip, color: t.accent),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatDay(context, p.day),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: t.text,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BarColumn extends StatelessWidget {
  const _BarColumn({required this.fraction, required this.color});
  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final clamped = fraction.clamp(0.08, 1.0);
    return FractionallySizedBox(
      heightFactor: clamped,
      alignment: Alignment.bottomCenter,
      child: Container(
        width: 14,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = HannaTokens.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: t.textMuted,
          ),
        ),
      ],
    );
  }
}
