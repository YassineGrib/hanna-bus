import 'dart:async';
import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../state/app_state.dart';
import 'driver_widgets.dart';
import 'hanna_icon.dart';

/// A privacy curtain, not device authentication. Biometrics and PIN preferences
/// do not claim to enforce an authentication mechanism that is not installed.
class PrivacyGuard extends StatefulWidget {
  const PrivacyGuard({super.key, required this.state, required this.child});
  final DriverState state;
  final Widget child;
  @override
  State<PrivacyGuard> createState() => _PrivacyGuardState();
}

class _PrivacyGuardState extends State<PrivacyGuard>
    with WidgetsBindingObserver {
  Timer? timer;
  DateTime? idleDeadline;
  bool covered = false;
  int? minutes;
  bool signedIn = false;
  bool permissionPending = false;
  AppLifecycleState lifecycle = AppLifecycleState.resumed;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.state.addListener(sync);
    sync();
  }

  void sync() {
    final next =
        (widget.state.settings['privacy_lock_minutes'] as num?)?.toInt() ?? 5;
    final permission = widget.state.requestingPermission;
    final resetIdle = minutes != next || signedIn != widget.state.authenticated;
    if (minutes == next &&
        signedIn == widget.state.authenticated &&
        permissionPending == permission) {
      return;
    }
    permissionPending = permission;
    minutes = next;
    signedIn = widget.state.authenticated;
    if (!signedIn) covered = false;
    arm(resetIdle: resetIdle);
  }

  void arm({bool resetIdle = true}) {
    timer?.cancel();
    if (resetIdle || idleDeadline == null) {
      idleDeadline = DateTime.now().add(Duration(minutes: minutes!));
    }
    if (signedIn &&
        !covered &&
        !permissionPending &&
        lifecycle == AppLifecycleState.resumed) {
      final remaining = idleDeadline!.difference(DateTime.now());
      timer = Timer(remaining.isNegative ? Duration.zero : remaining, () {
        if (mounted) setState(() => covered = true);
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    lifecycle = state;
    timer?.cancel();
    if ((state == AppLifecycleState.paused ||
            state == AppLifecycleState.hidden) &&
        signedIn &&
        !permissionPending) {
      timer?.cancel();
      setState(() => covered = true);
    } else if (state == AppLifecycleState.resumed) {
      arm();
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    widget.state.removeListener(sync);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: (_) => arm(),
    onPointerSignal: (_) => arm(),
    child: Stack(
      children: [
        ExcludeSemantics(
          excluding: covered,
          child: IgnorePointer(ignoring: covered, child: widget.child),
        ),
        if (covered && signedIn)
          Positioned.fill(
            child: Material(
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const HannaIcon('shield-check', size: 56),
                        const SizedBox(height: 20),
                        Text(
                          AppStrings.of(context).t('privacyCovered'),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        DriverButton(
                          AppStrings.of(context).t('resumeShift'),
                          onPressed: () {
                            setState(() => covered = false);
                            arm();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
