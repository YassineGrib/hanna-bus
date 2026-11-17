import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hanna_bus_parent/core/network/hanna_api_client.dart';
import 'package:hanna_bus_parent/core/state/app_state.dart';
import 'package:hanna_bus_parent/core/theme/hanna_tokens.dart';
import 'package:hanna_bus_parent/core/theme/hanna_typography.dart';
import 'package:hanna_bus_parent/features/children/screens/add_edit_child_screen.dart';
import 'package:hanna_bus_parent/features/children/screens/child_dossier_screen.dart';
import 'package:hanna_bus_parent/features/children/screens/children_list_screen.dart';
import 'package:hanna_bus_parent/features/children/screens/manage_child_screen.dart';

Future<AppStateController> _loggedInController() async {
  SharedPreferences.setMockInitialValues({});
  final controller = AppStateController(
    apiClient: HannaApiClient(
      baseUrl: 'http://127.0.0.1:8000/api/v1',
      httpClient: MockClient((_) async => throw http.ClientException('Offline')),
    ),
  );
  await controller.init();
  await controller.login('k.mansouri@mail.dz', 'Password123!');
  return controller;
}

Widget _wrap(AppStateController controller, Widget home) {
  HannaTypography.useGoogleFonts = false;
  return AppStateScope(
    controller: controller,
    child: AnimatedBuilder(
      animation: controller,
      builder: (_, _) {
        return MaterialApp(
          locale: controller.locale,
          supportedLocales: const [Locale('en'), Locale('ar'), Locale('fr')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: HannaTheme.build(
            palette: controller.palette,
            brightness: controller.brightness,
            locale: controller.locale,
          ),
          home: home,
        );
      },
    ),
  );
}

void main() {
  group('Module 04 My Children (4 screens / 7 views)', () {
    testWidgets('ChildrenListScreen navigates to ChildDossierScreen and switches FigCraft dossier tabs', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = await _loggedInController();
      await tester.pumpWidget(
        _wrap(controller, ChildrenListScreen(onOpenTrack: () {})),
      );
      await tester.pumpAndSettle();

      expect(find.text('Youssef Mansouri'), findsOneWidget);
      await tester.tap(find.text('Youssef Mansouri'));
      await tester.pumpAndSettle();

      expect(find.byType(ChildDossierScreen), findsOneWidget);
      expect(find.textContaining('101605180041'), findsOneWidget);

      await tester.tap(find.text('Educative'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Nadia Haddad'), findsOneWidget);
      expect(find.textContaining('Authorized Parent QR'), findsOneWidget);

      await tester.tap(find.text('Medical'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Peanuts'), findsWidgets);

      await tester.tap(find.text('Schedule'));
      await tester.pumpAndSettle();
      expect(find.textContaining('07:25'), findsWidgets);
    });

    testWidgets('AddEditChildScreen links code HB-2026-9911 and saves edited child', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = await _loggedInController();
      await tester.pumpWidget(_wrap(controller, const AddEditChildScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'HB-2026-9911');
      await tester.tap(find.text('Link Child Now'));
      await tester.pumpAndSettle();
      expect(controller.children.any((c) => c.studentCode == 'HB-2026-9911'), isTrue);
    });

    testWidgets('ManageChildScreen edits bus via HannaPickerSheet and confirms destructive removal', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = await _loggedInController();
      final rayan = controller.children.last;
      await tester.pumpWidget(
        _wrap(controller, ManageChildScreen(childId: rayan.id)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('Bus 02').first);
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Bus 04').last);
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView).first, const Offset(0, -240));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Unlink Child'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(controller.children.any((c) => c.id == rayan.id), isFalse);
    });
  });
}
