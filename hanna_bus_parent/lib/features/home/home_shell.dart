import 'package:flutter/material.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/motion/hanna_motion.dart';
import '../../core/widgets/hanna_background.dart';
import '../../core/widgets/hanna_floating_nav_bar.dart';
import 'screens/home_dashboard_screen.dart';

typedef HomeTabTrackBuilder = Widget Function(
  BuildContext context,
  VoidCallback onBackToHome,
);
typedef HomeTabChildrenBuilder = Widget Function(
  BuildContext context,
  VoidCallback onOpenTrack,
);
typedef HomeTabProfileBuilder = Widget Function(BuildContext context);

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.trackBuilder,
    required this.childrenBuilder,
    required this.profileBuilder,
    this.onOpenTripHistory,
    this.initialIndex = 0,
  });

  final HomeTabTrackBuilder trackBuilder;
  final HomeTabChildrenBuilder childrenBuilder;
  final HomeTabProfileBuilder profileBuilder;
  final VoidCallback? onOpenTripHistory;
  final int initialIndex;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  void _switchTab(int target) {
    if (_index == target) return;
    setState(() => _index = target);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);

    return Scaffold(
      body: HannaBackground(
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedSwitcher(
              duration: HannaMotion.effectiveDuration(
                context,
                HannaMotion.durationControl,
              ),
              switchInCurve: HannaMotion.easeOutExpo,
              child: IndexedStack(
                key: const ValueKey('home-indexed-stack'),
                index: _index,
                children: [
                  HomeDashboardScreen(
                    onOpenTrack: () => _switchTab(1),
                    onOpenChildren: () => _switchTab(2),
                    onOpenHistory: widget.onOpenTripHistory ?? () => _switchTab(1),
                  ),
                  widget.trackBuilder(context, () => _switchTab(0)),
                  widget.childrenBuilder(context, () => _switchTab(1)),
                  widget.profileBuilder(context),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: HannaFloatingNavBar(
                currentIndex: _index,
                onTap: _switchTab,
                strings: s,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
