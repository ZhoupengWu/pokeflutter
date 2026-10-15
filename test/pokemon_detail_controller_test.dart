import 'package:flutter_test/flutter_test.dart';
import 'package:pokeflutter/controllers/pokemon_detail_controller.dart';
import 'package:pokeflutter/model/pokemon.dart';
import 'package:pokeflutter/model/pokemon_list_item.dart';

import 'support/detail_fakes.dart';
import 'support/fixtures.dart';
import 'support/quiz_fakes.dart';

PokemonListItem _item(String name, int id) =>
    PokemonListItem(name: name, url: 'https://pokeapi.co/api/v2/pokemon/$id/');

PokemonDetailController _controller({
  FakePokemonApi? api,
  FakeEvolutionApi? evolution,
  FakeSpeciesApi? species,
  FakeAbilityApi? ability,
}) => PokemonDetailController(
  item: _item('mon2', 2),
  api: api ?? FakePokemonApi(),
  evolutionApi: evolution ?? FakeEvolutionApi(),
  speciesApi: species ?? FakeSpeciesApi(),
  abilityApi: ability ?? FakeAbilityApi(),
  repository: fakeRepository(),
);

void main() {
  test('loads the details, then the evolution chain', () async {
    final evolution = FakeEvolutionApi();
    final c = _controller(evolution: evolution);
    expect(c.status, LoadStatus.loading);

    await c.load();

    expect(c.status, LoadStatus.loaded);
    expect(c.pokemon?.name, 'mon2');
    expect(c.evolutionStatus, LoadStatus.loaded);
    expect(evolution.requested, ['mon2']); // species name defaults to name
    expect(c.evolution?.root.name, 'bulbasaur');
  });

  test('a failed load can be retried', () async {
    final api = FakePokemonApi(failing: {'mon2'});
    final c = _controller(api: api);

    await c.load();
    expect(c.status, LoadStatus.failed);
    expect(c.pokemon, isNull);

    api.failing.clear();
    await c.load();
    expect(c.status, LoadStatus.loaded);
  });

  test('the evolution chain failing does not hide the details', () async {
    final evolution = FakeEvolutionApi(fail: true);
    final c = _controller(evolution: evolution);

    await c.load();

    expect(c.status, LoadStatus.loaded);
    expect(c.evolutionStatus, LoadStatus.failed);

    evolution.fail = false;
    await c.loadEvolution();
    expect(c.evolutionStatus, LoadStatus.loaded);
  });

  test('looks the species up in the bundled list by Pokédex number', () async {
    final c = _controller();
    await c.load();

    expect(c.itemForSpecies(3)?.name, 'mon3');
    expect(c.itemForSpecies(9999), isNull);
  });

  test('uses the species name of an alternate form', () async {
    final evolution = FakeEvolutionApi();
    final species = FakeSpeciesApi();
    final api = _SpeciesApi();
    final c = PokemonDetailController(
      item: _item('charizard-mega-x', 10034),
      api: api,
      evolutionApi: evolution,
      speciesApi: species,
      abilityApi: FakeAbilityApi(),
      repository: fakeRepository(),
    );

    await c.load();

    expect(evolution.requested, ['charizard']);
    expect(species.requested, ['charizard']);
  });

  test('loads the species information along with the chain', () async {
    final species = FakeSpeciesApi();
    final c = _controller(species: species);

    await c.load();

    expect(species.requested, ['mon2']);
    expect(c.species?.categories['en'], 'Mouse Pokémon');
  });

  test('loads the translated names of the abilities', () async {
    final ability = FakeAbilityApi();
    final c = _controller(ability: ability);

    await c.load();

    expect(ability.requested, ['blaze']);
    expect(c.abilityNames['blaze']?['it'], 'Fuocardore');
  });

  test('ability names failing keep the English id', () async {
    final c = _controller(ability: FakeAbilityApi(fail: true));

    await c.load();

    expect(c.status, LoadStatus.loaded);
    expect(c.abilityNames, isEmpty);
  });

  test('species information failing leaves the rest intact', () async {
    final c = _controller(species: FakeSpeciesApi(fail: true));

    await c.load();

    expect(c.status, LoadStatus.loaded);
    expect(c.evolutionStatus, LoadStatus.loaded);
    expect(c.species, isNull);
  });

  test('does nothing after being disposed', () async {
    final c = _controller();
    final loading = c.load();
    c.dispose();

    await loading; // must not throw (notifyListeners after dispose)
  });
}

class _SpeciesApi extends FakePokemonApi {
  @override
  Future<Pokemon> getPokemonDetails(String name) async => Pokemon.fromJson(
    pokemonJson(name: 'charizard-mega-x', speciesName: 'charizard'),
  );
}
