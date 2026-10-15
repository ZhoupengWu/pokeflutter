import 'package:flutter_test/flutter_test.dart';
import 'package:pokeflutter/data/pokemon_repository.dart';

const _json = '''
{"pokemonList": [
  {"name": "bulbasaur", "url": "https://pokeapi.co/api/v2/pokemon/1/"},
  {"name": "ivysaur", "url": "https://pokeapi.co/api/v2/pokemon/2/"}
]}''';

void main() {
  test('parses the list once and shares it', () async {
    var loads = 0;
    final repo = PokemonRepository(
      loadAsset: () async {
        loads++;
        return _json;
      },
    );

    final a = await repo.getAll();
    final b = await repo.getAll();

    expect(a.map((p) => p.name), ['bulbasaur', 'ivysaur']);
    expect(a.first.url, 'https://pokeapi.co/api/v2/pokemon/1/');
    expect(identical(a, b), isTrue);
    expect(loads, 1);
  });

  test('the returned list cannot be modified', () async {
    final repo = PokemonRepository(loadAsset: () async => _json);

    final list = await repo.getAll();

    expect(list.clear, throwsUnsupportedError);
  });

  test('a failed load can be retried', () async {
    var fail = true;
    final repo = PokemonRepository(
      loadAsset: () async => fail ? throw Exception('boom') : _json,
    );

    await expectLater(repo.getAll(), throwsException);
    fail = false;

    expect(await repo.getAll(), hasLength(2));
  });

  test('the bundled asset is valid', () async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final all = await PokemonRepository().getAll();

    expect(all, isNotEmpty);
    expect(all.first.name, 'bulbasaur');
  });
}
