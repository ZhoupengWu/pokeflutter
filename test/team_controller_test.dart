import 'package:flutter_test/flutter_test.dart';
import 'package:pokeflutter/controllers/team_controller.dart';
import 'package:pokeflutter/data/team_manager.dart';
import 'package:pokeflutter/model/pokemon_list_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/quiz_fakes.dart';

PokemonListItem _item(int id) => PokemonListItem(
  name: 'mon$id',
  url: 'https://pokeapi.co/api/v2/pokemon/$id/',
);

Future<(TeamController, TeamManager, FakePokemonApi)> _controller({
  List<int> team = const [],
  FakePokemonApi? api,
  List<String> types = const ['fire'],
}) async {
  SharedPreferences.setMockInitialValues({
    'team_pokemon_names': [for (final id in team) 'mon$id'],
  });
  final repository = fakeRepository();
  final manager = TeamManager();
  await manager.init(await repository.getAll());
  final pokemonApi = api ?? FakePokemonApi(types: types);
  final controller = TeamController(
    team: manager,
    api: pokemonApi,
    repository: repository,
  );
  await controller.init();
  return (controller, manager, pokemonApi);
}

void main() {
  test('loads the list and the details of the saved team', () async {
    final (c, _, api) = await _controller(team: [1, 2]);

    expect(c.allPokemon, isNotEmpty);
    expect(c.members.map((m) => m.name), ['mon1', 'mon2']);
    expect(api.requested, unorderedEquals(['mon1', 'mon2']));
    expect(c.details.keys, unorderedEquals(['mon1', 'mon2']));
    expect(c.analysedCount, 2);
    expect(c.analysis.size, 2);
    c.dispose();
  });

  test('the analysis follows the types of the members', () async {
    final (c, _, _) = await _controller(team: [1], types: ['water']);

    expect(c.analysis.weaknesses, containsAll(['electric', 'grass']));
    expect(c.analysis.covered, containsAll(['fire', 'ground', 'rock']));
    c.dispose();
  });

  test('adding fetches the newcomer, removing forgets it', () async {
    final (c, _, api) = await _controller(team: [1]);
    api.requested.clear();

    expect(await c.add(_item(2)), isTrue);
    await Future<void>.delayed(Duration.zero);
    expect(api.requested, ['mon2']); // mon1 was not fetched again
    expect(c.analysedCount, 2);

    await c.remove(_item(1));
    expect(c.details.keys, ['mon2']);
    expect(c.members.map((m) => m.name), ['mon2']);
    c.dispose();
  });

  test('available leaves out the Pokémon already in the team', () async {
    final (c, _, _) = await _controller(team: [1, 2]);

    expect(c.available.map((p) => p.name), isNot(contains('mon1')));
    expect(c.available.map((p) => p.name), contains('mon3'));
    c.dispose();
  });

  test('a Pokémon that fails to load is reported and can be retried', () async {
    final api = FakePokemonApi(failing: {'mon2'});
    final (c, _, _) = await _controller(team: [1, 2], api: api);

    expect(c.failed, {'mon2'});
    expect(c.analysedCount, 1); // the analysis uses what loaded
    expect(c.members, hasLength(2)); // but the member stays in the team

    api.failing.clear();
    await c.loadDetails();
    expect(c.failed, isEmpty);
    expect(c.analysedCount, 2);
    c.dispose();
  });

  test('the team cannot grow past six, or hold a Pokémon twice', () async {
    final (c, _, _) = await _controller(team: [1, 2, 3, 4, 5, 6]);

    expect(c.isFull, isTrue);
    expect(await c.add(_item(7)), isFalse);
    await c.clear();
    expect(c.isEmpty, isTrue);
    expect(await c.add(_item(1)), isTrue);
    expect(await c.add(_item(1)), isFalse);
    c.dispose();
  });
}
