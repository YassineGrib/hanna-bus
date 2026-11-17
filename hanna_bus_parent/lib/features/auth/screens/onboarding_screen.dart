import 'package:flutter/material.dart';
import '../../../core/state/app_state.dart';
import 'welcome_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key, required this.onCompleted});
  final VoidCallback onCompleted;

  Future<void> _handleComplete(BuildContext context) async {
    await AppStateScope.of(context).markOnboardingComplete();
    onCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return WelcomeScreen(
      onCompleted: () => _handleComplete(context),
      onBack: () => _handleComplete(context),
    );
  }
}
