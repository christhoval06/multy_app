// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Tablas de Multiplicar';

  @override
  String get selectTableTitle => 'Selecciona una opción';

  @override
  String get selectTablePrompt => '¿Qué tabla quieres practicar hoy?';

  @override
  String get selectStudyTableTitle => 'Elige una tabla para estudiar';

  @override
  String get selectStudyTablePrompt => 'Escoge una tabla y explórala paso a paso a tu propio ritmo.';

  @override
  String get selectStudyTableHelper => 'Repasa patrones, repite operaciones y gana confianza antes del quiz.';

  @override
  String get selectQuizTableTitle => 'Elige una tabla para tu quiz';

  @override
  String get selectQuizTablePrompt => 'Escoge una tabla y pon a prueba tu rapidez con un reto corto.';

  @override
  String get selectQuizTableHelper => 'Responderás preguntas rápidas y verás tu puntaje al instante.';

  @override
  String get tableCardStudyLabel => 'Modo estudio';

  @override
  String get tableCardQuizLabel => 'Modo quiz';

  @override
  String get practiceButton => '¡Practicar!';

  @override
  String practiceScreenTitle(int tableNumber) {
    return 'Practicando la Tabla del $tableNumber';
  }

  @override
  String multiplicationOperation(int factor1, int factor2) {
    return '$factor1 x $factor2 = ';
  }

  @override
  String get answerHint => '?';

  @override
  String get gradeButton => 'Calificar';

  @override
  String get tryAgainButton => 'Intentar de Nuevo';

  @override
  String get summaryDialogTitle => 'Resumen';

  @override
  String get congratulationsDialogTitle => '¡Felicidades!';

  @override
  String summaryDialogContent(int correctCount) {
    return 'Tienes $correctCount de 12 respuestas correctas.';
  }

  @override
  String get dialogOkButton => 'OK';

  @override
  String correctAnswerWas(int correctAnswer) {
    return 'Era $correctAnswer';
  }

  @override
  String get practiceScreenTestButton => '¡Hacer un Test!';

  @override
  String quizScreenTitle(int tableNumber) {
    return 'Test: Tabla del $tableNumber';
  }

  @override
  String get quizTimeLabel => 'Tiempo';

  @override
  String quizQuestionProgress(Object current, Object total) {
    return 'Pregunta $current / $total';
  }

  @override
  String get quizEndedMessage => '¡Test Finalizado!';

  @override
  String get quizTimeOutTitle => '¡Se acabó el tiempo!';

  @override
  String get quizCompleteTitle => '¡Test Completado!';

  @override
  String quizScoreMessage(Object score, Object total) {
    return 'Tu puntaje: $score de $total';
  }

  @override
  String quizPercentageMessage(Object percentage) {
    return 'Porcentaje: $percentage%';
  }

  @override
  String get quizPassedMessage => '¡Aprobaste!';

  @override
  String get quizFailedMessage => '¡Sigue practicando!';

  @override
  String get quizRetryButton => 'Volver a intentar';

  @override
  String get quizBackToMenuButton => 'Volver al Menú';

  @override
  String get quizCannotExitMessage => '¡No puedes salir del test mientras está en progreso!';

  @override
  String quizResultScreenTitle(Object tableNumber) {
    return 'Resultados: Tabla del $tableNumber';
  }

  @override
  String get quizPassedMessageLarge => '¡FELICIDADES!';

  @override
  String get quizFailedMessageLarge => '¡OH NO! ¡SIGUE INTENTANDO!';

  @override
  String quizScoreDetailed(Object score, Object total) {
    return 'Obtuviste $score de $total respuestas correctas.';
  }

  @override
  String quizPercentageDetailed(Object percentage) {
    return 'Eso es un $percentage% de acierto.';
  }

  @override
  String get quizMainMenuButton => 'Menú Principal';

  @override
  String get quizResultTimedOutInfo => 'Se acabó el tiempo en esta ocasión.';

  @override
  String get quizResultCorrectLabel => 'Correctas';

  @override
  String get quizResultTimeLabel => 'Tiempo';

  @override
  String get quizResultBestTimeLabel => 'Mejor tiempo';

  @override
  String get quizResultNewRecord => 'Nuevo récord';

  @override
  String get quizResultKeepGoing => '¡Sigue así!';

  @override
  String get quizResultRetryHint => 'Intenta superar tu mejor tiempo';

  @override
  String get statisticsTitle => 'Mi Progreso';

  @override
  String get overallStats => 'Estadísticas Generales';

  @override
  String totalQuizzesPlayed(Object count) {
    return 'Total de Quizzes Jugados: $count';
  }

  @override
  String overallAccuracy(Object accuracy) {
    return 'Precisión General: $accuracy%';
  }

  @override
  String get statsByTable => 'Estadísticas por Tabla';

  @override
  String tableNumberHeader(Object number) {
    return 'Tabla del $number';
  }

  @override
  String attempts(Object count) {
    return 'Intentos: $count';
  }

  @override
  String accuracy(Object accuracy) {
    return 'Precisión: $accuracy%';
  }

  @override
  String bestScore(Object correct, Object total) {
    return 'Mejor: $correct/$total';
  }

  @override
  String get noAttemptsYet => 'Aún no hay intentos para esta tabla.';

  @override
  String get noStatsAvailable => 'Aún no hay estadísticas disponibles. ¡Juega algunos quizzes!';

  @override
  String get loadingStats => 'Cargando estadísticas...';

  @override
  String statsForProfile(Object name) {
    return 'Mostrando el progreso de $name';
  }

  @override
  String get statsGuestTitle => 'Sesión de invitado';

  @override
  String get statsGuestSubtitle => 'Las sesiones de invitado no se guardan, así que todavía no hay historial.';

  @override
  String get statsNoProfileTitle => 'No hay perfil seleccionado';

  @override
  String get statsNoProfileSubtitle => 'Elige un perfil en inicio para ver el progreso guardado.';

  @override
  String get sessionHistoryTitle => 'Historial de sesiones';

  @override
  String get sessionHistorySubtitle => 'Tus quizzes más recientes para este perfil.';

  @override
  String get sessionHistoryEmpty => 'Todavía no hay sesiones guardadas para este perfil.';

  @override
  String sessionHistoryScore(Object correct, Object total) {
    return 'Puntaje $correct/$total';
  }

  @override
  String sessionHistoryAccuracy(Object accuracy) {
    return 'Precisión $accuracy%';
  }

  @override
  String sessionHistoryShowAll(int count) {
    return 'Ver los $count quizzes';
  }

  @override
  String get sessionHistoryShowLess => 'Ver menos';

  @override
  String bestTime(String time) {
    return 'Mejor Tiempo: $time';
  }

  @override
  String get menuStats => 'Ver Estadísticas';

  @override
  String get menuSettings => 'Configuración';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get settingsLoading => 'Cargando...';

  @override
  String get settingsAppName => 'Multy';

  @override
  String get settingsAppDescription => 'Una aplicación educativa desarrollada en Flutter para que los niños de 4 a 10 años puedan aprender y practicar las tablas de multiplicación de forma divertida, rápida e interactiva.';

  @override
  String get settingsVersionNotAvailable => 'No disponible';

  @override
  String get settingsCouldNotOpenEmail => 'No se pudo abrir la app de correo.';

  @override
  String settingsCouldNotOpenLink(Object urlString) {
    return 'No se pudo abrir el enlace: $urlString';
  }

  @override
  String get settingsDestructiveActionTitle => '⚠️ ¡Acción Destructiva!';

  @override
  String get settingsDestructiveActionContent => 'Estás a punto de borrar TODOS los datos de la aplicación.\n\nEsta acción NO SE PUEDE DESHACER.\n\n¿Estás absolutamente seguro?';

  @override
  String get settingsCancel => 'CANCELAR';

  @override
  String get settingsConfirmDeleteAll => 'SÍ, BORRAR TODO';

  @override
  String get settingsFinalConfirmationTitle => 'CONFIRMACIÓN FINAL';

  @override
  String get settingsFinalConfirmationContent => 'Para confirmar, escribe \"BORRAR\" en el campo de abajo:';

  @override
  String get settingsFinalConfirmationHint => 'BORRAR';

  @override
  String get settingsDeleteDataNow => 'BORRAR DATOS AHORA';

  @override
  String get settingsIncorrectConfirmationText => 'Texto de confirmación incorrecto.';

  @override
  String get settingsAllDataDeleted => 'Todos los datos han sido borrados.';

  @override
  String get settingsSectionAppInfo => 'Información de la App';

  @override
  String get settingsSectionFeedback => 'Sonido y vibración';

  @override
  String get settingsSoundTitle => 'Sonidos';

  @override
  String get settingsSoundSubtitle => 'Reproduce sonidos cortos al elegir perfiles y mostrar resultados.';

  @override
  String get settingsSoundOn => 'Sonido activo';

  @override
  String get settingsSoundOff => 'Sonido apagado';

  @override
  String get settingsVibrationTitle => 'Vibración';

  @override
  String get settingsVibrationSubtitle => 'Usa vibración suave para selecciones y resultados.';

  @override
  String get settingsVibrationOn => 'Vibración activa';

  @override
  String get settingsVibrationOff => 'Vibración apagada';

  @override
  String get settingsAppVersion => 'Versión de la App';

  @override
  String get settingsTermsAndConditions => 'Términos y Condiciones';

  @override
  String get settingsPrivacyPolicy => 'Política de Privacidad';

  @override
  String get settingsSectionDeveloper => 'Desarrollador';

  @override
  String get settingsDeveloperName => 'Christhoval Barba';

  @override
  String get settingsDeveloperDescription => 'Desarrollador de esta aplicación';

  @override
  String get settingsPorfolio => 'Web Personal';

  @override
  String get settingsPorfolioWeb => 's.christhoval.dev';

  @override
  String get settingsGitHubProfile => 'Perfil de GitHub';

  @override
  String get settingsGitHubUsername => 'github.com/christhoval06';

  @override
  String get settingsLinkedInProfile => 'LinkedIn';

  @override
  String get settingsLinkedInUsername => 'christhoval';

  @override
  String get settingsContactDeveloper => 'Contactar';

  @override
  String get settingsSectionSupport => 'Soporte';

  @override
  String get settingsReportProblem => 'Reportar un Problema';

  @override
  String get settingsSupportSubtitle => 'Enviar comentarios o reportar un problema.';

  @override
  String get settingsSectionProfiles => 'Perfiles';

  @override
  String get settingsSectionTiming => 'Tiempo de práctica';

  @override
  String get settingsStudyTimerTitle => 'Velocidad de tarjetas';

  @override
  String get settingsStudyTimerSubtitle => 'Elige cada cuánto avanzan automáticamente las tarjetas de estudio.';

  @override
  String get settingsQuizTimerTitle => 'Tiempo del quiz';

  @override
  String get settingsQuizTimerSubtitle => 'Define cuánto tiempo tiene cada quiz antes de terminar.';

  @override
  String get settingsRestoreTimerDefaultsTitle => 'Restaurar tiempos por defecto';

  @override
  String get settingsRestoreTimerDefaultsSubtitle => 'Volver a 5s para estudio y 50s para los quizzes.';

  @override
  String get settingsChooseTimerValue => 'Elige un tiempo';

  @override
  String get settingsSectionDataManagement => 'Gestión de Datos';

  @override
  String get settingsManageProfilesTitle => 'Gestionar perfiles';

  @override
  String get settingsManageProfilesSubtitle => 'Crear, editar, archivar o borrar perfiles de estudio.';

  @override
  String settingsProfilesSummary(int count) {
    return '$count perfiles guardados en este dispositivo.';
  }

  @override
  String settingsProfilesActiveSummary(String name) {
    return 'Perfil activo: $name';
  }

  @override
  String settingsOverviewProfiles(int count) {
    return '$count perfiles';
  }

  @override
  String get settingsDeleteProgressSubtitle => 'Elimina todos los intentos de quiz y las estadisticas.';

  @override
  String get settingsDeleteAllDataTitle => 'Borrar Todos los Datos';

  @override
  String get settingsDeleteAllDataSubtitle => 'Elimina todas las rifas, números y compradores.';

  @override
  String studyTableTitle(Object tableNumber) {
    return 'Estudiando la Tabla del $tableNumber';
  }

  @override
  String get previous => 'Anterior';

  @override
  String get next => 'Siguiente';

  @override
  String get speak => 'Hablar';

  @override
  String get speakTimes => 'por';

  @override
  String get speakEquals => 'es igual a';

  @override
  String get funFactTable2Multiplier1 => '¡Tienes 2 ojos para ver el mundo!';

  @override
  String get funFactTable2Multiplier2 => 'Una bicicleta tiene 2 ruedas.';

  @override
  String get funFactTable2Multiplier4 => 'Un par de zapatos son 2 zapatos.';

  @override
  String get funFactTable2Multiplier5 => 'La mayoría de las personas tienen 2 manos y 2 pies.';

  @override
  String get funFactTable2Multiplier10 => '20 es el doble de 10, ¡como tener dos billetes de 10!';

  @override
  String get funFactTable3Multiplier1 => 'Un triciclo tiene 3 ruedas.';

  @override
  String get funFactTable3Multiplier2 => 'Un semáforo tiene 3 luces: rojo, amarillo y verde.';

  @override
  String get funFactTable3Multiplier3 => '¡3 x 3 es 9, un número cuadrado mágico!';

  @override
  String get funFactTable3Multiplier4 => 'Un trébol de la suerte suele tener 3 hojas (¡a veces 4!).';

  @override
  String get funFactTable4Multiplier1 => 'Un cuadrado tiene 4 lados iguales.';

  @override
  String get funFactTable4Multiplier2 => 'La mayoría de los carros tienen 4 ruedas.';

  @override
  String get funFactTable4Multiplier3 => 'Las estaciones del año son 4: primavera, verano, otoño e invierno.';

  @override
  String get funFactTable5Multiplier1 => '¡Tienes 5 dedos en cada mano!';

  @override
  String get funFactTable5Multiplier2 => 'Una estrella de mar comúnmente tiene 5 brazos.';

  @override
  String get funFactTable5Multiplier3 => 'Un pentágono es una figura con 5 lados.';

  @override
  String get funFactTable5Multiplier4 => 'Un lustro son 5 años.';

  @override
  String get funFactTable5Multiplier10 => 'Contar hasta 50 es como contar 5 veces hasta 10.';

  @override
  String get funFactTable6Multiplier1 => 'Un dado común tiene 6 caras.';

  @override
  String get funFactTable6Multiplier2 => 'Los insectos tienen 6 patas.';

  @override
  String get funFactTable6Multiplier3 => 'Una guitarra normalmente tiene 6 cuerdas.';

  @override
  String get funFactTable7Multiplier1 => '¡Hay 7 días en una semana!';

  @override
  String get funFactTable7Multiplier2 => 'Los colores del arcoíris son 7.';

  @override
  String get funFactTable7Multiplier3 => 'Blancanieves conoció a 7 enanitos.';

  @override
  String get funFactTable7Multiplier4 => 'Las 7 maravillas del mundo antiguo eran construcciones asombrosas.';

  @override
  String get funFactTable8Multiplier1 => 'Una araña tiene 8 patas.';

  @override
  String get funFactTable8Multiplier2 => 'Un pulpo tiene 8 tentáculos.';

  @override
  String get funFactTable8Multiplier3 => 'En música, una octava tiene 8 notas.';

  @override
  String get funFactTable9Multiplier1 => 'Un gato tiene fama de tener 9 vidas (¡es solo un dicho!).';

  @override
  String get funFactTable9Multiplier2 => 'Un partido de béisbol completo tiene 9 entradas (innings).';

  @override
  String get funFactTable9Multiplier3 => 'Un Sudoku se juega en una cuadrícula de 9x9.';

  @override
  String get funFactTable10Multiplier1 => '¡Tienes 10 dedos en total en tus manos!';

  @override
  String get funFactTable10Multiplier2 => 'Una década son 10 años.';

  @override
  String get funFactTable10Multiplier3 => 'El sistema decimal que usamos se basa en el número 10.';

  @override
  String get funFactTable10Multiplier5 => '50 es la mitad de 100, ¡y 5 x 10!';

  @override
  String get funFactTable11Multiplier1 => 'Un equipo de fútbol tiene 11 jugadores en el campo.';

  @override
  String get funFactTable11Multiplier2 => 'Si cuentas los dedos de tus manos y un pie, ¡casi llegas a 11 (son 15)!';

  @override
  String get funFactTable12Multiplier1 => 'Un año tiene 12 meses.';

  @override
  String get funFactTable12Multiplier2 => 'Una docena son 12 cosas, ¡como una docena de huevos!';

  @override
  String get funFactTable12Multiplier3 => 'Un reloj marca 12 horas (en formato de 12 horas).';

  @override
  String get funFactGeneric1 => '¡Las matemáticas son como un superpoder!';

  @override
  String get funFactGeneric2 => 'Practicar un poquito cada día te hace un campeón de las tablas.';

  @override
  String get funFactGeneric3 => '¡Sigue así, lo estás haciendo de maravilla!';

  @override
  String get funFactGeneric4 => 'Los números nos ayudan a entender el mundo.';

  @override
  String get funFactGeneric5 => 'Aprender es la mejor aventura.';

  @override
  String get funFactGeneric6 => 'Cada número tiene su propia historia secreta.';

  @override
  String get funFactGeneric7 => '¡Wow, eres muy inteligente!';

  @override
  String get funFactGeneric8 => 'Descubre la magia en cada multiplicación.';

  @override
  String get tableSelectionTitle => 'Selecciona una Tabla';

  @override
  String tableActionScreenTitle(Object tableNumber) {
    return 'Tabla del $tableNumber: ¿Qué quieres hacer?';
  }

  @override
  String get studyAction => 'Estudiar una Tabla';

  @override
  String get quizAction => 'Hacer un Quiz';

  @override
  String get onboardingSkip => 'Saltar';

  @override
  String get onboardingNext => 'Siguiente';

  @override
  String get onboardingStart => 'Comenzar aventura';

  @override
  String get onboardingSlide1Title => 'Convierte las tablas en tu superpoder';

  @override
  String get onboardingSlide1Description => 'Aprende con retos dinamicos y descubre que multiplicar puede ser increiblemente divertido.';

  @override
  String get onboardingSlide2Title => 'Sube de nivel en cada ronda';

  @override
  String get onboardingSlide2Description => 'Responde rapido, gana confianza y acelera tu mente con practicas cortas y efectivas.';

  @override
  String get onboardingSlide3Title => 'Rompe tus propios records';

  @override
  String get onboardingSlide3Description => 'Sigue tu progreso, celebra tus logros y conquista cada tabla como un campeon.';

  @override
  String get homeGreeting => '¿Qué deseas hacer hoy?';

  @override
  String get homeProfileSelectorTitle => 'Elige quién va a estudiar';

  @override
  String get homeProfileSelectorSubtitle => 'Selecciona un perfil antes de empezar a estudiar o hacer un quiz.';

  @override
  String get homeProfileGuestLabel => 'Invitado';

  @override
  String get homeProfileSelectionRequired => 'Selecciona un perfil para continuar';

  @override
  String homeProfileActiveSummary(String name) {
    return 'Estudiará $name';
  }

  @override
  String get homeProfileGuestSummary => 'Modo invitado activo';

  @override
  String get homeProfileGuestHelper => 'Ideal para una práctica rápida sin guardar historial.';

  @override
  String get homeProfileActiveHelper => 'El progreso y el historial se guardarán solo para este perfil.';

  @override
  String get homeProfileNoSelectionHelper => 'Elige un perfil o entra como invitado para empezar.';

  @override
  String get profileManagementTitle => 'Perfiles';

  @override
  String get profileManagementSubtitle => 'Configura los perfiles que pueden estudiar en este dispositivo.';

  @override
  String get profileManagementCreateAction => 'Crear perfil';

  @override
  String get profileManagementEditAction => 'Editar';

  @override
  String get profileManagementArchiveAction => 'Archivar';

  @override
  String get profileManagementDeleteAction => 'Borrar';

  @override
  String get profileManagementProfileSummary => 'Perfil persistente con progreso e historial separados.';

  @override
  String get profileManagementArchivedSummary => 'Perfil archivado. Ya no aparece en el selector del inicio.';

  @override
  String profileManagementMaxProfiles(int count) {
    return 'Puedes tener hasta $count perfiles guardados.';
  }

  @override
  String profileManagementSavedCount(int current, int max) {
    return '$current de $max perfiles guardados';
  }

  @override
  String get profileManagementGuestHint => 'Invitado siempre estará disponible en el inicio para sesiones temporales.';

  @override
  String get profileManagementActiveBadge => 'Activo';

  @override
  String get profileManagementArchivedBadge => 'Archivado';

  @override
  String get profileManagementArchiveTitle => '¿Archivar perfil?';

  @override
  String profileManagementArchiveMessage(String name) {
    return 'El perfil $name dejará de aparecer en el selector del inicio.';
  }

  @override
  String get profileManagementDeleteTitle => '¿Borrar perfil?';

  @override
  String profileManagementDeleteMessage(String name) {
    return 'El perfil $name se eliminará de este dispositivo.';
  }

  @override
  String get profileManagementCreateError => 'No se pudo crear el perfil.';

  @override
  String get profileManagementEditError => 'No se pudo actualizar el perfil.';

  @override
  String get profileManagementArchiveError => 'No se pudo archivar el perfil.';

  @override
  String get profileManagementDeleteError => 'No se pudo borrar el perfil.';

  @override
  String get profileFormCreateTitle => 'Crear perfil';

  @override
  String get profileFormEditTitle => 'Editar perfil';

  @override
  String get profileFormNameLabel => 'Nombre';

  @override
  String get profileFormNameHint => 'Ejemplo: Mateo';

  @override
  String get profileFormNameRequired => 'Ingresa un nombre para el perfil.';

  @override
  String get profileFormAvatarLabel => 'Avatar';

  @override
  String get profileFormColorLabel => 'Color';

  @override
  String get profileFormPreviewLabel => 'Vista previa';

  @override
  String get profileFormPreviewPlaceholder => 'Tu perfil';

  @override
  String get profileFormCreateButton => 'Guardar perfil';

  @override
  String get profileFormSaveButton => 'Guardar cambios';
}
