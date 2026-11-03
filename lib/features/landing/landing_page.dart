import 'package:flutter/material.dart';
import 'data/landing_content.dart';
import 'services/landing_link_opener.dart';
import 'presentation/sections/download_section.dart';
import 'presentation/sections/features_section.dart';
import 'presentation/sections/footer_section.dart';
import 'presentation/sections/hero_section.dart';
import 'presentation/sections/privacy_section.dart';
import 'presentation/sections/steps_section.dart';
import 'presentation/sections/story_section.dart';
import 'presentation/widgets/header_widget.dart';
import 'presentation/widgets/interactive_playground_section.dart';
import 'presentation/widgets/privacy_policy_dialog.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({
    super.key,
    this.linkOpener = const ExternalLandingLinkOpener(),
  });
  final LandingLinkOpener linkOpener;
  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final _scrollController = ScrollController();
  final _anchors = {
    for (final section in LandingSection.values) section: GlobalKey(),
  };

  void _navigate(LandingSection section) {
    final target = _anchors[section]?.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      alignment: 0,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 450),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _open(Uri uri) async {
    var opened = false;
    try {
      opened = await widget.linkOpener.open(uri);
    } catch (_) {
      /* Report launch failure below. */
    }
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open the link. Please try again.'),
        ),
      );
    }
  }

  void _privacy() => showDialog<void>(
    context: context,
    builder: (_) => const PrivacyPolicyDialog(),
  );

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void download() => _open(LandingContent.appStore);
    void developer() => _open(LandingContent.developer);
    void contact() => _open(LandingContent.contact);
    return Scaffold(
      body: Column(
        children: [
          HeaderWidget(onNavigate: _navigate, onDownload: download),
          Expanded(
            child: Scrollbar(
              controller: _scrollController,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    HeroSection(
                      onDownload: download,
                      onHowItWorks: () => _navigate(LandingSection.howItWorks),
                    ),
                    StepsSection(key: _anchors[LandingSection.howItWorks]),
                    FeaturesSection(key: _anchors[LandingSection.features]),
                    StorySection(
                      key: _anchors[LandingSection.story],
                      onDeveloper: developer,
                    ),
                    PrivacySection(
                      key: _anchors[LandingSection.privacy],
                      onPrivacy: _privacy,
                    ),
                    const InteractivePlaygroundSection(),
                    DownloadSection(
                      key: _anchors[LandingSection.download],
                      onDownload: download,
                    ),
                    FooterSection(
                      onNavigate: _navigate,
                      onPrivacy: _privacy,
                      onDeveloper: developer,
                      onContact: contact,
                      onDownload: download,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
