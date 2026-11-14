import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pokeflutter/data/pokemon_type_index.dart';

/// `mon1`…`mon30` (see `fakeRepository`): the first ten are fire, the next
/// ten water and the rest grass.
Map<String, List<String>> defaultFakeTypes() => {
  for (var i = 1; i <= 30; i++)
    'mon$i': i <= 10
        ? ['fire']
        : i <= 20
        ? ['water']
        : ['grass'],
};

/// A type index fed by [typesByName] through a fake network (the `/type/{t}`
/// endpoints), or failing as if offline when [offline] is set.
PokemonTypeIndex fakeTypeIndex({
  Map<String, List<String>>? typesByName,
  bool offline = false,
}) {
  final types = typesByName ?? defaultFakeTypes();
  return PokemonTypeIndex(
    client: MockClient((http.Request request) async {
      if (offline) return http.Response('', 503);
      final type = request.url.pathSegments.last;
      return http.Response(
        jsonEncode({
          'pokemon': [
            for (final entry in types.entries)
              if (entry.value.contains(type))
                {
                  'pokemon': {'name': entry.key},
                  'slot': entry.value.indexOf(type) + 1,
                },
          ],
        }),
        200,
      );
    }),
  );
}
