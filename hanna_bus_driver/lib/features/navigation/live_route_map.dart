import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/services/location_source.dart';
import '../../core/state/models.dart';
import '../../core/theme/hanna_tokens.dart';

class NonNetworkTileProvider extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) =>
      MemoryImage(TileProvider.transparentImage);
}

/// Geographic coordinates remain unmirrored; controls follow the UI direction.
class LiveRouteMap extends StatefulWidget {
  const LiveRouteMap({
    super.key,
    required this.points,
    required this.stations,
    required this.tokens,
    this.position,
    this.tileProvider,
  });
  final List<LatLng> points;
  final List<Station> stations;
  final HannaTokens tokens;
  final DriverPosition? position;
  final TileProvider? tileProvider;
  static TileProvider? defaultTileProvider;

  static List<LatLng> routeFor(DriverTrip trip) => trip.routePoints.isNotEmpty
      ? trip.routePoints
      : [
          for (final stop in trip.stations)
            if (validCoordinates(stop.lat, stop.lng))
              LatLng(stop.lat!, stop.lng!),
        ];

  @override
  State<LiveRouteMap> createState() => _LiveRouteMapState();
}

class _LiveRouteMapState extends State<LiveRouteMap> {
  final controller = MapController();
  late final TileProvider provider =
      widget.tileProvider ??
      LiveRouteMap.defaultTileProvider ??
      NetworkTileProvider();

  List<LatLng> get fittedPoints => [
    ...widget.points,
    for (final s in widget.stations)
      if (validCoordinates(s.lat, s.lng)) LatLng(s.lat!, s.lng!),
    if (validCoordinates(widget.position?.lat, widget.position?.lng))
      LatLng(widget.position!.lat, widget.position!.lng),
  ];

  CameraFit get fit => CameraFit.coordinates(
    coordinates: fittedPoints,
    padding: const EdgeInsets.all(42),
    maxZoom: 16,
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens;
    final s = AppStrings.of(context);
    return SizedBox(
      height: 280,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            FlutterMap(
              mapController: controller,
              options: MapOptions(initialCameraFit: fit),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.hannabus.hanna_bus_driver',
                  tileProvider: provider,
                  tileBuilder: (context, tile, _) => ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      t.isDark
                          ? t.mapBg.withValues(alpha: 0.6)
                          : t.mapBg.withValues(alpha: 0),
                      BlendMode.srcATop,
                    ),
                    child: tile,
                  ),
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: widget.points,
                      color: t.actionPrimary,
                      strokeWidth: 5,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    for (final stop in widget.stations)
                      if (validCoordinates(stop.lat, stop.lng))
                        Marker(
                          point: LatLng(stop.lat!, stop.lng!),
                          width: 34,
                          height: 34,
                          child: Tooltip(
                            message:
                                '${label(stop.name, s.language)}: ${s.t(stop.status == 'completed' ? 'stopCompleted' : stop.status)}',
                            child: Container(
                              key: ValueKey(
                                'map-stop-${stop.id}-${stop.status}',
                              ),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: stop.status == 'current'
                                    ? t.actionPrimary
                                    : stop.status == 'completed'
                                    ? t.success
                                    : t.surface,
                                border: Border.all(color: t.text, width: 2),
                              ),
                              child: Icon(
                                stop.status == 'completed'
                                    ? Icons.check
                                    : stop.status == 'current'
                                    ? Icons.location_on
                                    : Icons.circle_outlined,
                                size: 18,
                                color: stop.status == 'current'
                                    ? t.onPrimary
                                    : stop.status == 'completed'
                                    ? t.onSuccess
                                    : t.text,
                              ),
                            ),
                          ),
                        ),
                    if (validCoordinates(
                      widget.position?.lat,
                      widget.position?.lng,
                    ))
                      Marker(
                        point: LatLng(
                          widget.position!.lat,
                          widget.position!.lng,
                        ),
                        width: 42,
                        height: 42,
                        child: Tooltip(
                          message: s.t('driverPosition'),
                          child: Container(
                            key: const Key('map-driver-position'),
                            decoration: BoxDecoration(
                              color: t.heroSurface,
                              shape: BoxShape.circle,
                              border: Border.all(color: t.onHero, width: 2),
                            ),
                            child: Icon(
                              Icons.directions_bus,
                              color: t.onHero,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            PositionedDirectional(
              start: 8,
              end: 8,
              bottom: 8,
              child: Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: ColoredBox(
                        color: t.surface,
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            '© OpenStreetMap contributors',
                            textDirection: TextDirection.ltr,
                            style: TextStyle(fontSize: 10, color: t.text),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Material(
                    color: t.surface,
                    borderRadius: BorderRadius.circular(24),
                    child: IconButton(
                      key: const Key('map-recenter'),
                      tooltip: s.t('recenterMap'),
                      onPressed: () => controller.fitCamera(fit),
                      icon: Icon(Icons.my_location, color: t.text),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
