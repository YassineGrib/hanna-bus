import 'package:flutter/material.dart';
import 'app.dart';
import 'core/state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = AppStateController();
  await controller.init();
  runApp(HannaBusParentApp(controller: controller));
}
