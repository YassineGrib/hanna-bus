import 'package:url_launcher/url_launcher.dart';

abstract interface class CallSource {
  Future<bool> dial(String number);
}

class PhoneCallSource implements CallSource {
  @override
  Future<bool> dial(String number) => launchUrl(
    Uri(scheme: 'tel', path: number),
    mode: LaunchMode.externalApplication,
  );
}
