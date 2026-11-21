import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/state/app_state.dart';
import '../../../core/state/demo_seed.dart';
import '../../../core/state/models.dart';
import '../../../core/theme/hanna_tokens.dart';
import '../../../core/theme/hanna_typography.dart';

class NonNetworkTileProvider extends TileProvider {
  NonNetworkTileProvider();

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    return MemoryImage(TileProvider.transparentImage);
  }
}

class LiveRouteMap extends StatefulWidget {
  const LiveRouteMap({
    super.key,
    required this.progress,
    required this.busNumber,
    required this.streetLabel,
    this.speedKmh = 38,
    this.height = 320,
    this.replayMode = false,
    this.homeStopLabel = '',
    this.schoolStopLabel = '',
    this.gpsLabel = '',
    this.onRecenter,
    this.location,
    this.routePoints,
    this.stations,
    this.tileProvider,
  });

  final double progress;
  final String busNumber;
  final String streetLabel;
  final int speedKmh;
  final double height;
  final bool replayMode;
  /// Localized overlay labels. An empty label hides its tag.
  final String homeStopLabel;
  final String schoolStopLabel;
  final String gpsLabel;
  final VoidCallback? onRecenter;
  final TripLocation? location;
  final List<LatLng>? routePoints;
  final List<TripStation>? stations;
  final TileProvider? tileProvider;

  /// Optional default tile provider for the application.
  static TileProvider? defaultTileProvider;

  @override
  State<LiveRouteMap> createState() => _LiveRouteMapState();
}

class _LiveRouteMapState extends State<LiveRouteMap> {
  late final MapController _mapController;
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  TileProvider _resolveTileProvider(BuildContext context) {
    if (widget.tileProvider != null) return widget.tileProvider!;
    final appState = AppStateScope.maybeOf(context);
    if (appState?.tileProvider != null) return appState!.tileProvider!;
    if (LiveRouteMap.defaultTileProvider != null) {
      return LiveRouteMap.defaultTileProvider!;
    }
    return NetworkTileProvider();
  }

  List<LatLng> get _effectiveRoutePoints {
    if (widget.routePoints != null && widget.routePoints!.isNotEmpty) {
      return widget.routePoints!;
    }
    return DemoSeed.demoRoutePoints;
  }

  LatLng _computeBusPosition(List<LatLng> points) {
    if (widget.location != null) {
      return LatLng(widget.location!.lat, widget.location!.lng);
    }
    if (points.isEmpty) {
      return const LatLng(36.7538, 3.0588);
    }
    if (points.length == 1) {
      return points.first;
    }
    final clamped = widget.progress.clamp(0.0, 1.0);
    if (clamped <= 0.0) return points.first;
    if (clamped >= 1.0) return points.last;

    const distance = Distance();
    final segmentDistances = <double>[];
    var totalDist = 0.0;
    for (var i = 0; i < points.length - 1; i++) {
      final d = distance.as(LengthUnit.Meter, points[i], points[i + 1]);
      segmentDistances.add(d);
      totalDist += d;
    }

    if (totalDist <= 0.0) return points.first;

    final targetDist = clamped * totalDist;
    var accumulated = 0.0;
    for (var i = 0; i < segmentDistances.length; i++) {
      final segDist = segmentDistances[i];
      if (accumulated + segDist >= targetDist || i == segmentDistances.length - 1) {
        final rem = targetDist - accumulated;
        final factor = segDist > 0 ? (rem / segDist).clamp(0.0, 1.0) : 0.0;
        final p1 = points[i];
        final p2 = points[i + 1];
        return LatLng(
          p1.latitude + factor * (p2.latitude - p1.latitude),
          p1.longitude + factor * (p2.longitude - p1.longitude),
        );
      }
      accumulated += segDist;
    }
    return points.last;
  }

  List<LatLng> _computeTraveledPoints(List<LatLng> points, LatLng busPos) {
    if (points.isEmpty) return const [];
    if (widget.replayMode || widget.progress >= 1.0) {
      return List<LatLng>.from(points);
    }
    if (widget.progress <= 0.0) return const [];

    const distance = Distance();
    final segmentDistances = <double>[];
    var totalDist = 0.0;
    for (var i = 0; i < points.length - 1; i++) {
      final d = distance.as(LengthUnit.Meter, points[i], points[i + 1]);
      segmentDistances.add(d);
      totalDist += d;
    }
    if (totalDist <= 0.0) return [points.first];

    final targetDist = widget.progress.clamp(0.0, 1.0) * totalDist;
    final traveled = <LatLng>[points.first];
    var accumulated = 0.0;
    for (var i = 0; i < segmentDistances.length; i++) {
      final segDist = segmentDistances[i];
      if (accumulated + segDist >= targetDist) {
        traveled.add(busPos);
        break;
      }
      accumulated += segDist;
      traveled.add(points[i + 1]);
    }
    return traveled;
  }

  List<LatLng> get _allFittedPoints {
    final pts = List<LatLng>.from(_effectiveRoutePoints);
    final busPos = _computeBusPosition(pts);
    pts.add(busPos);
    if (widget.stations != null) {
      for (final st in widget.stations!) {
        if (st.lat != null && st.lng != null) {
          pts.add(LatLng(st.lat!, st.lng!));
        }
      }
    }
    return pts;
  }

