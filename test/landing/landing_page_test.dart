import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multy_app/features/landing/data/landing_content.dart';
import 'package:multy_app/features/landing/landing_page.dart';
import 'package:multy_app/features/landing/presentation/theme/landing_theme.dart';
import 'package:multy_app/features/landing/presentation/widgets/interactive_playground_section.dart';
import 'package:multy_app/features/landing/services/landing_link_opener.dart';

class RecordingLinkOpener implements LandingLinkOpener {
  final List<Uri> opened = [];
  bool succeeds = true;
  @override
  Future<bool> open(Uri uri) async {
    opened.add(uri);
    return succeeds;
  }
}

void main() {
  for (final width in [320.0, 390.0, 768.0, 1440.0]) {
    testWidgets('page lays out without overflow at $width px', (tester) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: LandingTheme.data,
          home: LandingPage(linkOpener: RecordingLinkOpener()),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Multy'), findsWidgets);
      // All sections are eagerly laid out, even below the current viewport.
      expect(find.text('Try a Mini Multy Challenge'), findsOneWidget);
    });
  }

  testWidgets('320px layout supports double text size', (tester) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: LandingTheme.data,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: LandingPage(linkOpener: RecordingLinkOpener()),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'download opens actual store listing and reports launch failure',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final links = RecordingLinkOpener();
      await tester.pumpWidget(
        MaterialApp(
          theme: LandingTheme.data,
          home: LandingPage(linkOpener: links),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Download Free'));
      await tester.pumpAndSettle();
      expect(links.opened, [LandingContent.appStore]);
      links.succeeds = false;
      await tester.tap(find.text('Download Free'));
      await tester.pumpAndSettle();
      expect(
        find.text('Unable to open the link. Please try again.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('mobile navigation reaches the requested section', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: LandingTheme.data,
        home: LandingPage(linkOpener: RecordingLinkOpener()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Open navigation'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Privacy & Safety').last);
    await tester.pumpAndSettle();
    final target = find.text('Privacy First. No Tricks. No Distractions.');
    expect(tester.getTopLeft(target).dy, greaterThan(70));
    expect(tester.getTopLeft(target).dy, lessThan(350));
    await tester.ensureVisible(find.text('Read our Privacy Policy'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Read our Privacy Policy'));
    await tester.pumpAndSettle();
    expect(find.text('Multy Privacy Policy'), findsOneWidget);
    expect(find.byType(SelectableText), findsOneWidget);
  });

  testWidgets('quiz permits retry and progresses after a correct answer', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: LandingTheme.data,
        home: const Scaffold(
          body: SingleChildScrollView(child: InteractivePlaygroundSection()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('48'));
    await tester.tap(find.text('48'));
    await tester.pumpAndSettle();
    expect(find.text('Almost! Try again!'), findsOneWidget);
    expect(find.text('SCORE: 0'), findsOneWidget);
    await tester.tap(find.text('56'));
    await tester.pumpAndSettle();
    expect(find.text('Spot on! 7 × 8 = 56!'), findsOneWidget);
    expect(find.text('SCORE: 10'), findsOneWidget);
    await tester.ensureVisible(find.text('Next challenge'));
    await tester.tap(find.text('Next challenge'));
    await tester.pumpAndSettle();
    expect(find.text('6 × 7'), findsOneWidget);
    expect(find.text('SCORE: 10'), findsOneWidget);
  });
}
