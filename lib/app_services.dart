import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'data/app_settings.dart';
import 'data/evolution_api.dart';
import 'data/favourites_manager.dart';
import 'data/pokemon_api.dart';
import 'data/pokemon_repository.dart';
import 'data/pokemon_type_index.dart';
import 'data/quiz_stats_store.dart';

/// The app's long-lived collaborators, created once and handed to the widget
/// tree by [AppProviders]. Pages and controllers receive what they need from
/// here instead of reaching for global singletons, so tests can swap any of
/// them for a fake.
class AppServices {
  AppServices({
    PokemonRepository? repository,
    PokemonApi? pokemonApi,
    EvolutionApi? evolutionApi,
    PokemonTypeIndex? typeIndex,
    FavouritesManager? favourites,
    AppSettings? settings,
    QuizStatsStore? quizStats,
  }) : repository = repository ?? PokemonRepository(),
       pokemonApi = pokemonApi ?? PokemonApi(),
       evolutionApi = evolutionApi ?? EvolutionApi(),
       typeIndex = typeIndex ?? PokemonTypeIndex(),
       favourites = favourites ?? FavouritesManager(),
       settings = settings ?? AppSettings(),
       quizStats = quizStats ?? QuizStatsStore();

  final PokemonRepository repository;
  final PokemonApi pokemonApi;
  final EvolutionApi evolutionApi;
  final PokemonTypeIndex typeIndex;
  final FavouritesManager favourites;
  final AppSettings settings;
  final QuizStatsStore quizStats;

  /// Loads what the first screen needs: the bundled list (favourites are
  /// re-hydrated from it) and the saved settings. The type index is started
  /// without waiting; the grid repaints when it arrives and a failure is
  /// retried on next use.
  Future<void> init() async {
    final all = await repository.getAll();
    await favourites.init(all);
    await settings.init();
    unawaited(typeIndex.ensureLoaded());
  }
}

/// Makes every service of [services] available below it with `context.read`.
class AppProviders extends StatelessWidget {
  const AppProviders({super.key, required this.services, required this.child});

  final AppServices services;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppServices>.value(value: services),
        Provider<PokemonRepository>.value(value: services.repository),
        Provider<PokemonApi>.value(value: services.pokemonApi),
        Provider<EvolutionApi>.value(value: services.evolutionApi),
        // Listenables are only looked up (widgets listen to them explicitly),
        // so they use InheritedProvider, which Provider's lint does not flag.
        InheritedProvider<PokemonTypeIndex>.value(value: services.typeIndex),
        Provider<FavouritesManager>.value(value: services.favourites),
        InheritedProvider<AppSettings>.value(value: services.settings),
        Provider<QuizStatsStore>.value(value: services.quizStats),
      ],
      child: child,
    );
  }
}
