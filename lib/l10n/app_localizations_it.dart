// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'PokéFlutter';

  @override
  String get navHome => 'Home';

  @override
  String get navCompare => 'Confronta';

  @override
  String get navQuiz => 'Quiz';

  @override
  String get navFavourites => 'Preferiti';

  @override
  String get retry => 'Riprova';

  @override
  String get settings => 'Impostazioni';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Chiaro';

  @override
  String get themeDark => 'Scuro';

  @override
  String get settingsLanguage => 'Lingua';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get homeTitle => 'Pokédex';

  @override
  String get homeSubtitle =>
      'Cerca per nome o filtra per tipo per trovare qualsiasi Pokémon.';

  @override
  String get typesLoadFailed =>
      'Impossibile caricare i dati dei tipi. Controlla la connessione.';

  @override
  String get noPokemonFound => 'Nessun Pokémon trovato.';

  @override
  String get typesUnavailableOffline => 'Tipi non disponibili offline.';

  @override
  String removeFilter(String type) {
    return 'Rimuovi il filtro $type';
  }

  @override
  String get clearAll => 'Rimuovi tutti';

  @override
  String get random => 'Casuale';

  @override
  String get searchHint => 'Cerca un Pokémon';

  @override
  String get clearSearch => 'Cancella la ricerca';

  @override
  String get filterByType => 'Filtra per tipo';

  @override
  String filterByTypeSelected(int count) {
    return 'Filtra per tipo, $count selezionati';
  }

  @override
  String get filterSheetTitle => 'Filtra per tipo';

  @override
  String get showAll => 'Mostra tutti';

  @override
  String applyCount(int count) {
    return 'Applica ($count)';
  }

  @override
  String pokemonSemantics(String name, int id) {
    return '$name, numero $id';
  }

  @override
  String pokemonSemanticsTyped(String name, int id, String types) {
    return '$name, numero $id, tipo $types';
  }

  @override
  String typesAnd(String first, String second) {
    return '$first e $second';
  }

  @override
  String get favouritesTitle => 'Preferiti';

  @override
  String get favouritesSubtitle => 'I Pokémon salvati per un accesso rapido.';

  @override
  String get favouritesEmptyTitle => 'Ancora nessun preferito';

  @override
  String get favouritesEmptyHint =>
      'Tocca il ♥ su un Pokémon per salvarlo qui.';

  @override
  String get typeNormal => 'Normale';

  @override
  String get typeFire => 'Fuoco';

  @override
  String get typeWater => 'Acqua';

  @override
  String get typeElectric => 'Elettro';

  @override
  String get typeGrass => 'Erba';

  @override
  String get typeIce => 'Ghiaccio';

  @override
  String get typeFighting => 'Lotta';

  @override
  String get typePoison => 'Veleno';

  @override
  String get typeGround => 'Terra';

  @override
  String get typeFlying => 'Volante';

  @override
  String get typePsychic => 'Psico';

  @override
  String get typeBug => 'Coleottero';

  @override
  String get typeRock => 'Roccia';

  @override
  String get typeGhost => 'Spettro';

  @override
  String get typeDragon => 'Drago';

  @override
  String get typeDark => 'Buio';

  @override
  String get typeSteel => 'Acciaio';

  @override
  String get typeFairy => 'Folletto';
}
