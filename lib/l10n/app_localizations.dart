import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Multiplication Tables'**
  String get appTitle;

  /// No description provided for @selectTableTitle.
  ///
  /// In en, this message translates to:
  /// **'Select a option'**
  String get selectTableTitle;

  /// No description provided for @selectTablePrompt.
  ///
  /// In en, this message translates to:
  /// **'Which table do you want to practice today?'**
  String get selectTablePrompt;

  /// No description provided for @practiceButton.
  ///
  /// In en, this message translates to:
  /// **'Practice!'**
  String get practiceButton;

  /// Title for the practice screen
  ///
  /// In en, this message translates to:
  /// **'Practicing Table {tableNumber}'**
  String practiceScreenTitle(int tableNumber);

  /// The multiplication calculation shown
  ///
  /// In en, this message translates to:
  /// **'{factor1} x {factor2} = '**
  String multiplicationOperation(int factor1, int factor2);

  /// No description provided for @answerHint.
  ///
  /// In en, this message translates to:
  /// **'?'**
  String get answerHint;

  /// No description provided for @gradeButton.
  ///
  /// In en, this message translates to:
  /// **'Grade'**
  String get gradeButton;

  /// No description provided for @tryAgainButton.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgainButton;

  /// No description provided for @summaryDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summaryDialogTitle;

  /// No description provided for @congratulationsDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get congratulationsDialogTitle;

  /// Text showing the score in the summary dialog
  ///
  /// In en, this message translates to:
  /// **'You got {correctCount} out of 12 correct answers.'**
  String summaryDialogContent(int correctCount);

  /// No description provided for @dialogOkButton.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get dialogOkButton;

  /// Error message showing the correct answer
  ///
  /// In en, this message translates to:
  /// **'It was {correctAnswer}'**
  String correctAnswerWas(int correctAnswer);

  /// Button on practice screen to start the quiz
  ///
  /// In en, this message translates to:
  /// **'Take a Quiz!'**
  String get practiceScreenTestButton;

  /// No description provided for @quizScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Quiz: Table {tableNumber}'**
  String quizScreenTitle(int tableNumber);

  /// No description provided for @quizTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get quizTimeLabel;

  /// No description provided for @quizQuestionProgress.
  ///
  /// In en, this message translates to:
  /// **'Question {current} / {total}'**
  String quizQuestionProgress(Object current, Object total);

  /// No description provided for @quizEndedMessage.
  ///
  /// In en, this message translates to:
  /// **'Quiz Finished!'**
  String get quizEndedMessage;

  /// No description provided for @quizTimeOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Time\'s Up!'**
  String get quizTimeOutTitle;

  /// No description provided for @quizCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Quiz Complete!'**
  String get quizCompleteTitle;

  /// No description provided for @quizScoreMessage.
  ///
  /// In en, this message translates to:
  /// **'Your score: {score} out of {total}'**
  String quizScoreMessage(Object score, Object total);

  /// No description provided for @quizPercentageMessage.
  ///
  /// In en, this message translates to:
  /// **'Percentage: {percentage}%'**
  String quizPercentageMessage(Object percentage);

  /// No description provided for @quizPassedMessage.
  ///
  /// In en, this message translates to:
  /// **'You passed!'**
  String get quizPassedMessage;

  /// No description provided for @quizFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Keep practicing!'**
  String get quizFailedMessage;

  /// No description provided for @quizRetryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get quizRetryButton;

  /// No description provided for @quizBackToMenuButton.
  ///
  /// In en, this message translates to:
  /// **'Back to Menu'**
  String get quizBackToMenuButton;

  /// No description provided for @quizCannotExitMessage.
  ///
  /// In en, this message translates to:
  /// **'You cannot exit the quiz while it\'s in progress!'**
  String get quizCannotExitMessage;

  /// No description provided for @quizResultScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Results: Table {tableNumber}'**
  String quizResultScreenTitle(Object tableNumber);

  /// No description provided for @quizPassedMessageLarge.
  ///
  /// In en, this message translates to:
  /// **'CONGRATULATIONS!'**
  String get quizPassedMessageLarge;

  /// No description provided for @quizFailedMessageLarge.
  ///
  /// In en, this message translates to:
  /// **'OH NO! KEEP TRYING!'**
  String get quizFailedMessageLarge;

  /// No description provided for @quizScoreDetailed.
  ///
  /// In en, this message translates to:
  /// **'You got {score} out of {total} correct answers.'**
  String quizScoreDetailed(Object score, Object total);

  /// No description provided for @quizPercentageDetailed.
  ///
  /// In en, this message translates to:
  /// **'That\'s a {percentage}% accuracy.'**
  String quizPercentageDetailed(Object percentage);

  /// No description provided for @quizMainMenuButton.
  ///
  /// In en, this message translates to:
  /// **'Main Menu'**
  String get quizMainMenuButton;

  /// No description provided for @quizResultTimedOutInfo.
  ///
  /// In en, this message translates to:
  /// **'You ran out of time on this attempt.'**
  String get quizResultTimedOutInfo;

  /// No description provided for @statisticsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Progress'**
  String get statisticsTitle;

  /// No description provided for @overallStats.
  ///
  /// In en, this message translates to:
  /// **'Overall Statistics'**
  String get overallStats;

  /// No description provided for @totalQuizzesPlayed.
  ///
  /// In en, this message translates to:
  /// **'Total Quizzes Played: {count}'**
  String totalQuizzesPlayed(Object count);

  /// No description provided for @overallAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Overall Accuracy: {accuracy}%'**
  String overallAccuracy(Object accuracy);

  /// No description provided for @statsByTable.
  ///
  /// In en, this message translates to:
  /// **'Statistics by Table'**
  String get statsByTable;

  /// No description provided for @tableNumberHeader.
  ///
  /// In en, this message translates to:
  /// **'Table {number}'**
  String tableNumberHeader(Object number);

  /// No description provided for @attempts.
  ///
  /// In en, this message translates to:
  /// **'Attempts: {count}'**
  String attempts(Object count);

  /// No description provided for @accuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy: {accuracy}%'**
  String accuracy(Object accuracy);

  /// No description provided for @bestScore.
  ///
  /// In en, this message translates to:
  /// **'Best: {correct}/{total}'**
  String bestScore(Object correct, Object total);

  /// No description provided for @noAttemptsYet.
  ///
  /// In en, this message translates to:
  /// **'No attempts yet for this table.'**
  String get noAttemptsYet;

  /// No description provided for @noStatsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No statistics available yet. Play some quizzes!'**
  String get noStatsAvailable;

  /// No description provided for @loadingStats.
  ///
  /// In en, this message translates to:
  /// **'Loading statistics...'**
  String get loadingStats;

  /// No description provided for @bestTime.
  ///
  /// In en, this message translates to:
  /// **'Best Time: {time}'**
  String bestTime(String time);

  /// No description provided for @menuStats.
  ///
  /// In en, this message translates to:
  /// **'Show Stats'**
  String get menuStats;

  /// No description provided for @menuSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get menuSettings;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get settingsLoading;

  /// No description provided for @settingsAppName.
  ///
  /// In en, this message translates to:
  /// **'Multy'**
  String get settingsAppName;

  /// No description provided for @settingsAppDescription.
  ///
  /// In en, this message translates to:
  /// **'An educational application developed in Flutter for children aged 4 to 10 to learn and practice multiplication tables in a fun, fast, and interactive way.'**
  String get settingsAppDescription;

  /// No description provided for @settingsVersionNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get settingsVersionNotAvailable;

  /// No description provided for @settingsCouldNotOpenEmail.
  ///
  /// In en, this message translates to:
  /// **'Could not open email app.'**
  String get settingsCouldNotOpenEmail;

  /// No description provided for @settingsCouldNotOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Could not open link: {urlString}'**
  String settingsCouldNotOpenLink(Object urlString);

  /// No description provided for @settingsDestructiveActionTitle.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Destructive Action!'**
  String get settingsDestructiveActionTitle;

  /// No description provided for @settingsDestructiveActionContent.
  ///
  /// In en, this message translates to:
  /// **'You are about to delete ALL application data.\n\nThis action CANNOT BE UNDONE.\n\nAre you absolutely sure?'**
  String get settingsDestructiveActionContent;

  /// No description provided for @settingsCancel.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get settingsCancel;

  /// No description provided for @settingsConfirmDeleteAll.
  ///
  /// In en, this message translates to:
  /// **'YES, DELETE ALL'**
  String get settingsConfirmDeleteAll;

  /// No description provided for @settingsFinalConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'FINAL CONFIRMATION'**
  String get settingsFinalConfirmationTitle;

  /// No description provided for @settingsFinalConfirmationContent.
  ///
  /// In en, this message translates to:
  /// **'To confirm, type \"DELETE\" in the field below:'**
  String get settingsFinalConfirmationContent;

  /// No description provided for @settingsFinalConfirmationHint.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get settingsFinalConfirmationHint;

  /// No description provided for @settingsDeleteDataNow.
  ///
  /// In en, this message translates to:
  /// **'DELETE DATA NOW'**
  String get settingsDeleteDataNow;

  /// No description provided for @settingsIncorrectConfirmationText.
  ///
  /// In en, this message translates to:
  /// **'Incorrect confirmation text.'**
  String get settingsIncorrectConfirmationText;

  /// No description provided for @settingsAllDataDeleted.
  ///
  /// In en, this message translates to:
  /// **'All data has been deleted.'**
  String get settingsAllDataDeleted;

  /// No description provided for @settingsSectionAppInfo.
  ///
  /// In en, this message translates to:
  /// **'App Information'**
  String get settingsSectionAppInfo;

  /// No description provided for @settingsAppVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get settingsAppVersion;

  /// No description provided for @settingsTermsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get settingsTermsAndConditions;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsSectionDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get settingsSectionDeveloper;

  /// No description provided for @settingsDeveloperName.
  ///
  /// In en, this message translates to:
  /// **'Christhoval Barba'**
  String get settingsDeveloperName;

  /// No description provided for @settingsDeveloperDescription.
  ///
  /// In en, this message translates to:
  /// **'Developer of this application'**
  String get settingsDeveloperDescription;

  /// No description provided for @settingsPorfolio.
  ///
  /// In en, this message translates to:
  /// **'Personal Site'**
  String get settingsPorfolio;

  /// No description provided for @settingsPorfolioWeb.
  ///
  /// In en, this message translates to:
  /// **'s.christhoval.dev'**
  String get settingsPorfolioWeb;

  /// No description provided for @settingsGitHubProfile.
  ///
  /// In en, this message translates to:
  /// **'GitHub Profile'**
  String get settingsGitHubProfile;

  /// No description provided for @settingsGitHubUsername.
  ///
  /// In en, this message translates to:
  /// **'github.com/christhoval06'**
  String get settingsGitHubUsername;

  /// No description provided for @settingsLinkedInProfile.
  ///
  /// In en, this message translates to:
  /// **'LinkedIn'**
  String get settingsLinkedInProfile;

  /// No description provided for @settingsLinkedInUsername.
  ///
  /// In en, this message translates to:
  /// **'christhoval'**
  String get settingsLinkedInUsername;

  /// No description provided for @settingsContactDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get settingsContactDeveloper;

  /// No description provided for @settingsSectionSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get settingsSectionSupport;

  /// No description provided for @settingsReportProblem.
  ///
  /// In en, this message translates to:
  /// **'Report a Problem'**
  String get settingsReportProblem;

  /// No description provided for @settingsSectionDataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get settingsSectionDataManagement;

  /// No description provided for @settingsDeleteAllDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete All Data'**
  String get settingsDeleteAllDataTitle;

  /// No description provided for @settingsDeleteAllDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Deletes all raffles, numbers, and buyers.'**
  String get settingsDeleteAllDataSubtitle;

  /// No description provided for @studyTableTitle.
  ///
  /// In en, this message translates to:
  /// **'Studying the Table of {tableNumber}'**
  String studyTableTitle(Object tableNumber);

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @speak.
  ///
  /// In en, this message translates to:
  /// **'Speak'**
  String get speak;

  /// No description provided for @speakTimes.
  ///
  /// In en, this message translates to:
  /// **'times'**
  String get speakTimes;

  /// No description provided for @speakEquals.
  ///
  /// In en, this message translates to:
  /// **'equals'**
  String get speakEquals;

  /// No description provided for @funFactTable2Multiplier1.
  ///
  /// In en, this message translates to:
  /// **'You have 2 eyes to see the world!'**
  String get funFactTable2Multiplier1;

  /// No description provided for @funFactTable2Multiplier2.
  ///
  /// In en, this message translates to:
  /// **'A bicycle has 2 wheels.'**
  String get funFactTable2Multiplier2;

  /// No description provided for @funFactTable2Multiplier4.
  ///
  /// In en, this message translates to:
  /// **'A pair of shoes are 2 shoes.'**
  String get funFactTable2Multiplier4;

  /// No description provided for @funFactTable2Multiplier5.
  ///
  /// In en, this message translates to:
  /// **'Most people have 2 hands and 2 feet.'**
  String get funFactTable2Multiplier5;

  /// No description provided for @funFactTable2Multiplier10.
  ///
  /// In en, this message translates to:
  /// **'20 is double 10, like having two 10-dollar bills!'**
  String get funFactTable2Multiplier10;

  /// No description provided for @funFactTable3Multiplier1.
  ///
  /// In en, this message translates to:
  /// **'A tricycle has 3 wheels.'**
  String get funFactTable3Multiplier1;

  /// No description provided for @funFactTable3Multiplier2.
  ///
  /// In en, this message translates to:
  /// **'A traffic light has 3 lights: red, yellow, and green.'**
  String get funFactTable3Multiplier2;

  /// No description provided for @funFactTable3Multiplier3.
  ///
  /// In en, this message translates to:
  /// **'3 x 3 is 9, a magical square number!'**
  String get funFactTable3Multiplier3;

  /// No description provided for @funFactTable3Multiplier4.
  ///
  /// In en, this message translates to:
  /// **'A lucky clover usually has 3 leaves (sometimes 4!).'**
  String get funFactTable3Multiplier4;

  /// No description provided for @funFactTable4Multiplier1.
  ///
  /// In en, this message translates to:
  /// **'A square has 4 equal sides.'**
  String get funFactTable4Multiplier1;

  /// No description provided for @funFactTable4Multiplier2.
  ///
  /// In en, this message translates to:
  /// **'Most cars have 4 wheels.'**
  String get funFactTable4Multiplier2;

  /// No description provided for @funFactTable4Multiplier3.
  ///
  /// In en, this message translates to:
  /// **'The seasons of the year are 4: spring, summer, autumn, and winter.'**
  String get funFactTable4Multiplier3;

  /// No description provided for @funFactTable5Multiplier1.
  ///
  /// In en, this message translates to:
  /// **'You have 5 fingers on each hand!'**
  String get funFactTable5Multiplier1;

  /// No description provided for @funFactTable5Multiplier2.
  ///
  /// In en, this message translates to:
  /// **'A starfish commonly has 5 arms.'**
  String get funFactTable5Multiplier2;

  /// No description provided for @funFactTable5Multiplier3.
  ///
  /// In en, this message translates to:
  /// **'A pentagon is a shape with 5 sides.'**
  String get funFactTable5Multiplier3;

  /// No description provided for @funFactTable5Multiplier4.
  ///
  /// In en, this message translates to:
  /// **'A lustrum is 5 years.'**
  String get funFactTable5Multiplier4;

  /// No description provided for @funFactTable5Multiplier10.
  ///
  /// In en, this message translates to:
  /// **'Counting to 50 is like counting 5 times to 10.'**
  String get funFactTable5Multiplier10;

  /// No description provided for @funFactTable6Multiplier1.
  ///
  /// In en, this message translates to:
  /// **'A common die has 6 faces.'**
  String get funFactTable6Multiplier1;

  /// No description provided for @funFactTable6Multiplier2.
  ///
  /// In en, this message translates to:
  /// **'Insects have 6 legs.'**
  String get funFactTable6Multiplier2;

  /// No description provided for @funFactTable6Multiplier3.
  ///
  /// In en, this message translates to:
  /// **'A guitar usually has 6 strings.'**
  String get funFactTable6Multiplier3;

  /// No description provided for @funFactTable7Multiplier1.
  ///
  /// In en, this message translates to:
  /// **'There are 7 days in a week!'**
  String get funFactTable7Multiplier1;

  /// No description provided for @funFactTable7Multiplier2.
  ///
  /// In en, this message translates to:
  /// **'The colors of the rainbow are 7.'**
  String get funFactTable7Multiplier2;

  /// No description provided for @funFactTable7Multiplier3.
  ///
  /// In en, this message translates to:
  /// **'Snow White met 7 dwarfs.'**
  String get funFactTable7Multiplier3;

  /// No description provided for @funFactTable7Multiplier4.
  ///
  /// In en, this message translates to:
  /// **'The 7 wonders of the ancient world were amazing constructions.'**
  String get funFactTable7Multiplier4;

  /// No description provided for @funFactTable8Multiplier1.
  ///
  /// In en, this message translates to:
  /// **'A spider has 8 legs.'**
  String get funFactTable8Multiplier1;

  /// No description provided for @funFactTable8Multiplier2.
  ///
  /// In en, this message translates to:
  /// **'An octopus has 8 tentacles.'**
  String get funFactTable8Multiplier2;

  /// No description provided for @funFactTable8Multiplier3.
  ///
  /// In en, this message translates to:
  /// **'In music, an octave has 8 notes.'**
  String get funFactTable8Multiplier3;

  /// No description provided for @funFactTable9Multiplier1.
  ///
  /// In en, this message translates to:
  /// **'A cat is said to have 9 lives (it\'s just a saying!).'**
  String get funFactTable9Multiplier1;

  /// No description provided for @funFactTable9Multiplier2.
  ///
  /// In en, this message translates to:
  /// **'A full baseball game has 9 innings.'**
  String get funFactTable9Multiplier2;

  /// No description provided for @funFactTable9Multiplier3.
  ///
  /// In en, this message translates to:
  /// **'Sudoku is played on a 9x9 grid.'**
  String get funFactTable9Multiplier3;

  /// No description provided for @funFactTable10Multiplier1.
  ///
  /// In en, this message translates to:
  /// **'You have 10 fingers in total on your hands!'**
  String get funFactTable10Multiplier1;

  /// No description provided for @funFactTable10Multiplier2.
  ///
  /// In en, this message translates to:
  /// **'A decade is 10 years.'**
  String get funFactTable10Multiplier2;

  /// No description provided for @funFactTable10Multiplier3.
  ///
  /// In en, this message translates to:
  /// **'The decimal system we use is based on the number 10.'**
  String get funFactTable10Multiplier3;

  /// No description provided for @funFactTable10Multiplier5.
  ///
  /// In en, this message translates to:
  /// **'50 is half of 100, and 5 x 10!'**
  String get funFactTable10Multiplier5;

  /// No description provided for @funFactTable11Multiplier1.
  ///
  /// In en, this message translates to:
  /// **'A soccer team has 11 players on the field.'**
  String get funFactTable11Multiplier1;

  /// No description provided for @funFactTable11Multiplier2.
  ///
  /// In en, this message translates to:
  /// **'If you count your fingers and one foot, you almost get to 11 (it\'s 15)!'**
  String get funFactTable11Multiplier2;

  /// No description provided for @funFactTable12Multiplier1.
  ///
  /// In en, this message translates to:
  /// **'A year has 12 months.'**
  String get funFactTable12Multiplier1;

  /// No description provided for @funFactTable12Multiplier2.
  ///
  /// In en, this message translates to:
  /// **'A dozen is 12 things, like a dozen eggs!'**
  String get funFactTable12Multiplier2;

  /// No description provided for @funFactTable12Multiplier3.
  ///
  /// In en, this message translates to:
  /// **'A clock shows 12 hours (in 12-hour format).'**
  String get funFactTable12Multiplier3;

  /// No description provided for @funFactGeneric1.
  ///
  /// In en, this message translates to:
  /// **'Math is like a superpower!'**
  String get funFactGeneric1;

  /// No description provided for @funFactGeneric2.
  ///
  /// In en, this message translates to:
  /// **'Practicing a little bit every day makes you a tables champion.'**
  String get funFactGeneric2;

  /// No description provided for @funFactGeneric3.
  ///
  /// In en, this message translates to:
  /// **'Keep it up, you\'re doing wonderfully!'**
  String get funFactGeneric3;

  /// No description provided for @funFactGeneric4.
  ///
  /// In en, this message translates to:
  /// **'Numbers help us understand the world.'**
  String get funFactGeneric4;

  /// No description provided for @funFactGeneric5.
  ///
  /// In en, this message translates to:
  /// **'Learning is the best adventure.'**
  String get funFactGeneric5;

  /// No description provided for @funFactGeneric6.
  ///
  /// In en, this message translates to:
  /// **'Every number has its own secret story.'**
  String get funFactGeneric6;

  /// No description provided for @funFactGeneric7.
  ///
  /// In en, this message translates to:
  /// **'Wow, you are so smart!'**
  String get funFactGeneric7;

  /// No description provided for @funFactGeneric8.
  ///
  /// In en, this message translates to:
  /// **'Discover the magic in every multiplication.'**
  String get funFactGeneric8;

  /// No description provided for @tableSelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Select a Table'**
  String get tableSelectionTitle;

  /// No description provided for @tableActionScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Table of {tableNumber}: What to do?'**
  String tableActionScreenTitle(Object tableNumber);

  /// No description provided for @studyAction.
  ///
  /// In en, this message translates to:
  /// **'Study a Table'**
  String get studyAction;

  /// No description provided for @quizAction.
  ///
  /// In en, this message translates to:
  /// **'Take a Quiz'**
  String get quizAction;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Start adventure'**
  String get onboardingStart;

  /// No description provided for @onboardingSlide1Title.
  ///
  /// In en, this message translates to:
  /// **'Turn multiplication into your superpower'**
  String get onboardingSlide1Title;

  /// No description provided for @onboardingSlide1Description.
  ///
  /// In en, this message translates to:
  /// **'Learn with dynamic challenges and discover that math practice can feel exciting and fun.'**
  String get onboardingSlide1Description;

  /// No description provided for @onboardingSlide2Title.
  ///
  /// In en, this message translates to:
  /// **'Level up every round'**
  String get onboardingSlide2Title;

  /// No description provided for @onboardingSlide2Description.
  ///
  /// In en, this message translates to:
  /// **'Answer faster, build confidence, and sharpen your mind with short focused sessions.'**
  String get onboardingSlide2Description;

  /// No description provided for @onboardingSlide3Title.
  ///
  /// In en, this message translates to:
  /// **'Break your own records'**
  String get onboardingSlide3Title;

  /// No description provided for @onboardingSlide3Description.
  ///
  /// In en, this message translates to:
  /// **'Track your progress, celebrate every win, and master each table like a champion.'**
  String get onboardingSlide3Description;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'What do you want to do today?'**
  String get homeGreeting;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
