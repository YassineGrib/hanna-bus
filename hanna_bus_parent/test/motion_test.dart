import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanna_bus_parent/core/motion/hanna_motion.dart';

void main() {
  group('HannaMotion Emil Kowalski motion system', () {
    test('uses easeOutExpo and fast sub-300ms timings', () {
      expect(HannaMotion.easeOutExpo, equals(const Cubic(0.16, 1, 0.3, 1)));
      expect(HannaMotion.easeOutQuint, equals(const Cubic(0.22, 1, 0.36, 1)));
      expect(HannaMotion.durationFast.inMilliseconds, lessThanOrEqualTo(150));
      expect(HannaMotion.durationControl.inMilliseconds, lessThanOrEqualTo(220));
      expect(HannaMotion.durationRoute.inMilliseconds, lessThan(300));
      expect(HannaMotion.entryScale, greaterThanOrEqualTo(0.95));
      expect(HannaMotion.pressScale, greaterThanOrEqualTo(0.95));
    });

    testWidgets('effectiveDuration honors disableAnimationsOf(context)', (tester) async {
      Duration? observed;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Builder(
            builder: (context) {
              observed = HannaMotion.effectiveDuration(context, HannaMotion.durationRoute);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(observed, equals(Duration.zero));
    });

    testWidgets('HannaPressable triggers callback and renders immediately under reduced motion', (tester) async {
      var tapped = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: HannaPressable(
                onTap: () => tapped++,
                child: const Text('Press Me'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Press Me'));
      await tester.pumpAndSettle();
      expect(tapped, equals(1));

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: const MaterialApp(
            home: Scaffold(
              body: HannaMotionEntrance(
                child: Text('Appears Now'),
              ),
            ),
          ),
        ),
      );
      expect(find.text('Appears Now'), findsOneWidget);
    });
  });
}
