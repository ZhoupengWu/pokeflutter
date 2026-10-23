import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'PokéFlutter'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navCompare.
  ///
  /// In en, this message translates to:
  /// **'Compare'**
  String get navCompare;

  /// No description provided for @navQuiz.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get navQuiz;

  /// No description provided for @navFavourites.
  ///
  /// In en, this message translates to:
  /// **'Favourites'**
  String get navFavourites;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Pokédex'**
  String get homeTitle;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Search by name or filter by type to find any Pokémon.'**
  String get homeSubtitle;

  /// No description provided for @typesLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the type data. Check your connection.'**
  String get typesLoadFailed;

  /// No description provided for @noPokemonFound.
  ///
  /// In en, this message translates to:
  /// **'No Pokémon found.'**
  String get noPokemonFound;

  /// No description provided for @typesUnavailableOffline.
  ///
  /// In en, this message translates to:
  /// **'Types unavailable offline.'**
  String get typesUnavailableOffline;

  /// No description provided for @removeFilter.
  ///
  /// In en, this message translates to:
  /// **'Remove {type} filter'**
  String removeFilter(String type);

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @random.
  ///
  /// In en, this message translates to:
  /// **'Random'**
  String get random;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search a Pokémon'**
  String get searchHint;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @filterByType.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filterByType;

  /// No description provided for @filterByTypeSelected.
  ///
  /// In en, this message translates to:
  /// **'Filters, {count} selected'**
  String filterByTypeSelected(int count);

  /// No description provided for @filterSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter and sort'**
  String get filterSheetTitle;

  /// No description provided for @showAll.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get showAll;

  /// No description provided for @applyCount.
  ///
  /// In en, this message translates to:
  /// **'Apply ({count})'**
  String applyCount(int count);

  /// No description provided for @pokemonSemantics.
  ///
  /// In en, this message translates to:
  /// **'{name}, number {id}'**
  String pokemonSemantics(String name, int id);

  /// No description provided for @pokemonSemanticsTyped.
  ///
  /// In en, this message translates to:
  /// **'{name}, number {id}, {types} type'**
  String pokemonSemanticsTyped(String name, int id, String types);

  /// No description provided for @typesAnd.
  ///
  /// In en, this message translates to:
  /// **'{first} and {second}'**
  String typesAnd(String first, String second);

  /// No description provided for @favouritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Favourites'**
  String get favouritesTitle;

  /// No description provided for @favouritesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pokémon you\'ve saved for quick access.'**
  String get favouritesSubtitle;

  /// No description provided for @favouritesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No favourites yet'**
  String get favouritesEmptyTitle;

  /// No description provided for @favouritesEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the ♥ on any Pokémon to save it here.'**
  String get favouritesEmptyHint;

  /// No description provided for @typeNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get typeNormal;

  /// No description provided for @typeFire.
  ///
  /// In en, this message translates to:
  /// **'Fire'**
  String get typeFire;

  /// No description provided for @typeWater.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get typeWater;

  /// No description provided for @typeElectric.
  ///
  /// In en, this message translates to:
  /// **'Electric'**
  String get typeElectric;

  /// No description provided for @typeGrass.
  ///
  /// In en, this message translates to:
  /// **'Grass'**
  String get typeGrass;

  /// No description provided for @typeIce.
  ///
  /// In en, this message translates to:
  /// **'Ice'**
  String get typeIce;

  /// No description provided for @typeFighting.
  ///
  /// In en, this message translates to:
  /// **'Fighting'**
  String get typeFighting;

  /// No description provided for @typePoison.
  ///
  /// In en, this message translates to:
  /// **'Poison'**
  String get typePoison;

  /// No description provided for @typeGround.
  ///
  /// In en, this message translates to:
  /// **'Ground'**
  String get typeGround;

  /// No description provided for @typeFlying.
  ///
  /// In en, this message translates to:
  /// **'Flying'**
  String get typeFlying;

  /// No description provided for @typePsychic.
  ///
  /// In en, this message translates to:
  /// **'Psychic'**
  String get typePsychic;

  /// No description provided for @typeBug.
  ///
  /// In en, this message translates to:
  /// **'Bug'**
  String get typeBug;

  /// No description provided for @typeRock.
  ///
  /// In en, this message translates to:
  /// **'Rock'**
  String get typeRock;

  /// No description provided for @typeGhost.
  ///
  /// In en, this message translates to:
  /// **'Ghost'**
  String get typeGhost;

  /// No description provided for @typeDragon.
  ///
  /// In en, this message translates to:
  /// **'Dragon'**
  String get typeDragon;

  /// No description provided for @typeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get typeDark;

  /// No description provided for @typeSteel.
  ///
  /// In en, this message translates to:
  /// **'Steel'**
  String get typeSteel;

  /// No description provided for @typeFairy.
  ///
  /// In en, this message translates to:
  /// **'Fairy'**
  String get typeFairy;

  /// No description provided for @quizTitle.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get quizTitle;

  /// No description provided for @quizIntro.
  ///
  /// In en, this message translates to:
  /// **'Test your Pokémon knowledge! Guess who is behind the silhouette, name the types, compare stats and spot weaknesses.'**
  String get quizIntro;

  /// No description provided for @quizDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get quizDifficulty;

  /// No description provided for @difficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get difficultyEasy;

  /// No description provided for @difficultyNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get difficultyNormal;

  /// No description provided for @difficultyHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get difficultyHard;

  /// No description provided for @difficultyEasyHint.
  ///
  /// In en, this message translates to:
  /// **'First generation only (151 Pokémon), no timer.'**
  String get difficultyEasyHint;

  /// No description provided for @difficultyTimedHint.
  ///
  /// In en, this message translates to:
  /// **'All Pokémon, {seconds} seconds per question.'**
  String difficultyTimedHint(int seconds);

  /// No description provided for @quizBestScore.
  ///
  /// In en, this message translates to:
  /// **'Best score: {score}'**
  String quizBestScore(int score);

  /// No description provided for @quizNoBestScore.
  ///
  /// In en, this message translates to:
  /// **'No score yet'**
  String get quizNoBestScore;

  /// No description provided for @quizStart.
  ///
  /// In en, this message translates to:
  /// **'Start Quiz'**
  String get quizStart;

  /// No description provided for @quizLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get quizLoading;

  /// No description provided for @quizQuestionCounter.
  ///
  /// In en, this message translates to:
  /// **'Question {current} / {total}'**
  String quizQuestionCounter(int current, int total);

  /// No description provided for @quizPoints.
  ///
  /// In en, this message translates to:
  /// **'{score} pts'**
  String quizPoints(int score);

  /// No description provided for @quizStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak {count}'**
  String quizStreak(int count);

  /// No description provided for @quizWhoIsThis.
  ///
  /// In en, this message translates to:
  /// **'Who is this Pokémon?'**
  String get quizWhoIsThis;

  /// No description provided for @quizWhatType.
  ///
  /// In en, this message translates to:
  /// **'What type is {name}?'**
  String quizWhatType(String name);

  /// No description provided for @quizWhatTypes.
  ///
  /// In en, this message translates to:
  /// **'What types does {name} have?'**
  String quizWhatTypes(String name);

  /// No description provided for @quizHigherStat.
  ///
  /// In en, this message translates to:
  /// **'Which one has the higher {stat}?'**
  String quizHigherStat(String stat);

  /// No description provided for @quizSuperEffective.
  ///
  /// In en, this message translates to:
  /// **'Which type is super effective against {name}?'**
  String quizSuperEffective(String name);

  /// No description provided for @quizStatHp.
  ///
  /// In en, this message translates to:
  /// **'HP'**
  String get quizStatHp;

  /// No description provided for @quizStatAttack.
  ///
  /// In en, this message translates to:
  /// **'Attack'**
  String get quizStatAttack;

  /// No description provided for @quizStatDefense.
  ///
  /// In en, this message translates to:
  /// **'Defense'**
  String get quizStatDefense;

  /// No description provided for @quizStatSpecialAttack.
  ///
  /// In en, this message translates to:
  /// **'Sp. Attack'**
  String get quizStatSpecialAttack;

  /// No description provided for @quizStatSpecialDefense.
  ///
  /// In en, this message translates to:
  /// **'Sp. Defense'**
  String get quizStatSpecialDefense;

  /// No description provided for @quizStatSpeed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get quizStatSpeed;

  /// No description provided for @quizAnswerStat.
  ///
  /// In en, this message translates to:
  /// **'{stat}: {first} {firstValue} vs {second} {secondValue}'**
  String quizAnswerStat(
    String stat,
    String first,
    int firstValue,
    String second,
    int secondValue,
  );

  /// No description provided for @quizAnswerWeakness.
  ///
  /// In en, this message translates to:
  /// **'{name} takes extra damage from {types}'**
  String quizAnswerWeakness(String name, String types);

  /// No description provided for @quizDailyTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily challenge'**
  String get quizDailyTitle;

  /// No description provided for @quizDailyHint.
  ///
  /// In en, this message translates to:
  /// **'The same questions for everyone today. One try a day.'**
  String get quizDailyHint;

  /// No description provided for @quizDailyPlay.
  ///
  /// In en, this message translates to:
  /// **'Play today\'s challenge'**
  String get quizDailyPlay;

  /// No description provided for @quizDailyDone.
  ///
  /// In en, this message translates to:
  /// **'Today: {correct} / {total} · {score} pts'**
  String quizDailyDone(int correct, int total, int score);

  /// No description provided for @quizDailyStreak.
  ///
  /// In en, this message translates to:
  /// **'{count}-day streak'**
  String quizDailyStreak(int count);

  /// No description provided for @quizShare.
  ///
  /// In en, this message translates to:
  /// **'Share result'**
  String get quizShare;

  /// No description provided for @quizShareGame.
  ///
  /// In en, this message translates to:
  /// **'PokéFlutter Quiz ({difficulty})\n{correct}/{total} · {score} pts\n{grid}'**
  String quizShareGame(
    String difficulty,
    int correct,
    int total,
    int score,
    String grid,
  );

  /// No description provided for @quizShareDaily.
  ///
  /// In en, this message translates to:
  /// **'PokéFlutter Daily {date}\n{correct}/{total} · {score} pts\n{grid}'**
  String quizShareDaily(
    String date,
    int correct,
    int total,
    int score,
    String grid,
  );

  /// No description provided for @quizSilhouette.
  ///
  /// In en, this message translates to:
  /// **'Silhouette of a Pokémon'**
  String get quizSilhouette;

  /// No description provided for @quizLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this Pokémon.'**
  String get quizLoadFailed;

  /// No description provided for @quizTimeLeft.
  ///
  /// In en, this message translates to:
  /// **'{seconds} seconds left'**
  String quizTimeLeft(int seconds);

  /// No description provided for @quizTimeUp.
  ///
  /// In en, this message translates to:
  /// **'Time\'s up!'**
  String get quizTimeUp;

  /// No description provided for @quizCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct! +{points}'**
  String quizCorrect(int points);

  /// No description provided for @quizWrong.
  ///
  /// In en, this message translates to:
  /// **'Wrong'**
  String get quizWrong;

  /// No description provided for @quizAnswerName.
  ///
  /// In en, this message translates to:
  /// **'It\'s {name}!'**
  String quizAnswerName(String name);

  /// No description provided for @quizAnswerTypes.
  ///
  /// In en, this message translates to:
  /// **'{name} is {types} type'**
  String quizAnswerTypes(String name, String types);

  /// No description provided for @quizNext.
  ///
  /// In en, this message translates to:
  /// **'Next Question'**
  String get quizNext;

  /// No description provided for @quizSeeResults.
  ///
  /// In en, this message translates to:
  /// **'See Results'**
  String get quizSeeResults;

  /// No description provided for @quizResults.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get quizResults;

  /// No description provided for @quizVerdictMaster.
  ///
  /// In en, this message translates to:
  /// **'Pokémon Master! 🏆'**
  String get quizVerdictMaster;

  /// No description provided for @quizVerdictOk.
  ///
  /// In en, this message translates to:
  /// **'Not bad, keep training!'**
  String get quizVerdictOk;

  /// No description provided for @quizVerdictLow.
  ///
  /// In en, this message translates to:
  /// **'Keep studying the Pokédex!'**
  String get quizVerdictLow;

  /// No description provided for @quizCorrectLabel.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get quizCorrectLabel;

  /// No description provided for @quizWrongLabel.
  ///
  /// In en, this message translates to:
  /// **'Wrong'**
  String get quizWrongLabel;

  /// No description provided for @quizScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get quizScoreLabel;

  /// No description provided for @quizBestStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Best streak'**
  String get quizBestStreakLabel;

  /// No description provided for @quizNewRecord.
  ///
  /// In en, this message translates to:
  /// **'New record! 🎉'**
  String get quizNewRecord;

  /// No description provided for @quizPlayAgain.
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get quizPlayAgain;

  /// No description provided for @quizChangeDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Change difficulty'**
  String get quizChangeDifficulty;

  /// No description provided for @quizOptionCorrect.
  ///
  /// In en, this message translates to:
  /// **'{answer}, correct answer'**
  String quizOptionCorrect(String answer);

  /// No description provided for @quizOptionWrong.
  ///
  /// In en, this message translates to:
  /// **'{answer}, wrong answer'**
  String quizOptionWrong(String answer);

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @addToFavourites.
  ///
  /// In en, this message translates to:
  /// **'Add to favourites'**
  String get addToFavourites;

  /// No description provided for @removeFromFavourites.
  ///
  /// In en, this message translates to:
  /// **'Remove from favourites'**
  String get removeFromFavourites;

  /// No description provided for @detailLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load Pokémon'**
  String get detailLoadFailed;

  /// No description provided for @detailAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get detailAbout;

  /// No description provided for @detailWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get detailWeight;

  /// No description provided for @detailHeight.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get detailHeight;

  /// No description provided for @weightValue.
  ///
  /// In en, this message translates to:
  /// **'{value} kg'**
  String weightValue(String value);

  /// No description provided for @heightValue.
  ///
  /// In en, this message translates to:
  /// **'{value} cm'**
  String heightValue(String value);

  /// No description provided for @detailAbilities.
  ///
  /// In en, this message translates to:
  /// **'Abilities'**
  String get detailAbilities;

  /// No description provided for @detailBaseStats.
  ///
  /// In en, this message translates to:
  /// **'Base Stats'**
  String get detailBaseStats;

  /// No description provided for @statHp.
  ///
  /// In en, this message translates to:
  /// **'HP'**
  String get statHp;

  /// No description provided for @statAttack.
  ///
  /// In en, this message translates to:
  /// **'ATK'**
  String get statAttack;

  /// No description provided for @statDefense.
  ///
  /// In en, this message translates to:
  /// **'DEF'**
  String get statDefense;

  /// No description provided for @statSpecialAttack.
  ///
  /// In en, this message translates to:
  /// **'SpA'**
  String get statSpecialAttack;

  /// No description provided for @statSpecialDefense.
  ///
  /// In en, this message translates to:
  /// **'SpD'**
  String get statSpecialDefense;

  /// No description provided for @statSpeed.
  ///
  /// In en, this message translates to:
  /// **'SPD'**
  String get statSpeed;

  /// No description provided for @matchupsTitle.
  ///
  /// In en, this message translates to:
  /// **'Type matchups'**
  String get matchupsTitle;

  /// No description provided for @matchupsHint.
  ///
  /// In en, this message translates to:
  /// **'Damage taken from each type of move.'**
  String get matchupsHint;

  /// No description provided for @matchupsWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak to'**
  String get matchupsWeak;

  /// No description provided for @matchupsResists.
  ///
  /// In en, this message translates to:
  /// **'Resists'**
  String get matchupsResists;

  /// No description provided for @matchupsImmune.
  ///
  /// In en, this message translates to:
  /// **'Immune to'**
  String get matchupsImmune;

  /// No description provided for @matchupSemantics.
  ///
  /// In en, this message translates to:
  /// **'{type}: {damage} damage'**
  String matchupSemantics(String type, String damage);

  /// No description provided for @evolutionTitle.
  ///
  /// In en, this message translates to:
  /// **'Evolution'**
  String get evolutionTitle;

  /// No description provided for @evolutionNone.
  ///
  /// In en, this message translates to:
  /// **'This Pokémon doesn\'t evolve.'**
  String get evolutionNone;

  /// No description provided for @evolutionLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the evolutions.'**
  String get evolutionLoadFailed;

  /// No description provided for @evolutionLevel.
  ///
  /// In en, this message translates to:
  /// **'Lv. {level}'**
  String evolutionLevel(int level);

  /// No description provided for @evolutionLevelUp.
  ///
  /// In en, this message translates to:
  /// **'Level up'**
  String get evolutionLevelUp;

  /// No description provided for @evolutionTrade.
  ///
  /// In en, this message translates to:
  /// **'Trade'**
  String get evolutionTrade;

  /// No description provided for @evolutionFriendship.
  ///
  /// In en, this message translates to:
  /// **'Friendship'**
  String get evolutionFriendship;

  /// No description provided for @evolutionDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get evolutionDay;

  /// No description provided for @evolutionNight.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get evolutionNight;

  /// No description provided for @evolutionHolding.
  ///
  /// In en, this message translates to:
  /// **'Holding {item}'**
  String evolutionHolding(String item);

  /// No description provided for @evolutionKnowing.
  ///
  /// In en, this message translates to:
  /// **'Knowing {move}'**
  String evolutionKnowing(String move);

  /// No description provided for @evolutionSpecial.
  ///
  /// In en, this message translates to:
  /// **'Special'**
  String get evolutionSpecial;

  /// No description provided for @evolutionStageSemantics.
  ///
  /// In en, this message translates to:
  /// **'{name}, number {id}'**
  String evolutionStageSemantics(String name, int id);

  /// No description provided for @evolutionStageSemanticsWith.
  ///
  /// In en, this message translates to:
  /// **'{name}, number {id}, {requirement}'**
  String evolutionStageSemanticsWith(String name, int id, String requirement);

  /// No description provided for @evolutionCurrent.
  ///
  /// In en, this message translates to:
  /// **'current'**
  String get evolutionCurrent;

  /// No description provided for @compareTitle.
  ///
  /// In en, this message translates to:
  /// **'Compare'**
  String get compareTitle;

  /// No description provided for @compareSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select two Pokémon to compare their stats.'**
  String get compareSubtitle;

  /// No description provided for @compareSlotA.
  ///
  /// In en, this message translates to:
  /// **'Pokémon A'**
  String get compareSlotA;

  /// No description provided for @compareSlotB.
  ///
  /// In en, this message translates to:
  /// **'Pokémon B'**
  String get compareSlotB;

  /// No description provided for @compareVersus.
  ///
  /// In en, this message translates to:
  /// **'VS'**
  String get compareVersus;

  /// No description provided for @compareEmpty.
  ///
  /// In en, this message translates to:
  /// **'Select two Pokémon to start comparing'**
  String get compareEmpty;

  /// No description provided for @compareSelectSecond.
  ///
  /// In en, this message translates to:
  /// **'Select the second Pokémon to compare'**
  String get compareSelectSecond;

  /// No description provided for @compareFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load a Pokémon. Tap its card to retry.'**
  String get compareFailed;

  /// No description provided for @compareTapToRetry.
  ///
  /// In en, this message translates to:
  /// **'Tap to retry'**
  String get compareTapToRetry;

  /// No description provided for @compareSlotFailedSemantics.
  ///
  /// In en, this message translates to:
  /// **'{slot}: failed to load, tap to retry'**
  String compareSlotFailedSemantics(String slot);

  /// No description provided for @compareSlotLoadedSemantics.
  ///
  /// In en, this message translates to:
  /// **'{slot}: {name}, tap to change'**
  String compareSlotLoadedSemantics(String slot, String name);

  /// No description provided for @compareSlotSelectSemantics.
  ///
  /// In en, this message translates to:
  /// **'Select {slot}'**
  String compareSlotSelectSemantics(String slot);

  /// No description provided for @comparePickerHint.
  ///
  /// In en, this message translates to:
  /// **'Search Pokémon...'**
  String get comparePickerHint;

  /// No description provided for @compareTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get compareTotal;

  /// No description provided for @compareStatSemantics.
  ///
  /// In en, this message translates to:
  /// **'{stat}: {first} against {second}'**
  String compareStatSemantics(String stat, int first, int second);

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Pokémon you\'ve already opened are still available.'**
  String get offlineBanner;

  /// No description provided for @filterTypeSection.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get filterTypeSection;

  /// No description provided for @filterGenerationSection.
  ///
  /// In en, this message translates to:
  /// **'Generation'**
  String get filterGenerationSection;

  /// No description provided for @filterGenerationHint.
  ///
  /// In en, this message translates to:
  /// **'Alternate forms are hidden when a generation is selected.'**
  String get filterGenerationHint;

  /// No description provided for @filterSortSection.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get filterSortSection;

  /// No description provided for @generationName.
  ///
  /// In en, this message translates to:
  /// **'Gen {roman}'**
  String generationName(String roman);

  /// No description provided for @sortNumberAsc.
  ///
  /// In en, this message translates to:
  /// **'Number (low to high)'**
  String get sortNumberAsc;

  /// No description provided for @sortNumberDesc.
  ///
  /// In en, this message translates to:
  /// **'Number (high to low)'**
  String get sortNumberDesc;

  /// No description provided for @sortNameAsc.
  ///
  /// In en, this message translates to:
  /// **'Name (A–Z)'**
  String get sortNameAsc;

  /// No description provided for @sortNameDesc.
  ///
  /// In en, this message translates to:
  /// **'Name (Z–A)'**
  String get sortNameDesc;

  /// No description provided for @settingsStorage.
  ///
  /// In en, this message translates to:
  /// **'Offline data'**
  String get settingsStorage;

  /// No description provided for @storageUsed.
  ///
  /// In en, this message translates to:
  /// **'{size} of Pokémon data and images saved on this device'**
  String storageUsed(String size);

  /// No description provided for @storageEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing saved on this device'**
  String get storageEmpty;

  /// No description provided for @storageClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get storageClear;

  /// No description provided for @storageClearSemantics.
  ///
  /// In en, this message translates to:
  /// **'Clear offline data'**
  String get storageClearSemantics;

  /// No description provided for @detailEntry.
  ///
  /// In en, this message translates to:
  /// **'Pokédex entry'**
  String get detailEntry;

  /// No description provided for @speciesLegendary.
  ///
  /// In en, this message translates to:
  /// **'Legendary'**
  String get speciesLegendary;

  /// No description provided for @speciesMythical.
  ///
  /// In en, this message translates to:
  /// **'Mythical'**
  String get speciesMythical;

  /// No description provided for @habitatValue.
  ///
  /// In en, this message translates to:
  /// **'Habitat: {name}'**
  String habitatValue(String name);

  /// No description provided for @habitatCave.
  ///
  /// In en, this message translates to:
  /// **'Cave'**
  String get habitatCave;

  /// No description provided for @habitatForest.
  ///
  /// In en, this message translates to:
  /// **'Forest'**
  String get habitatForest;

  /// No description provided for @habitatGrassland.
  ///
  /// In en, this message translates to:
  /// **'Grassland'**
  String get habitatGrassland;

  /// No description provided for @habitatMountain.
  ///
  /// In en, this message translates to:
  /// **'Mountain'**
  String get habitatMountain;

  /// No description provided for @habitatRare.
  ///
  /// In en, this message translates to:
  /// **'Rare'**
  String get habitatRare;

  /// No description provided for @habitatRoughTerrain.
  ///
  /// In en, this message translates to:
  /// **'Rough terrain'**
  String get habitatRoughTerrain;

  /// No description provided for @habitatSea.
  ///
  /// In en, this message translates to:
  /// **'Sea'**
  String get habitatSea;

  /// No description provided for @habitatUrban.
  ///
  /// In en, this message translates to:
  /// **'Urban'**
  String get habitatUrban;

  /// No description provided for @habitatWatersEdge.
  ///
  /// In en, this message translates to:
  /// **'Water\'s edge'**
  String get habitatWatersEdge;

  /// No description provided for @storageSaveFavourites.
  ///
  /// In en, this message translates to:
  /// **'Save favourites for offline use'**
  String get storageSaveFavourites;

  /// No description provided for @storageNoFavourites.
  ///
  /// In en, this message translates to:
  /// **'Add favourites to save them for offline use'**
  String get storageNoFavourites;

  /// No description provided for @storageSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving {done} of {total}…'**
  String storageSaving(int done, int total);

  /// No description provided for @storageSaved.
  ///
  /// In en, this message translates to:
  /// **'Favourites saved'**
  String get storageSaved;

  /// No description provided for @storageSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Pokémon could not be saved} other{{count} Pokémon could not be saved}}. Check your connection.'**
  String storageSaveFailed(int count);

  /// No description provided for @typeChartOpen.
  ///
  /// In en, this message translates to:
  /// **'Full type chart'**
  String get typeChartOpen;

  /// No description provided for @typeChartTitle.
  ///
  /// In en, this message translates to:
  /// **'Type chart'**
  String get typeChartTitle;

  /// No description provided for @typeChartHint.
  ///
  /// In en, this message translates to:
  /// **'Rows are the attacking type, columns the defending type. Pinch to zoom, drag to move.'**
  String get typeChartHint;

  /// No description provided for @typeChartSuper.
  ///
  /// In en, this message translates to:
  /// **'Super effective (2×)'**
  String get typeChartSuper;

  /// No description provided for @typeChartNotVery.
  ///
  /// In en, this message translates to:
  /// **'Not very effective (½×)'**
  String get typeChartNotVery;

  /// No description provided for @typeChartNoEffect.
  ///
  /// In en, this message translates to:
  /// **'No effect (0×)'**
  String get typeChartNoEffect;

  /// No description provided for @typeChartCellSemantics.
  ///
  /// In en, this message translates to:
  /// **'{attacker} against {defender}: {multiplier}'**
  String typeChartCellSemantics(
    String attacker,
    String defender,
    String multiplier,
  );

  /// No description provided for @showShiny.
  ///
  /// In en, this message translates to:
  /// **'Show shiny'**
  String get showShiny;

  /// No description provided for @showNormal.
  ///
  /// In en, this message translates to:
  /// **'Show normal'**
  String get showNormal;

  /// No description provided for @statsShowRadar.
  ///
  /// In en, this message translates to:
  /// **'Show as radar chart'**
  String get statsShowRadar;

  /// No description provided for @statsShowBars.
  ///
  /// In en, this message translates to:
  /// **'Show as bars'**
  String get statsShowBars;

  /// No description provided for @detailForms.
  ///
  /// In en, this message translates to:
  /// **'Forms'**
  String get detailForms;

  /// No description provided for @navTeam.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get navTeam;

  /// No description provided for @teamTitle.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get teamTitle;

  /// No description provided for @teamSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick up to six Pokémon and see what the team is weak to and what it hits hard.'**
  String get teamSubtitle;

  /// No description provided for @teamClear.
  ///
  /// In en, this message translates to:
  /// **'Clear team'**
  String get teamClear;

  /// No description provided for @teamSlotEmpty.
  ///
  /// In en, this message translates to:
  /// **'Add a Pokémon'**
  String get teamSlotEmpty;

  /// No description provided for @teamSlotEmptySemantics.
  ///
  /// In en, this message translates to:
  /// **'Empty slot {number}, add a Pokémon'**
  String teamSlotEmptySemantics(int number);

  /// No description provided for @teamRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from the team'**
  String teamRemove(String name);

  /// No description provided for @teamEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Add a Pokémon to start building your team.'**
  String get teamEmptyHint;

  /// No description provided for @teamLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Pokémon could not be loaded. Tap to retry} other{{count} Pokémon could not be loaded. Tap to retry}}'**
  String teamLoadFailed(int count);

  /// No description provided for @teamDefence.
  ///
  /// In en, this message translates to:
  /// **'Defence'**
  String get teamDefence;

  /// No description provided for @teamDefenceHint.
  ///
  /// In en, this message translates to:
  /// **'Types with more Pokémon weak to them than resisting them; ×N is how many.'**
  String get teamDefenceHint;

  /// No description provided for @teamWeakTo.
  ///
  /// In en, this message translates to:
  /// **'Weak to'**
  String get teamWeakTo;

  /// No description provided for @teamResists.
  ///
  /// In en, this message translates to:
  /// **'Resists'**
  String get teamResists;

  /// No description provided for @teamNoWeakness.
  ///
  /// In en, this message translates to:
  /// **'No type gives this team trouble.'**
  String get teamNoWeakness;

  /// No description provided for @teamNoResistance.
  ///
  /// In en, this message translates to:
  /// **'No type is resisted by more Pokémon than it hurts.'**
  String get teamNoResistance;

  /// No description provided for @teamOffence.
  ///
  /// In en, this message translates to:
  /// **'Offence'**
  String get teamOffence;

  /// No description provided for @teamOffenceHint.
  ///
  /// In en, this message translates to:
  /// **'Judged by the types of your Pokémon, not by their moves.'**
  String get teamOffenceHint;

  /// No description provided for @teamHits.
  ///
  /// In en, this message translates to:
  /// **'Hits super effectively'**
  String get teamHits;

  /// No description provided for @teamMisses.
  ///
  /// In en, this message translates to:
  /// **'Not covered'**
  String get teamMisses;

  /// No description provided for @teamNoCoverage.
  ///
  /// In en, this message translates to:
  /// **'No type is hit super effectively yet.'**
  String get teamNoCoverage;

  /// No description provided for @teamNoGaps.
  ///
  /// In en, this message translates to:
  /// **'Every type is covered.'**
  String get teamNoGaps;

  /// No description provided for @filterWeakToSection.
  ///
  /// In en, this message translates to:
  /// **'Weak to'**
  String get filterWeakToSection;

  /// No description provided for @filterWeakToHint.
  ///
  /// In en, this message translates to:
  /// **'Pokémon that take double damage or more from any of the chosen types.'**
  String get filterWeakToHint;

  /// No description provided for @weakToChip.
  ///
  /// In en, this message translates to:
  /// **'Weak to {type}'**
  String weakToChip(String type);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
