import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../data/pokemon_names.dart';
import 'app_localizations.dart';

export 'app_localizations.dart';
export 'pokemon_labels.dart';

extension AppLocalizationsContext on BuildContext {
  /// The translated strings of the current locale.
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// How the Pokémon with API id [name] is called in the current language
  /// ("mr-mime" → "Mr. Mime").
  String pokemonName(String name) => read<PokemonNames>().display(
    name,
    Localizations.localeOf(this).languageCode,
  );
}

extension PokemonTypeNames on AppLocalizations {
  /// Display name of a PokéAPI type id (`"fire"` → "Fire" / "Fuoco").
  /// Unknown ids come back capitalised.
  String typeName(String type) => switch (type.toLowerCase()) {
    'normal' => typeNormal,
    'fire' => typeFire,
    'water' => typeWater,
    'electric' => typeElectric,
    'grass' => typeGrass,
    'ice' => typeIce,
    'fighting' => typeFighting,
    'poison' => typePoison,
    'ground' => typeGround,
    'flying' => typeFlying,
    'psychic' => typePsychic,
    'bug' => typeBug,
    'rock' => typeRock,
    'ghost' => typeGhost,
    'dragon' => typeDragon,
    'dark' => typeDark,
    'steel' => typeSteel,
    'fairy' => typeFairy,
    _ =>
      type.isEmpty
          ? type
          : '${type[0].toUpperCase()}${type.substring(1).toLowerCase()}',
  };

  /// "Fire", "Fire and Flying"… for screen readers.
  String typeList(List<String> types) {
    final names = types.map(typeName).toList();
    return names.length == 2 ? typesAnd(names[0], names[1]) : names.join(', ');
  }
}
