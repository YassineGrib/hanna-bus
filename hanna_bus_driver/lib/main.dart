import 'package:flutter/material.dart';
import 'app.dart';
import 'core/l10n/app_strings.dart';
import 'core/state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppStrings.load();
  final state = DriverState();
  runApp(DriverApp(state: state));
  await state.init();
}
