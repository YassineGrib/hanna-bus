import 'package:hanna_bus_driver/features/navigation/live_route_map.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Use the shipped fonts so Arabic shaping and overflow checks match the app.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  LiveRouteMap.defaultTileProvider = NonNetworkTileProvider();
  final inter = FontLoader('Inter')
    ..addFont(rootBundle.load('assets/fonts/Inter-Variable.ttf'));
  final arabic = FontLoader('IBM Plex Sans Arabic');
  for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    arabic.addFont(
      rootBundle.load('assets/fonts/IBMPlexSansArabic-$weight.ttf'),
    );
  }
  await Future.wait([inter.load(), arabic.load()]);
  await testMain();
}
