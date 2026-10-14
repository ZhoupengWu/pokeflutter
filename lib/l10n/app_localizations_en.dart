// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'PokéFlutter';

  @override
  String get navHome => 'Home';

  @override
  String get navCompare => 'Compare';

  @override
  String get navQuiz => 'Quiz';

  @override
  String get navFavourites => 'Favourites';

  @override
  String get retry => 'Retry';

  @override
  String get settings => 'Settings';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get homeTitle => 'Pokédex';

  @override
  String get homeSubtitle =>
      'Search by name or filter by type to find any Pokémon.';

  @override
  String get typesLoadFailed =>
      'Couldn\'t load the type data. Check your connection.';

  @override
  String get noPokemonFound => 'No Pokémon found.';

  @override
  String get typesUnavailableOffline => 'Types unavailable offline.';

  @override
  String removeFilter(String type) {
    return 'Remove $type filter';
  }

  @override
  String get clearAll => 'Clear all';

  @override
  String get random => 'Random';

  @override
  String get searchHint => 'Search a Pokémon';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get filterByType => 'Filter by type';

  @override
  String filterByTypeSelected(int count) {
    return 'Filter by type, $count selected';
  }

  @override
  String get filterSheetTitle => 'Filter by Type';

  @override
  String get showAll => 'Show all';

  @override
  String applyCount(int count) {
    return 'Apply ($count)';
  }

  @override
  String pokemonSemantics(String name, int id) {
    return '$name, number $id';
  }

  @override
  String pokemonSemanticsTyped(String name, int id, String types) {
    return '$name, number $id, $types type';
  }

  @override
  String typesAnd(String first, String second) {
    return '$first and $second';
  }

  @override
  String get favouritesTitle => 'Favourites';

  @override
  String get favouritesSubtitle => 'Pokémon you\'ve saved for quick access.';

  @override
  String get favouritesEmptyTitle => 'No favourites yet';

  @override
  String get favouritesEmptyHint => 'Tap the ♥ on any Pokémon to save it here.';

  @override
  String get typeNormal => 'Normal';

  @override
  String get typeFire => 'Fire';

  @override
  String get typeWater => 'Water';

  @override
  String get typeElectric => 'Electric';

  @override
  String get typeGrass => 'Grass';

  @override
  String get typeIce => 'Ice';

  @override
  String get typeFighting => 'Fighting';

  @override
  String get typePoison => 'Poison';

  @override
  String get typeGround => 'Ground';

  @override
  String get typeFlying => 'Flying';

  @override
  String get typePsychic => 'Psychic';

  @override
  String get typeBug => 'Bug';

  @override
  String get typeRock => 'Rock';

  @override
  String get typeGhost => 'Ghost';

  @override
  String get typeDragon => 'Dragon';

  @override
  String get typeDark => 'Dark';

  @override
  String get typeSteel => 'Steel';

  @override
  String get typeFairy => 'Fairy';
}
