import 'package:url_launcher/url_launcher.dart';

abstract interface class LandingLinkOpener {
  Future<bool> open(Uri uri);
}

class ExternalLandingLinkOpener implements LandingLinkOpener {
  const ExternalLandingLinkOpener();

  @override
  Future<bool> open(Uri uri) =>
      launchUrl(uri, mode: LaunchMode.externalApplication);
}
