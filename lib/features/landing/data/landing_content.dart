abstract final class LandingContent {
  static final appStore = Uri.parse(
    const String.fromEnvironment(
      'MULTY_APP_STORE_URL',
      defaultValue:
          'https://apps.apple.com/us/app/multy-multiplication-tables/id6759070074',
    ),
  );
  static final developer = Uri.parse('https://s.christhoval.dev');
  static final contact = Uri.parse(
    'mailto:me@christhoval.dev.com?subject=Multy%20inquiry',
  );
  static const icon = 'assets/icon.png';
  static const study = 'assets/screens/s4.png';
  static const tables = 'assets/screens/s3.png';
  static const quiz = 'assets/screens/s6.png';
  static const results = 'assets/screens/s5.png';
  static const profiles = 'assets/screens/s10.png';
}

enum LandingSection {
  features('Features'),
  howItWorks('How it Works'),
  story("Dion’s Story"),
  privacy('Privacy & Safety'),
  download('Download');

  const LandingSection(this.label);
  final String label;
}
