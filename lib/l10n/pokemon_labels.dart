import 'package:intl/intl.dart';
import '../model/evolution.dart';
import 'app_localizations.dart';

/// "water-stone" → "Water Stone". PokéAPI item and move ids are not translated.
String titleCaseId(String id) => id
    .split('-')
    .where((word) => word.isNotEmpty)
    .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
    .join(' ');

extension PokemonLabels on AppLocalizations {
  /// Short label of a PokéAPI stat id (`special-attack` → "SpA").
  String statLabel(String stat) => switch (stat) {
    'hp' => statHp,
    'attack' => statAttack,
    'defense' => statDefense,
    'special-attack' => statSpecialAttack,
    'special-defense' => statSpecialDefense,
    'speed' => statSpeed,
    _ =>
      stat.length < 3 ? stat.toUpperCase() : stat.substring(0, 3).toUpperCase(),
  };

  /// A number with at most one decimal, in the current language
  /// (`90.5` → "90.5" / "90,5", `170.0` → "170").
  String decimal(double value) => NumberFormat('0.#', localeName).format(value);

  /// Short text for how a stage is reached ("Lv. 16", "Water Stone", …).
  String evolutionRequirementLabel(EvolutionRequirement? requirement) {
    if (requirement == null) return '';
    final parts = <String>[
      if (requirement.minLevel != null) evolutionLevel(requirement.minLevel!),
      if (requirement.item != null) titleCaseId(requirement.item!),
      if (requirement.trigger == 'trade') evolutionTrade,
      if (requirement.minHappiness != null) evolutionFriendship,
      if (requirement.timeOfDay == 'day') evolutionDay,
      if (requirement.timeOfDay == 'night') evolutionNight,
      if (requirement.heldItem != null)
        evolutionHolding(titleCaseId(requirement.heldItem!)),
      if (requirement.knownMove != null)
        evolutionKnowing(titleCaseId(requirement.knownMove!)),
    ];
    if (parts.isNotEmpty) return parts.join(' · ');
    return requirement.trigger == 'level-up'
        ? evolutionLevelUp
        : evolutionSpecial;
  }
}
