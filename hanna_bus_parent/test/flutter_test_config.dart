import 'dart:async';
import 'package:hanna_bus_parent/features/tracking/widgets/live_route_map.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  LiveRouteMap.defaultTileProvider = NonNetworkTileProvider();
  await testMain();
}
