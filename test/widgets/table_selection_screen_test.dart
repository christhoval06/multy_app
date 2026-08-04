import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multy_app/configs/route_paths.dart';
import 'package:multy_app/l10n/app_localizations.dart';
import 'package:multy_app/screens/table_selection_screen.dart';

void main() {
  group('TableSelectionScreen', () {
    testWidgets('renders study mode hero and table cards', (tester) async {
      await tester.pumpWidget(
        const _TableSelectionTestApp(
          child: TableSelectionScreen(nextRoute: RoutePaths.study),
        ),
      );

      final context = tester.element(find.byType(TableSelectionScreen));
      final l10n = AppLocalizations.of(context)!;

      expect(find.text(l10n.selectStudyTableTitle), findsWidgets);
      expect(find.text(l10n.selectStudyTablePrompt), findsOneWidget);
      expect(find.text(l10n.selectStudyTableHelper), findsOneWidget);
      expect(find.text(l10n.tableCardStudyLabel), findsNothing);
      expect(find.text(l10n.tableCardQuizLabel), findsNothing);
    });

    testWidgets('renders quiz mode hero and table cards', (tester) async {
      await tester.pumpWidget(
        const _TableSelectionTestApp(
          child: TableSelectionScreen(nextRoute: RoutePaths.multiplicationQuiz),
        ),
      );

      final context = tester.element(find.byType(TableSelectionScreen));
      final l10n = AppLocalizations.of(context)!;

      expect(find.text(l10n.selectQuizTableTitle), findsWidgets);
      expect(find.text(l10n.selectQuizTablePrompt), findsOneWidget);
      expect(find.text(l10n.selectQuizTableHelper), findsOneWidget);
      expect(find.text(l10n.tableCardQuizLabel), findsNothing);
      expect(find.text(l10n.tableCardStudyLabel), findsNothing);
    });
  });
}

class _TableSelectionTestApp extends StatelessWidget {
  const _TableSelectionTestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );
  }
}
