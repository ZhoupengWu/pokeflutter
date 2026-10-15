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

  @override
  String get quizTitle => 'Quiz';

  @override
  String get quizIntro =>
      'Metti alla prova la tua conoscenza dei Pokémon! Indovina il nome dalla silhouette o il tipo dal nome.';

  @override
  String get quizDifficulty => 'Difficoltà';

  @override
  String get difficultyEasy => 'Facile';

  @override
  String get difficultyNormal => 'Normale';

  @override
  String get difficultyHard => 'Difficile';

  @override
  String get difficultyEasyHint =>
      'Solo la prima generazione (151 Pokémon), senza timer.';

  @override
  String difficultyTimedHint(int seconds) {
    return 'Tutti i Pokémon, $seconds secondi per domanda.';
  }

  @override
  String quizBestScore(int score) {
    return 'Record: $score';
  }

  @override
  String get quizNoBestScore => 'Ancora nessun punteggio';

  @override
  String get quizStart => 'Inizia il quiz';

  @override
  String get quizLoading => 'Caricamento…';

  @override
  String quizQuestionCounter(int current, int total) {
    return 'Domanda $current / $total';
  }

  @override
  String quizPoints(int score) {
    return '$score pt';
  }

  @override
  String quizStreak(int count) {
    return 'Serie $count';
  }

  @override
  String get quizWhoIsThis => 'Chi è questo Pokémon?';

  @override
  String quizWhatType(String name) {
    return 'Di che tipo è $name?';
  }

  @override
  String get quizSilhouette => 'Silhouette di un Pokémon';

  @override
  String get quizLoadFailed => 'Impossibile caricare questo Pokémon.';

  @override
  String quizTimeLeft(int seconds) {
    return '$seconds secondi rimasti';
  }

  @override
  String get quizTimeUp => 'Tempo scaduto!';

  @override
  String quizCorrect(int points) {
    return 'Corretto! +$points';
  }

  @override
  String get quizWrong => 'Sbagliato';

  @override
  String quizAnswerName(String name) {
    return 'È $name!';
  }

  @override
  String quizAnswerTypes(String name, String types) {
    return '$name è di tipo $types';
  }

  @override
  String get quizNext => 'Prossima domanda';

  @override
  String get quizSeeResults => 'Vedi i risultati';

  @override
  String get quizResults => 'Risultati';

  @override
  String get quizVerdictMaster => 'Maestro Pokémon! 🏆';

  @override
  String get quizVerdictOk => 'Non male, continua ad allenarti!';

  @override
  String get quizVerdictLow => 'Continua a studiare il Pokédex!';

  @override
  String get quizCorrectLabel => 'Corrette';

  @override
  String get quizWrongLabel => 'Sbagliate';

  @override
  String get quizScoreLabel => 'Punti';

  @override
  String get quizBestStreakLabel => 'Serie migliore';

  @override
  String get quizNewRecord => 'Nuovo record! 🎉';

  @override
  String get quizPlayAgain => 'Gioca ancora';

  @override
  String get quizChangeDifficulty => 'Cambia difficoltà';

  @override
  String quizOptionCorrect(String answer) {
    return '$answer, risposta corretta';
  }

  @override
  String quizOptionWrong(String answer) {
    return '$answer, risposta sbagliata';
  }

  @override
  String get back => 'Indietro';

  @override
  String get addToFavourites => 'Aggiungi ai preferiti';

  @override
  String get removeFromFavourites => 'Rimuovi dai preferiti';

  @override
  String get detailLoadFailed => 'Impossibile caricare il Pokémon';

  @override
  String get detailAbout => 'Informazioni';

  @override
  String get detailWeight => 'Peso';

  @override
  String get detailHeight => 'Altezza';

  @override
  String weightValue(String value) {
    return '$value kg';
  }

  @override
  String heightValue(String value) {
    return '$value cm';
  }

  @override
  String get detailAbilities => 'Abilità';

  @override
  String get detailBaseStats => 'Statistiche base';

  @override
  String get statHp => 'PS';

  @override
  String get statAttack => 'ATT';

  @override
  String get statDefense => 'DIF';

  @override
  String get statSpecialAttack => 'AtS';

  @override
  String get statSpecialDefense => 'DfS';

  @override
  String get statSpeed => 'VEL';

  @override
  String get matchupsTitle => 'Efficacia dei tipi';

  @override
  String get matchupsHint => 'Danni subiti da ogni tipo di mossa.';

  @override
  String get matchupsWeak => 'Debole a';

  @override
  String get matchupsResists => 'Resiste a';

  @override
  String get matchupsImmune => 'Immune a';

  @override
  String matchupSemantics(String type, String damage) {
    return '$type: danni $damage';
  }

  @override
  String get evolutionTitle => 'Evoluzione';

  @override
  String get evolutionNone => 'Questo Pokémon non si evolve.';

  @override
  String get evolutionLoadFailed => 'Impossibile caricare le evoluzioni.';

  @override
  String evolutionLevel(int level) {
    return 'Liv. $level';
  }

  @override
  String get evolutionLevelUp => 'Salita di livello';

  @override
  String get evolutionTrade => 'Scambio';

  @override
  String get evolutionFriendship => 'Amicizia';

  @override
  String get evolutionDay => 'Giorno';

  @override
  String get evolutionNight => 'Notte';

  @override
  String evolutionHolding(String item) {
    return 'Tenendo $item';
  }

  @override
  String evolutionKnowing(String move) {
    return 'Conoscendo $move';
  }

  @override
  String get evolutionSpecial => 'Speciale';

  @override
  String evolutionStageSemantics(String name, int id) {
    return '$name, numero $id';
  }

  @override
  String evolutionStageSemanticsWith(String name, int id, String requirement) {
    return '$name, numero $id, $requirement';
  }

  @override
  String get evolutionCurrent => 'attuale';

  @override
  String get compareTitle => 'Confronta';

  @override
  String get compareSubtitle =>
      'Scegli due Pokémon per confrontare le loro statistiche.';

  @override
  String get compareSlotA => 'Pokémon A';

  @override
  String get compareSlotB => 'Pokémon B';

  @override
  String get compareVersus => 'VS';

  @override
  String get compareEmpty => 'Scegli due Pokémon per iniziare il confronto';

  @override
  String get compareSelectSecond => 'Scegli il secondo Pokémon da confrontare';

  @override
  String get compareFailed =>
      'Impossibile caricare un Pokémon. Tocca la sua scheda per riprovare.';

  @override
  String get compareTapToRetry => 'Tocca per riprovare';

  @override
  String compareSlotFailedSemantics(String slot) {
    return '$slot: caricamento non riuscito, tocca per riprovare';
  }

  @override
  String compareSlotLoadedSemantics(String slot, String name) {
    return '$slot: $name, tocca per cambiare';
  }

  @override
  String compareSlotSelectSemantics(String slot) {
    return 'Scegli $slot';
  }

  @override
  String get comparePickerHint => 'Cerca un Pokémon...';

  @override
  String get compareTotal => 'Totale';

  @override
  String compareStatSemantics(String stat, int first, int second) {
    return '$stat: $first contro $second';
  }

  @override
  String get offlineBanner =>
      'Sei offline. I Pokémon già aperti restano disponibili.';
}
