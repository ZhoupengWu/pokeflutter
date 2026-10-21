import 'package:flutter_test/flutter_test.dart';
import 'package:pokeflutter/data/team_manager.dart';
import 'package:pokeflutter/model/pokemon_list_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

PokemonListItem _item(int id) => PokemonListItem(
  name: 'mon$id',
  url: 'https://pokeapi.co/api/v2/pokemon/$id/',
);

final _all = [for (var i = 1; i <= 10; i++) _item(i)];

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<TeamManager> manager() async {
    final m = TeamManager();
    await m.init(_all);
    return m;
  }

  test('starts empty', () async {
    final m = await manager();

    expect(m.members, isEmpty);
    expect(m.isFull, isFalse);
  });

  test('adds members in order, without duplicates', () async {
    final m = await manager();

    expect(await m.add(_item(3)), isTrue);
    expect(await m.add(_item(1)), isTrue);
    expect(await m.add(_item(3)), isFalse); // already there

    expect(m.members.map((p) => p.name), ['mon3', 'mon1']);
    expect(m.contains('mon3'), isTrue);
    expect(m.contains('mon2'), isFalse);
  });

  test('holds at most six', () async {
    final m = await manager();
    for (var i = 1; i <= 6; i++) {
      expect(await m.add(_item(i)), isTrue);
    }

    expect(m.isFull, isTrue);
    expect(await m.add(_item(7)), isFalse);
    expect(m.members, hasLength(6));
  });

  test('removes one and clears all', () async {
    final m = await manager();
    await m.add(_item(1));
    await m.add(_item(2));

    await m.remove('mon1');
    expect(m.members.map((p) => p.name), ['mon2']);

    await m.clear();
    expect(m.members, isEmpty);
  });

  test('the team survives a restart, in the same order', () async {
    final first = await manager();
    await first.add(_item(5));
    await first.add(_item(2));

    final second = await manager(); // a new instance reads the preferences
    expect(second.members.map((p) => p.name), ['mon5', 'mon2']);
  });

  test(
    'names no longer in the list are dropped, and the team is capped',
    () async {
      SharedPreferences.setMockInitialValues({
        'team_pokemon_names': [
          'mon1',
          'ghost', // not in the list any more
          'mon2',
          'mon3',
          'mon4',
          'mon5',
          'mon6',
          'mon7',
        ],
      });

      final m = await manager();

      expect(m.members.map((p) => p.name), [
        'mon1',
        'mon2',
        'mon3',
        'mon4',
        'mon5',
        'mon6',
      ]);
    },
  );

  test('listeners hear about every change', () async {
    final m = await manager();
    var calls = 0;
    m.notifier.addListener(() => calls++);

    await m.add(_item(1));
    await m.remove('mon1');

    expect(calls, 2);
  });
}
