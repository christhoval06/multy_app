import 'package:flutter/material.dart';

import 'package:multy_app/configs/route_paths.dart';
import 'package:multy_app/configs/settings.dart';
import 'package:multy_app/l10n/app_localizations.dart';
import 'package:multy_app/theme/app_fonts.dart';

import 'package:multy_app/widgets/table_selection/table_button.dart';

class TableSelectionScreen extends StatelessWidget {
  final String nextRoute;
  const TableSelectionScreen({super.key, required this.nextRoute});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isQuizMode = nextRoute == RoutePaths.multiplicationQuiz;
    final selectionMode =
        isQuizMode ? TableSelectionMode.quiz : TableSelectionMode.study;
    final appBarColor = isQuizMode
        ? const Color(0xFFFF8A3D)
        : const Color(0xFF4F86F7);
    final heroTitle =
        isQuizMode ? l10n.selectQuizTableTitle : l10n.selectStudyTableTitle;
    final heroPrompt =
        isQuizMode ? l10n.selectQuizTablePrompt : l10n.selectStudyTablePrompt;
    final heroHelper =
        isQuizMode ? l10n.selectQuizTableHelper : l10n.selectStudyTableHelper;
    final heroIcon =
        isQuizMode ? Icons.bolt_rounded : Icons.menu_book_rounded;
    final heroGradient = isQuizMode
        ? const <Color>[Color(0xFFFFF0E4), Color(0xFFFFD2B0)]
        : const <Color>[Color(0xFFEAF2FF), Color(0xFFC9DFFF)];
    final heroAccent = isQuizMode
        ? const Color(0xFF9A4D00)
        : const Color(0xFF1E4DA1);

    return Scaffold(
      appBar: AppBar(
        title: Text(heroTitle),
        backgroundColor: appBarColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
            sliver: SliverToBoxAdapter(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: heroGradient,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: heroAccent.withValues(alpha: 0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.72),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          heroIcon,
                          color: heroAccent,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              heroTitle,
                              style: TextStyle(
                                fontFamily: AppFonts.display,
                                fontSize: 27,
                                color: heroAccent,
                                height: 1.05,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              heroPrompt,
                              style: TextStyle(
                                fontFamily: AppFonts.body,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: heroAccent.withValues(alpha: 0.92),
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              heroHelper,
                              style: TextStyle(
                                fontFamily: AppFonts.body,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: heroAccent.withValues(alpha: 0.76),
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.92,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                return TableButton(
                  tableNumber: index + 1,
                  nextRoute: nextRoute,
                  selectionMode: selectionMode,
                );
              }, childCount: Settings.maxTableNumber),
            ),
          ),
        ],
      ),
    );
  }
}
