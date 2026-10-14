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
  /// **'Filter by type'**
  String get filterByType;

  /// No description provided for @filterByTypeSelected.
  ///
  /// In en, this message translates to:
  /// **'Filter by type, {count} selected'**
  String filterByTypeSelected(int count);

  /// No description provided for @filterSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter by Type'**
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