  void _recenter() {
    widget.onRecenter?.call();
    final pts = _allFittedPoints;
    if (pts.isNotEmpty && _isMapReady) {
      _mapController.fitCamera(
        CameraFit.coordinates(
          coordinates: pts,
          padding: const EdgeInsets.all(36),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = HannaTokens.of(context);
    final dir = Directionality.of(context);
    final routePts = _effectiveRoutePoints;
    final busPos = _computeBusPosition(routePts);
    final traveledPts = _computeTraveledPoints(routePts, busPos);
    final effectiveTileProvider = _resolveTileProvider(context);

    // Build stop markers
    final markers = <Marker>[];
    if (widget.stations != null && widget.stations!.isNotEmpty) {
      for (var i = 0; i < widget.stations!.length; i++) {
        final st = widget.stations![i];
        if (st.lat != null && st.lng != null) {
          final isFirst = i == 0;
          final isLast = i == widget.stations!.length - 1;
          markers.add(
            Marker(
              point: LatLng(st.lat!, st.lng!),
              width: 32,
              height: 32,
              alignment: Alignment.center,
              child: _buildStationMarker(t, st.status, isFirst: isFirst, isLast: isLast),
            ),
          );
        }
      }
    } else if (routePts.isNotEmpty) {
      markers.add(
        Marker(
          point: routePts.first,
          width: 32,
          height: 32,
          alignment: Alignment.center,
          child: _buildStationMarker(t, 'passed', isFirst: true, isLast: false),
        ),
      );
      if (routePts.length > 1) {
        markers.add(
          Marker(
            point: routePts.last,
            width: 32,
            height: 32,
            alignment: Alignment.center,
            child: _buildStationMarker(t, 'upcoming', isFirst: false, isLast: true),
          ),
        );
      }
    }

    // Bus marker
    markers.add(
      Marker(
        point: busPos,
        width: 46,
        height: 46,
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (!widget.replayMode)
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: t.actionPrimary.withValues(alpha: 0.24),
                ),
              ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: t.text,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, 2),
                    blurRadius: 6,
                    color: t.text.withValues(alpha: 0.25),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  LucideIcons.bus,
                  size: 14,
                  color: t.actionPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return Container(
      height: widget.height,
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
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCameraFit: CameraFit.coordinates(
                  coordinates: _allFittedPoints,
                  padding: const EdgeInsets.all(36),
                ),
                onMapReady: () {
                  if (mounted) setState(() => _isMapReady = true);
                },
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.hannabus.hanna_bus_parent',
                  tileProvider: effectiveTileProvider,
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePts,
                      color: t.border,
                      strokeWidth: 5.5,
                      strokeCap: StrokeCap.round,
                      strokeJoin: StrokeJoin.round,
                    ),
                    if (traveledPts.length >= 2)
                      Polyline(
                        points: traveledPts,
                        color: t.actionPrimary,
                        strokeWidth: 5.5,
                        strokeCap: StrokeCap.round,
                        strokeJoin: StrokeJoin.round,
                      ),
                  ],
                ),
                MarkerLayer(markers: markers),
              ],
            ),

            // Origin Home Stop Tag
            if (widget.homeStopLabel.isNotEmpty)
            Positioned.directional(
              textDirection: dir,
              start: 14,
              bottom: widget.replayMode ? 54 : 14,
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
                      widget.homeStopLabel,
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

            // Destination School Tag
            if (widget.schoolStopLabel.isNotEmpty)
            Positioned.directional(
              textDirection: dir,
              end: 14,
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
                      widget.schoolStopLabel,
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

            // Live GPS Pill
            if (!widget.replayMode && widget.gpsLabel.isNotEmpty)
              Positioned.directional(
                textDirection: dir,
                start: 14,
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
                        widget.gpsLabel,
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

            // Attribution Tag: "© OpenStreetMap contributors"
            Positioned.directional(
              textDirection: dir,
              start: 14,
              bottom: widget.replayMode ? 54 : 38,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: t.surface.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: t.border.withValues(alpha: 0.6)),
                ),
                child: Text(
                  '© OpenStreetMap contributors',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: t.textMuted,
                  ),
                ),
              ),
            ),

            // Recenter Button
            if (!widget.replayMode)
              Positioned.directional(
                textDirection: dir,
                end: 14,
                bottom: 14,
                child: GestureDetector(
                  key: const ValueKey('map-recenter-button'),
                  onTap: _recenter,
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

            // Replay Player Bar
            if (widget.replayMode)
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

  Widget _buildStationMarker(
    HannaTokens t,
    String status, {
    required bool isFirst,
    required bool isLast,
  }) {
    if (status == 'passed' || status == 'completed') {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: t.surface,
          shape: BoxShape.circle,
          border: Border.all(color: t.actionPrimary, width: 2),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 1),
              blurRadius: 4,
              color: t.text.withValues(alpha: 0.08),
            ),
          ],
        ),
        child: Center(
          child: isFirst
              ? Icon(LucideIcons.mapPin, size: 12, color: t.actionPrimary)
              : Icon(LucideIcons.check, size: 12, color: t.actionPrimary),
        ),
      );
    }

    if (status == 'current') {
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: t.actionPrimary.withValues(alpha: 0.28),
            ),
          ),
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: t.actionPrimary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // upcoming
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: t.surface,
        shape: BoxShape.circle,
        border: Border.all(color: t.border, width: 2),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 1),
            blurRadius: 4,
            color: t.text.withValues(alpha: 0.06),
          ),
        ],
      ),
      child: Center(
        child: isLast
            ? Icon(LucideIcons.graduationCap, size: 12, color: t.textMuted)
            : Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: t.textMuted,
                  shape: BoxShape.circle,
                ),
              ),
      ),
    );
  }
}
