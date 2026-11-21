import 'package:latlong2/latlong.dart' show LatLng;
import 'live_route_map.dart';
import 'package:flutter/material.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/state/app_state.dart';
import '../../core/state/models.dart';
import '../../core/theme/hanna_tokens.dart';
import '../../core/widgets/driver_widgets.dart';
import '../home/home_shell.dart';

class NavigationContent extends StatelessWidget {
  const NavigationContent({super.key, required this.state});
  final DriverState state;
  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final stops = state.trip?.stations ?? <Station>[];
    final points = state.trip == null
        ? <LatLng>[]
        : LiveRouteMap.routeFor(state.trip!);
    final tokens = state.settings['glare_mode'] == 'auto'
        ? HannaTokens.of(context)
        : HannaTokens.forPalette(
            state.palette,
            state.settings['glare_mode'] == 'night'
                ? Brightness.dark
                : Brightness.light,
          );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(s.t('routeOverview')),
        Text(s.t('routeHint')),
        const SizedBox(height: 16),
        if (state.trip == null) Text(s.t('noTrips')),
        if (points.isNotEmpty)
          LiveRouteMap(
            key: ValueKey(state.trip!.id),
            points: points,
            stations: stops,
            position: state.lastPosition,
            tokens: tokens,
          ),
        if (points.isEmpty && stops.isNotEmpty) ...[
          Text(
            s.t('mapUnavailable'),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Semantics(
            label: s.t('routeOverview'),
            child: SizedBox(
              height: 240,
              child: CustomPaint(painter: RoutePainter(stops, tokens)),
            ),
          ),
        ],
        if (stops.isNotEmpty) ...[
          const SizedBox(height: 18),
          for (final stop in stops)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: StationCard(state: state, station: stop),
            ),
        ],
      ],
    );
  }
}

/// Plots the actual API stop coordinates. It does not invent road directions.
class RoutePainter extends CustomPainter {
  RoutePainter(this.stops, this.tokens);
  final List<Station> stops;
  final HannaTokens tokens;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(24)),
      Paint()..color = tokens.mapBg,
    );
    final points = stops.where((s) => validCoordinates(s.lat, s.lng)).toList();
    if (points.isEmpty) {
      final paint = Paint()
        ..color = tokens.actionPrimary
        ..strokeWidth = 4;
      canvas.drawLine(
        Offset(size.width / 2, 24),
        Offset(size.width / 2, size.height - 24),
        paint,
      );
      for (var i = 0; i < stops.length; i++) {
        final y = stops.length == 1
            ? size.height / 2
            : 24 + i * (size.height - 48) / (stops.length - 1);
        canvas.drawCircle(
          Offset(size.width / 2, y),
          10,
          Paint()..color = tokens.text,
        );
      }
      return;
    }
    if (points.isEmpty) return;
    final lats = points.map((s) => s.lat!).toList()..sort();
    final lngs = points.map((s) => s.lng!).toList()..sort();
    final latSpan = (lats.last - lats.first).abs();
    final lngSpan = (lngs.last - lngs.first).abs();
    final offsets = points
        .map(
          (s) => Offset(
            32 +
                (s.lng! - lngs.first) /
                    (lngSpan == 0 ? 1 : lngSpan) *
                    (size.width - 64),
            size.height -
                32 -
                (s.lat! - lats.first) /
                    (latSpan == 0 ? 1 : latSpan) *
                    (size.height - 64),
          ),
        )
        .toList();
    final path = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (final p in offsets.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = tokens.actionPrimary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeJoin = StrokeJoin.round,
    );
    for (var i = 0; i < offsets.length; i++) {
      canvas.drawCircle(
        offsets[i],
        12,
        Paint()
          ..color = points[i].status == 'completed'
              ? tokens.success
              : tokens.heroSurface,
      );
      canvas.drawCircle(offsets[i], 5, Paint()..color = tokens.heroAccent);
    }
  }

  @override
  bool shouldRepaint(covariant RoutePainter oldDelegate) =>
      oldDelegate.stops != stops || oldDelegate.tokens != tokens;
}
