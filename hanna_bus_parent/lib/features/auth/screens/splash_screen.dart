import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/motion/hanna_motion.dart';
import '../../../core/theme/hanna_tokens.dart';
import '../../../core/widgets/hanna_background.dart';
import '../widgets/auth_chrome.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.onFinished,
    this.autoAdvanceDelay = const Duration(milliseconds: 950),
  });

  final VoidCallback onFinished;
  final Duration autoAdvanceDelay;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.autoAdvanceDelay, () {
      if (mounted) widget.onFinished();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final t = HannaTokens.of(context);

    return Scaffold(
      body: HannaBackground(
        variant: HannaBackgroundVariant.auth,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(HannaSpace.xl),
              child: HannaMotionEntrance(
                withScale: true,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const HannaCrestLogo(size: 96),
                    const SizedBox(height: HannaSpace.lg),
                    Text(
                      s.appTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    const SizedBox(height: HannaSpace.xs),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 280),
                      child: Text(
                        s.splashTagline,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: t.textMuted,
                            ),
                      ),
                    ),
                    const SizedBox(height: HannaSpace.xl),
                    Container(
                      width: 64,
                      height: 4,
                      decoration: BoxDecoration(
                        color: t.actionPrimary,
                        borderRadius: BorderRadius.circular(HannaRadius.pill),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
