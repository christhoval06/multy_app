// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Multiplication Tables';

  @override
  String get selectTableTitle => 'Select a option';

  @override
  String get selectTablePrompt => 'Which table do you want to practice today?';

  @override
  String get selectStudyTableTitle => 'Choose a table to study';

  @override
  String get selectStudyTablePrompt => 'Pick a table and explore it step by step at your own pace.';

  @override
  String get selectStudyTableHelper => 'Review patterns, repeat facts, and build confidence before the quiz.';

  @override
  String get selectQuizTableTitle => 'Choose a table for your quiz';

  @override
  String get selectQuizTablePrompt => 'Pick a table and test your speed with a quick challenge.';

  @override
  String get selectQuizTableHelper => 'You will answer fast questions and see your score right away.';

  @override
  String get tableCardStudyLabel => 'Study mode';

  @override
  String get tableCardQuizLabel => 'Quiz mode';

  @override
  String get practiceButton => 'Practice!';

  @override
  String practiceScreenTitle(int tableNumber) {
    return 'Practicing Table $tableNumber';
  }

  @override
  String multiplicationOperation(int factor1, int factor2) {
    return '$factor1 x $factor2 = ';
  }

  @override
  String get answerHint => '?';

  @override
  String get gradeButton => 'Grade';

  @override
  String get tryAgainButton => 'Try Again';

  @override
  String get summaryDialogTitle => 'Summary';

  @override
  String get congratulationsDialogTitle => 'Congratulations!';

  @override
  String summaryDialogContent(int correctCount) {
    return 'You got $correctCount out of 12 correct answers.';
  }

  @override
  String get dialogOkButton => 'OK';

  @override
  String correctAnswerWas(int correctAnswer) {
    return 'It was $correctAnswer';
  }

  @override
  String get practiceScreenTestButton => 'Take a Quiz!';

  @override
  String quizScreenTitle(int tableNumber) {
    return 'Quiz: Table $tableNumber';
  }

  @override
  String get quizTimeLabel => 'Time';

  @override
  String quizQuestionProgress(Object current, Object total) {
    return 'Question $current / $total';
  }

  @override
  String get quizEndedMessage => 'Quiz Finished!';

  @override
  String get quizTimeOutTitle => 'Time\'s Up!';

  @override
  String get quizCompleteTitle => 'Quiz Complete!';

  @override
  String quizScoreMessage(Object score, Object total) {
    return 'Your score: $score out of $total';
  }

  @override
  String quizPercentageMessage(Object percentage) {
    return 'Percentage: $percentage%';
  }

  @override
  String get quizPassedMessage => 'You passed!';

  @override
  String get quizFailedMessage => 'Keep practicing!';

  @override
  String get quizRetryButton => 'Retry';

  @override
  String get quizBackToMenuButton => 'Back to Menu';

  @override
  String get quizCannotExitMessage => 'You cannot exit the quiz while it\'s in progress!';

  @override
  String quizResultScreenTitle(Object tableNumber) {
    return 'Results: Table $tableNumber';
  }

  @override
  String get quizPassedMessageLarge => 'CONGRATULATIONS!';

  @override
  String get quizFailedMessageLarge => 'OH NO! KEEP TRYING!';

  @override
  String quizScoreDetailed(Object score, Object total) {
    return 'You got $score out of $total correct answers.';
  }

  @override
  String quizPercentageDetailed(Object percentage) {
    return 'That\'s a $percentage% accuracy.';
  }

  @override
  String get quizMainMenuButton => 'Main Menu';

  @override
  String get quizResultTimedOutInfo => 'You ran out of time on this attempt.';

  @override
  String get quizResultCorrectLabel => 'Correct';

  @override
  String get quizResultTimeLabel => 'Time';

  @override
  String get quizResultBestTimeLabel => 'Best time';

  @override
  String get quizResultNewRecord => 'New record';

  @override
  String get quizResultKeepGoing => 'Keep going!';

  @override
  String get quizResultRetryHint => 'Beat your best time';

  @override
  String get statisticsTitle => 'My Progress';

  @override
  String get overallStats => 'Overall Statistics';

  @override
  String totalQuizzesPlayed(Object count) {
    return 'Total Quizzes Played: $count';
  }

  @override
  String overallAccuracy(Object accuracy) {
    return 'Overall Accuracy: $accuracy%';
  }

  @override
  String get statsByTable => 'Statistics by Table';

  @override
  String tableNumberHeader(Object number) {
    return 'Table $number';
  }

  @override
  String attempts(Object count) {
    return 'Attempts: $count';
  }

  @override
  String accuracy(Object accuracy) {
    return 'Accuracy: $accuracy%';
  }

  @override
  String bestScore(Object correct, Object total) {
    return 'Best: $correct/$total';
  }

  @override
  String get noAttemptsYet => 'No attempts yet for this table.';

  @override
  String get noStatsAvailable => 'No statistics available yet. Play some quizzes!';

  @override
  String get loadingStats => 'Loading statistics...';

  @override
  String statsForProfile(Object name) {
    return 'Showing progress for $name';
  }

  @override
  String get statsGuestTitle => 'Guest session';

  @override
  String get statsGuestSubtitle => 'Guest sessions are not saved, so there is no history yet.';

  @override
  String get statsNoProfileTitle => 'No profile selected';

  @override
  String get statsNoProfileSubtitle => 'Choose a profile on the home screen to see saved progress.';

  @override
  String get sessionHistoryTitle => 'Session History';

  @override
  String get sessionHistorySubtitle => 'Your most recent quizzes for this profile.';

  @override
  String get sessionHistoryEmpty => 'No saved sessions yet for this profile.';

  @override
  String sessionHistoryScore(Object correct, Object total) {
    return 'Score $correct/$total';
  }

  @override
  String sessionHistoryAccuracy(Object accuracy) {
    return 'Accuracy $accuracy%';
  }

  @override
  String sessionHistoryShowAll(int count) {
    return 'Show all $count quizzes';
  }

  @override
  String get sessionHistoryShowLess => 'Show less';

  @override
  String bestTime(String time) {
    return 'Best Time: $time';
  }

  @override
  String get menuStats => 'Show Stats';

  @override
  String get menuSettings => 'Settings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLoading => 'Loading...';

  @override
  String get settingsAppName => 'Multy';

  @override
  String get settingsAppDescription => 'An educational application developed in Flutter for children aged 4 to 10 to learn and practice multiplication tables in a fun, fast, and interactive way.';

  @override
  String get settingsVersionNotAvailable => 'Not available';

  @override
  String get settingsCouldNotOpenEmail => 'Could not open email app.';

  @override
  String settingsCouldNotOpenLink(Object urlString) {
    return 'Could not open link: $urlString';
  }

  @override
  String get settingsDestructiveActionTitle => '⚠️ Destructive Action!';

  @override
  String get settingsDestructiveActionContent => 'You are about to delete ALL application data.\n\nThis action CANNOT BE UNDONE.\n\nAre you absolutely sure?';

  @override
  String get settingsCancel => 'CANCEL';

  @override
  String get settingsConfirmDeleteAll => 'YES, DELETE ALL';

  @override
  String get settingsFinalConfirmationTitle => 'FINAL CONFIRMATION';

  @override
  String get settingsFinalConfirmationContent => 'To confirm, type \"DELETE\" in the field below:';

  @override
  String get settingsFinalConfirmationHint => 'DELETE';

  @override
  String get settingsDeleteDataNow => 'DELETE DATA NOW';

  @override
  String get settingsIncorrectConfirmationText => 'Incorrect confirmation text.';

  @override
  String get settingsAllDataDeleted => 'All data has been deleted.';

  @override
  String get settingsSectionAppInfo => 'App Information';

  @override
  String get settingsSectionFeedback => 'Sound & vibration';

  @override
  String get settingsSoundTitle => 'Sounds';

  @override
  String get settingsSoundSubtitle => 'Play short sounds when selecting profiles and showing results.';

  @override
  String get settingsSoundOn => 'Sound on';

  @override
  String get settingsSoundOff => 'Sound off';

  @override
  String get settingsVibrationTitle => 'Vibration';

  @override
  String get settingsVibrationSubtitle => 'Use gentle vibration for selections and results.';

  @override
  String get settingsVibrationOn => 'Vibration on';

  @override
  String get settingsVibrationOff => 'Vibration off';

  @override
  String get settingsAppVersion => 'App Version';

  @override
  String get settingsTermsAndConditions => 'Terms and Conditions';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsSectionDeveloper => 'Developer';

  @override
  String get settingsDeveloperName => 'Christhoval Barba';

  @override
  String get settingsDeveloperDescription => 'Developer of this application';

  @override
  String get settingsPorfolio => 'Personal Site';

  @override
  String get settingsPorfolioWeb => 's.christhoval.dev';

  @override
  String get settingsGitHubProfile => 'GitHub Profile';

  @override
  String get settingsGitHubUsername => 'github.com/christhoval06';

  @override
  String get settingsLinkedInProfile => 'LinkedIn';

  @override
  String get settingsLinkedInUsername => 'christhoval';

  @override
  String get settingsContactDeveloper => 'Contact';

  @override
  String get settingsSectionSupport => 'Support';

  @override
  String get settingsReportProblem => 'Report a Problem';

  @override
  String get settingsSupportSubtitle => 'Send feedback or report an issue.';

  @override
  String get settingsSectionProfiles => 'Profiles';

  @override
  String get settingsSectionTiming => 'Practice Timing';

  @override
  String get settingsStudyTimerTitle => 'Study card speed';

  @override
  String get settingsStudyTimerSubtitle => 'Choose how fast the study cards move automatically.';

  @override
  String get settingsQuizTimerTitle => 'Quiz time limit';

  @override
  String get settingsQuizTimerSubtitle => 'Set how much time each quiz gives before it ends.';

  @override
  String get settingsRestoreTimerDefaultsTitle => 'Restore default timers';

  @override
  String get settingsRestoreTimerDefaultsSubtitle => 'Back to 5s for study cards and 50s for quizzes.';

  @override
  String get settingsChooseTimerValue => 'Choose a time';

  @override
  String get settingsSectionDataManagement => 'Data Management';

  @override
  String get settingsManageProfilesTitle => 'Manage profiles';

  @override
  String get settingsManageProfilesSubtitle => 'Create, edit, archive, or delete study profiles.';

  @override
  String settingsProfilesSummary(int count) {
    return '$count saved profiles on this device.';
  }

  @override
  String settingsProfilesActiveSummary(String name) {
    return 'Active profile: $name';
  }

  @override
  String settingsOverviewProfiles(int count) {
    return '$count profiles';
  }

  @override
  String get settingsDeleteProgressSubtitle => 'Deletes all quiz attempts and statistics.';

  @override
  String get settingsDeleteAllDataTitle => 'Delete All Data';

  @override
  String get settingsDeleteAllDataSubtitle => 'Deletes all raffles, numbers, and buyers.';

  @override
  String studyTableTitle(Object tableNumber) {
    return 'Studying the Table of $tableNumber';
  }

  @override
  String get previous => 'Previous';

  @override
  String get next => 'Next';

  @override
  String get speak => 'Speak';

  @override
  String get speakTimes => 'times';

  @override
  String get speakEquals => 'equals';

  @override
  String get funFactTable2Multiplier1 => 'You have 2 eyes to see the world!';

  @override
  String get funFactTable2Multiplier2 => 'A bicycle has 2 wheels.';

  @override
  String get funFactTable2Multiplier4 => 'A pair of shoes are 2 shoes.';

  @override
  String get funFactTable2Multiplier5 => 'Most people have 2 hands and 2 feet.';

  @override
  String get funFactTable2Multiplier10 => '20 is double 10, like having two 10-dollar bills!';

  @override
  String get funFactTable3Multiplier1 => 'A tricycle has 3 wheels.';

  @override
  String get funFactTable3Multiplier2 => 'A traffic light has 3 lights: red, yellow, and green.';

  @override
  String get funFactTable3Multiplier3 => '3 x 3 is 9, a magical square number!';

  @override
  String get funFactTable3Multiplier4 => 'A lucky clover usually has 3 leaves (sometimes 4!).';

  @override
  String get funFactTable4Multiplier1 => 'A square has 4 equal sides.';

  @override
  String get funFactTable4Multiplier2 => 'Most cars have 4 wheels.';

  @override
  String get funFactTable4Multiplier3 => 'The seasons of the year are 4: spring, summer, autumn, and winter.';

  @override
  String get funFactTable5Multiplier1 => 'You have 5 fingers on each hand!';

  @override
  String get funFactTable5Multiplier2 => 'A starfish commonly has 5 arms.';

  @override
  String get funFactTable5Multiplier3 => 'A pentagon is a shape with 5 sides.';

  @override
  String get funFactTable5Multiplier4 => 'A lustrum is 5 years.';

  @override
  String get funFactTable5Multiplier10 => 'Counting to 50 is like counting 5 times to 10.';

  @override
  String get funFactTable6Multiplier1 => 'A common die has 6 faces.';

  @override
  String get funFactTable6Multiplier2 => 'Insects have 6 legs.';

  @override
  String get funFactTable6Multiplier3 => 'A guitar usually has 6 strings.';

  @override
  String get funFactTable7Multiplier1 => 'There are 7 days in a week!';

  @override
  String get funFactTable7Multiplier2 => 'The colors of the rainbow are 7.';

  @override
  String get funFactTable7Multiplier3 => 'Snow White met 7 dwarfs.';

  @override
  String get funFactTable7Multiplier4 => 'The 7 wonders of the ancient world were amazing constructions.';

  @override
  String get funFactTable8Multiplier1 => 'A spider has 8 legs.';

  @override
  String get funFactTable8Multiplier2 => 'An octopus has 8 tentacles.';

  @override
  String get funFactTable8Multiplier3 => 'In music, an octave has 8 notes.';

  @override
  String get funFactTable9Multiplier1 => 'A cat is said to have 9 lives (it\'s just a saying!).';

  @override
  String get funFactTable9Multiplier2 => 'A full baseball game has 9 innings.';

  @override
  String get funFactTable9Multiplier3 => 'Sudoku is played on a 9x9 grid.';

  @override
  String get funFactTable10Multiplier1 => 'You have 10 fingers in total on your hands!';

  @override
  String get funFactTable10Multiplier2 => 'A decade is 10 years.';

  @override
  String get funFactTable10Multiplier3 => 'The decimal system we use is based on the number 10.';

  @override
  String get funFactTable10Multiplier5 => '50 is half of 100, and 5 x 10!';

  @override
  String get funFactTable11Multiplier1 => 'A soccer team has 11 players on the field.';

  @override
  String get funFactTable11Multiplier2 => 'If you count your fingers and one foot, you almost get to 11 (it\'s 15)!';

  @override
  String get funFactTable12Multiplier1 => 'A year has 12 months.';

  @override
  String get funFactTable12Multiplier2 => 'A dozen is 12 things, like a dozen eggs!';

  @override
  String get funFactTable12Multiplier3 => 'A clock shows 12 hours (in 12-hour format).';

  @override
  String get funFactGeneric1 => 'Math is like a superpower!';

  @override
  String get funFactGeneric2 => 'Practicing a little bit every day makes you a tables champion.';

  @override
  String get funFactGeneric3 => 'Keep it up, you\'re doing wonderfully!';

  @override
  String get funFactGeneric4 => 'Numbers help us understand the world.';

  @override
  String get funFactGeneric5 => 'Learning is the best adventure.';

  @override
  String get funFactGeneric6 => 'Every number has its own secret story.';

  @override
  String get funFactGeneric7 => 'Wow, you are so smart!';

  @override
  String get funFactGeneric8 => 'Discover the magic in every multiplication.';

  @override
  String get tableSelectionTitle => 'Select a Table';

  @override
  String tableActionScreenTitle(Object tableNumber) {
    return 'Table of $tableNumber: What to do?';
  }

  @override
  String get studyAction => 'Study a Table';

  @override
  String get quizAction => 'Take a Quiz';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStart => 'Start adventure';

  @override
  String get onboardingSlide1Title => 'Turn multiplication into your superpower';

  @override
  String get onboardingSlide1Description => 'Learn with dynamic challenges and discover that math practice can feel exciting and fun.';

  @override
  String get onboardingSlide2Title => 'Level up every round';

  @override
  String get onboardingSlide2Description => 'Answer faster, build confidence, and sharpen your mind with short focused sessions.';

  @override
  String get onboardingSlide3Title => 'Break your own records';

  @override
  String get onboardingSlide3Description => 'Track your progress, celebrate every win, and master each table like a champion.';

  @override
  String get homeGreeting => 'What do you want to do today?';

  @override
  String get homeProfileSelectorTitle => 'Choose who is studying';

  @override
  String get homeProfileSelectorSubtitle => 'Pick a profile before starting to study or take a quiz.';

  @override
  String get homeProfileGuestLabel => 'Guest';

  @override
  String get homeProfileSelectionRequired => 'Select a profile to continue';

  @override
  String homeProfileActiveSummary(String name) {
    return '$name will study';
  }

  @override
  String get homeProfileGuestSummary => 'Guest mode is active';

  @override
  String get homeProfileGuestHelper => 'Great for a quick practice session without saving history.';

  @override
  String get homeProfileActiveHelper => 'Progress and history will be saved only for this profile.';

  @override
  String get homeProfileNoSelectionHelper => 'Choose a profile or enter as guest to get started.';

  @override
  String get profileManagementTitle => 'Profiles';

  @override
  String get profileManagementSubtitle => 'Set up the profiles that can study on this device.';

  @override
  String get profileManagementCreateAction => 'Create profile';

  @override
  String get profileManagementEditAction => 'Edit';

  @override
  String get profileManagementArchiveAction => 'Archive';

  @override
  String get profileManagementDeleteAction => 'Delete';

  @override
  String get profileManagementProfileSummary => 'Persistent profile with separate progress and history.';

  @override
  String get profileManagementArchivedSummary => 'Archived profile. It no longer appears on the home selector.';

  @override
  String profileManagementMaxProfiles(int count) {
    return 'You can have up to $count saved profiles.';
  }

  @override
  String profileManagementSavedCount(int current, int max) {
    return '$current of $max saved profiles';
  }

  @override
  String get profileManagementGuestHint => 'Guest will always be available on home for temporary sessions.';

  @override
  String get profileManagementActiveBadge => 'Active';

  @override
  String get profileManagementArchivedBadge => 'Archived';

  @override
  String get profileManagementArchiveTitle => 'Archive profile?';

  @override
  String profileManagementArchiveMessage(String name) {
    return 'The profile $name will stop appearing on the home selector.';
  }

  @override
  String get profileManagementDeleteTitle => 'Delete profile?';

  @override
  String profileManagementDeleteMessage(String name) {
    return 'The profile $name will be removed from the device.';
  }

  @override
  String get profileManagementCreateError => 'The profile could not be created.';

  @override
  String get profileManagementEditError => 'The profile could not be updated.';

  @override
  String get profileManagementArchiveError => 'The profile could not be archived.';

  @override
  String get profileManagementDeleteError => 'The profile could not be deleted.';

  @override
  String get profileFormCreateTitle => 'Create profile';

  @override
  String get profileFormEditTitle => 'Edit profile';

  @override
  String get profileFormNameLabel => 'Name';

  @override
  String get profileFormNameHint => 'Example: Mateo';

  @override
  String get profileFormNameRequired => 'Enter a profile name.';

  @override
  String get profileFormAvatarLabel => 'Avatar';

  @override
  String get profileFormColorLabel => 'Color';

  @override
  String get profileFormPreviewLabel => 'Preview';

  @override
  String get profileFormPreviewPlaceholder => 'Your profile';

  @override
  String get profileFormCreateButton => 'Save profile';

  @override
  String get profileFormSaveButton => 'Save changes';
}
