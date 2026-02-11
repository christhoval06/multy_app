import 'dart:math';

import 'package:multy_app/l10n/app_localizations.dart';
import 'package:multy_app/configs/settings.dart';

class FunFacts {
  static Map<int, Map<int, String>> getFunFacts(AppLocalizations l10n) => {
    2: {
      1: l10n.funFactTable2Multiplier1,
      2: l10n.funFactTable2Multiplier2,
      4: l10n.funFactTable2Multiplier4,
      5: l10n.funFactTable2Multiplier5,
      10: l10n.funFactTable2Multiplier10,
    },
    3: {
      1: l10n.funFactTable3Multiplier1,
      2: l10n.funFactTable3Multiplier2,
      3: l10n.funFactTable3Multiplier3,
      4: l10n.funFactTable3Multiplier4,
    },
    4: {
      1: l10n.funFactTable4Multiplier1,
      2: l10n.funFactTable4Multiplier2,
      3: l10n.funFactTable4Multiplier3,
    },
    5: {
      1: l10n.funFactTable5Multiplier1,
      2: l10n.funFactTable5Multiplier2,
      3: l10n.funFactTable5Multiplier3,
      4: l10n.funFactTable5Multiplier4,
      10: l10n.funFactTable5Multiplier10,
    },
    6: {
      1: l10n.funFactTable6Multiplier1,
      2: l10n.funFactTable6Multiplier2,
      3: l10n.funFactTable6Multiplier3,
    },
    7: {
      1: l10n.funFactTable7Multiplier1,
      2: l10n.funFactTable7Multiplier2,
      3: l10n.funFactTable7Multiplier3,
      4: l10n.funFactTable7Multiplier4,
    },
    8: {
      1: l10n.funFactTable8Multiplier1,
      2: l10n.funFactTable8Multiplier2,
      3: l10n.funFactTable8Multiplier3,
    },
    9: {
      1: l10n.funFactTable9Multiplier1,
      2: l10n.funFactTable9Multiplier2,
      3: l10n.funFactTable9Multiplier3,
    },
    10: {
      1: l10n.funFactTable10Multiplier1,
      2: l10n.funFactTable10Multiplier2,
      3: l10n.funFactTable10Multiplier3,
      5: l10n.funFactTable10Multiplier5,
    },
    11: {1: l10n.funFactTable11Multiplier1, 2: l10n.funFactTable11Multiplier2},
    12: {
      1: l10n.funFactTable12Multiplier1,
      2: l10n.funFactTable12Multiplier2,
      3: l10n.funFactTable12Multiplier3,
    },
  };

  // Lista de hechos genéricos si no hay uno específico
  static List<String> getGenericFunFact(AppLocalizations l10n) => [
    l10n.funFactGeneric1,
    l10n.funFactGeneric2,
    l10n.funFactGeneric3,
    l10n.funFactGeneric4,
    l10n.funFactGeneric5,
    l10n.funFactGeneric6,
    l10n.funFactGeneric7,
    l10n.funFactGeneric8,
  ];

  static String? getFunFact(int table, int multiplier, AppLocalizations l10n) {
    Map<int, Map<int, String>> funFactsData = getFunFacts(l10n);
    // Intenta obtener una clave de hecho específico
    if (funFactsData.containsKey(table)) {
      if (funFactsData[table]!.containsKey(multiplier)) {
        return funFactsData[table]![multiplier];
      }
    }

    List<String> genericFunFacts = getGenericFunFact(l10n);

    // Estrategia para hechos genéricos:
    // Mostrar un hecho genérico aleatorio si no hay uno específico Y
    // es el primer multiplicador (1), uno intermedio (como 5), o el último.
    // Esto evita que aparezcan hechos genéricos en cada paso si no hay específicos.
    // Puedes ajustar esta lógica según prefieras.

    if (multiplier == 1 ||
        multiplier == 5 ||
        multiplier == Settings.maxMultiplier) {
      if (genericFunFacts.isNotEmpty) {
        final random = Random();
        return genericFunFacts[random.nextInt(genericFunFacts.length)];
      }
    }

    // Si no se encuentra ningún hecho específico o genérico apropiado
    return null;
  }
}
