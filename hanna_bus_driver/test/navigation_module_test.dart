import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:hanna_bus_driver/core/state/models.dart';
import 'package:hanna_bus_driver/core/services/location_source.dart';
import 'package:hanna_bus_driver/core/theme/hanna_tokens.dart';
import 'package:hanna_bus_driver/features/navigation/live_route_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanna_bus_driver/features/navigation/navigation_screen.dart';
import 'package:hanna_bus_driver/core/widgets/driver_widgets.dart';
import 'helpers.dart';

void main() {
  test(
    'route points are optional, validated, preserved and preferred over stations',
    () {
      DriverTrip trip(dynamic points) => DriverTrip.fromJson({
        'route_points': points,
        'stations': [
          {'id': 1, 'lat': 36.7, 'lng': 3.1},
          {'id': 2, 'lat': null, 'lng': null},
        ],
      });
      for (final points in [null, []]) {
        expect(LiveRouteMap.routeFor(trip(points)), [const LatLng(36.7, 3.1)]);
      }
      final routed = trip([
        [36.8, 3.2],
        [36.9, 3.3],
        [999, 4],
        ['bad', null],
      ]);
      expect(LiveRouteMap.routeFor(routed), [
        const LatLng(36.8, 3.2),
        const LatLng(36.9, 3.3),
      ]);
      expect(
        DriverTrip.withStatus(routed, 'en_route').routePoints,
        routed.routePoints,
      );
      expect(LiveRouteMap.routeFor(DriverTrip.fromJson({})), isEmpty);
    },
  );

  for (final language in ['en', 'ar']) {
    for (final brightness in Brightness.values) {
      testWidgets(
        '$language ${brightness.name} map at 360px and 1.25 text scale',
        (tester) async {
          tester.view.physicalSize = const Size(360, 800);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final state = await readyState();
          addTearDown(state.dispose);
          state.locale = Locale(language);
          state.brightness = brightness;
          state.lastPosition = const DriverPosition(36.75, 3.05);
          final stops = [
            for (final status in ['completed', 'current', 'upcoming'])
              Station.fromJson({
                'id': status,
                'name': {'en': 'Stop', 'ar': 'المحطة'},
                'status': status,
                'lat': 36.75,
                'lng': 3.05,
              }),
          ];
          await tester.pumpWidget(
            host(
              state,
              Scaffold(
                body: LiveRouteMap(
                  points: const [LatLng(36.75, 3.05), LatLng(36.76, 3.06)],
                  stations: stops,
                  position: state.lastPosition,
                  tokens: HannaTokens.forPalette(state.palette, brightness),
                  tileProvider: NonNetworkTileProvider(),
                ),
              ),
              scale: 1.25,
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          final tiles = tester.widget<TileLayer>(find.byType(TileLayer));
          expect(tiles.tileProvider, isA<NonNetworkTileProvider>());
          expect(
            tester
                .widget<PolylineLayer>(find.byType(PolylineLayer))
                .polylines
                .single
                .points
                .length,
            2,
          );
          final markers = tester
              .widget<MarkerLayer>(find.byType(MarkerLayer))
              .markers;
          expect(markers.length, 4);
          expect(markers.last.point, const LatLng(36.75, 3.05));
          expect(find.text('© OpenStreetMap contributors'), findsOneWidget);
          expect(
            find.byTooltip(language == 'ar' ? 'توسيط الخريطة' : 'Recenter map'),
            findsOneWidget,
          );
          for (final status in ['completed', 'current', 'upcoming']) {
            expect(
              find.byKey(ValueKey('map-stop-$status-$status')),
              findsOneWidget,
            );
          }
          await tester.tap(find.byKey(const Key('map-recenter')));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          // Geographic points retain the same order in RTL.
          expect(markers.first.point, const LatLng(36.75, 3.05));
        },
      );
    }
  }
  testWidgets('API stop coordinates and arrival actions are shown', (
    tester,
  ) async {
    final repo = FakeRepository();
    final state = await readyState(repository: repo, active: true);
    addTearDown(state.dispose);
    await tester.pumpWidget(
      host(
        state,
        DriverPage(
          state: state,
          title: 'Navigation',
          children: [NavigationContent(state: state)],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byWidgetPredicate((w) => w is FlutterMap), findsOneWidget);
    await tapVisible(tester, find.byKey(const Key('arrive-stop-1')));
    expect(
      repo.calls.any((c) => c.path.endsWith('/stations/stop-1/arrive')),
      true,
    );
    expect(state.trip!.stations.first.status, 'current');
  });

  for (final language in ['en', 'ar']) {
    testWidgets(
      '$language missing coordinates use labeled schematic and station copy',
      (tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final repo = FakeRepository();
        for (final trip in repo.seed.trips) {
          for (final stop in trip['stations'] as List) {
            stop.remove('lat');
            stop.remove('lng');
            stop['status'] = 'completed';
          }
        }
        final state = await readyState(repository: repo);
        addTearDown(state.dispose);
        state.locale = Locale(language);
        await tester.pumpWidget(
          host(
            state,
            DriverPage(
              state: state,
              title: 'Navigation',
              children: [NavigationContent(state: state)],
            ),
            scale: 1.25,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(FlutterMap), findsNothing);
        expect(
          find.byWidgetPredicate(
            (w) => w is CustomPaint && w.painter is RoutePainter,
          ),
          findsOneWidget,
        );
        final note = find.text(
          language == 'ar'
              ? 'إحداثيات الخريطة غير متاحة. يظهر مخطط المحطات.'
              : 'Map coordinates unavailable. Showing stop diagram.',
        );
        expect(note, findsOneWidget);
        await tester.scrollUntilVisible(
          find
              .text(language == 'ar' ? 'اكتملت المحطة' : 'Stop completed')
              .first,
          150,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('Trip completed'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
