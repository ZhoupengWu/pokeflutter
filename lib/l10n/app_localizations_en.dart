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
  String get filterByType => 'Filters';

  @override
  String filterByTypeSelected(int count) {
    return 'Filters, $count selected';
  }

  @override
  String get filterSheetTitle => 'Filter and sort';

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

  @override
  String get quizTitle => 'Quiz';

  @override
  String get quizIntro =>
      'Test your Pokémon knowledge! Guess the name from the silhouette or the type from the name.';

  @override
  String get quizDifficulty => 'Difficulty';

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyNormal => 'Normal';

  @override
  String get difficultyHard => 'Hard';

  @override
  String get difficultyEasyHint =>
      'First generation only (151 Pokémon), no timer.';

  @override
  String difficultyTimedHint(int seconds) {
    return 'All Pokémon, $seconds seconds per question.';
  }

  @override
  String quizBestScore(int score) {
    return 'Best score: $score';
  }

  @override
  String get quizNoBestScore => 'No score yet';

  @override
  String get quizStart => 'Start Quiz';

  @override
  String get quizLoading => 'Loading…';

  @override
  String quizQuestionCounter(int current, int total) {
    return 'Question $current / $total';
  }

  @override
  String quizPoints(int score) {
    return '$score pts';
  }

  @override
  String quizStreak(int count) {
    return 'Streak $count';
  }

  @override
  String get quizWhoIsThis => 'Who is this Pokémon?';

  @override
  String quizWhatType(String name) {
    return 'What type is $name?';
  }

  @override
  String get quizSilhouette => 'Silhouette of a Pokémon';

  @override
  String get quizLoadFailed => 'Couldn\'t load this Pokémon.';

  @override
  String quizTimeLeft(int seconds) {
    return '$seconds seconds left';
  }

  @override
  String get quizTimeUp => 'Time\'s up!';

  @override
  String quizCorrect(int points) {
    return 'Correct! +$points';
  }

  @override
  String get quizWrong => 'Wrong';

  @override
  String quizAnswerName(String name) {
    return 'It\'s $name!';
  }

  @override
  String quizAnswerTypes(String name, String types) {
    return '$name is $types type';
  }

  @override
  String get quizNext => 'Next Question';

  @override
  String get quizSeeResults => 'See Results';

  @override
  String get quizResults => 'Results';

  @override
  String get quizVerdictMaster => 'Pokémon Master! 🏆';

  @override
  String get quizVerdictOk => 'Not bad, keep training!';

  @override
  String get quizVerdictLow => 'Keep studying the Pokédex!';

  @override
  String get quizCorrectLabel => 'Correct';

  @override
  String get quizWrongLabel => 'Wrong';

  @override
  String get quizScoreLabel => 'Score';

  @override
  String get quizBestStreakLabel => 'Best streak';

  @override
  String get quizNewRecord => 'New record! 🎉';

  @override
  String get quizPlayAgain => 'Play Again';

  @override
  String get quizChangeDifficulty => 'Change difficulty';

  @override
  String quizOptionCorrect(String answer) {
    return '$answer, correct answer';
  }

  @override
  String quizOptionWrong(String answer) {
    return '$answer, wrong answer';
  }

  @override
  String get back => 'Back';

  @override
  String get addToFavourites => 'Add to favourites';

  @override
  String get removeFromFavourites => 'Remove from favourites';

  @override
  String get detailLoadFailed => 'Failed to load Pokémon';

  @override
  String get detailAbout => 'About';

  @override
  String get detailWeight => 'Weight';

  @override
  String get detailHeight => 'Height';

  @override
  String weightValue(String value) {
    return '$value kg';
  }

  @override
  String heightValue(String value) {
    return '$value cm';
  }

  @override
  String get detailAbilities => 'Abilities';

  @override
  String get detailBaseStats => 'Base Stats';

  @override
  String get statHp => 'HP';

  @override
  String get statAttack => 'ATK';

  @override
  String get statDefense => 'DEF';

  @override
  String get statSpecialAttack => 'SpA';

  @override
  String get statSpecialDefense => 'SpD';

  @override
  String get statSpeed => 'SPD';

  @override
  String get matchupsTitle => 'Type matchups';

  @override
  String get matchupsHint => 'Damage taken from each type of move.';

  @override
  String get matchupsWeak => 'Weak to';

  @override
  String get matchupsResists => 'Resists';

  @override
  String get matchupsImmune => 'Immune to';

  @override
  String matchupSemantics(String type, String damage) {
    return '$type: $damage damage';
  }

  @override
  String get evolutionTitle => 'Evolution';

  @override
  String get evolutionNone => 'This Pokémon doesn\'t evolve.';

  @override
  String get evolutionLoadFailed => 'Couldn\'t load the evolutions.';

  @override
  String evolutionLevel(int level) {
    return 'Lv. $level';
  }

  @override
  String get evolutionLevelUp => 'Level up';

  @override
  String get evolutionTrade => 'Trade';

  @override
  String get evolutionFriendship => 'Friendship';

  @override
  String get evolutionDay => 'Day';

  @override
  String get evolutionNight => 'Night';

  @override
  String evolutionHolding(String item) {
    return 'Holding $item';
  }

  @override
  String evolutionKnowing(String move) {
    return 'Knowing $move';
  }

  @override
  String get evolutionSpecial => 'Special';

  @override
  String evolutionStageSemantics(String name, int id) {
    return '$name, number $id';
  }

  @override
  String evolutionStageSemanticsWith(String name, int id, String requirement) {
    return '$name, number $id, $requirement';
  }

  @override
  String get evolutionCurrent => 'current';

  @override
  String get compareTitle => 'Compare';

  @override
  String get compareSubtitle => 'Select two Pokémon to compare their stats.';

  @override
  String get compareSlotA => 'Pokémon A';

  @override
  String get compareSlotB => 'Pokémon B';

  @override
  String get compareVersus => 'VS';

  @override
  String get compareEmpty => 'Select two Pokémon to start comparing';

  @override
  String get compareSelectSecond => 'Select the second Pokémon to compare';

  @override
  String get compareFailed =>
      'Couldn\'t load a Pokémon. Tap its card to retry.';

  @override
  String get compareTapToRetry => 'Tap to retry';

  @override
  String compareSlotFailedSemantics(String slot) {
    return '$slot: failed to load, tap to retry';
  }

  @override
  String compareSlotLoadedSemantics(String slot, String name) {
    return '$slot: $name, tap to change';
  }

  @override
  String compareSlotSelectSemantics(String slot) {
    return 'Select $slot';
  }

  @override
  String get comparePickerHint => 'Search Pokémon...';

  @override
  String get compareTotal => 'Total';

  @override
  String compareStatSemantics(String stat, int first, int second) {
    return '$stat: $first against $second';
  }

  @override
  String get offlineBanner =>
      'You\'re offline. Pokémon you\'ve already opened are still available.';

  @override
  String get filterTypeSection => 'Type';

  @override
  String get filterGenerationSection => 'Generation';

  @override
  String get filterGenerationHint =>
      'Alternate forms are hidden when a generation is selected.';

  @override
  String get filterSortSection => 'Sort by';

  @override
  String generationName(String roman) {
    return 'Gen $roman';
  }

  @override
  String get sortNumberAsc => 'Number (low to high)';

  @override
  String get sortNumberDesc => 'Number (high to low)';

  @override
  String get sortNameAsc => 'Name (A–Z)';

  @override
  String get sortNameDesc => 'Name (Z–A)';

  @override
  String get settingsStorage => 'Offline data';

  @override
  String storageUsed(String size) {
    return '$size of Pokémon data and images saved on this device';
  }

  @override
  String get storageEmpty => 'Nothing saved on this device';

  @override
  String get storageClear => 'Clear';

  @override
  String get storageClearSemantics => 'Clear offline data';
}
