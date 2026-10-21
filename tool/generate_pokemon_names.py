#!/usr/bin/env python3
"""Builds assets/pokemonNames.json: display names of every entry of
assets/pokemonList.json in the languages the app offers.

Source: the PokéAPI CSV data (pokemon.csv, pokemon_species.csv,
pokemon_species_names.csv, in https://github.com/PokeAPI/pokeapi/tree/master/data/v2/csv).
Alternate forms show the species name plus the form: "Charizard (Mega X)".

    python3 tool/generate_pokemon_names.py [csv_dir]

Without csv_dir the files are downloaded. Add a language by extending LANGUAGES
(code -> PokéAPI language id, see languages.csv) and the app's locales.
"""
import csv
import json
import os
import sys
import urllib.request

LANGUAGES = {'en': '9', 'it': '8'}
BASE = 'https://raw.githubusercontent.com/PokeAPI/pokeapi/master/data/v2/csv/'
ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')

# Form identifiers that read better spelled out.
FORM_WORDS = {'gmax': 'Gigantamax', 'mega': 'Mega', 'x': 'X', 'y': 'Y'}


def rows(name, directory):
    if directory:
        path = os.path.join(directory, name)
        text = open(path, encoding='utf-8').read()
    else:
        with urllib.request.urlopen(BASE + name, timeout=60) as response:
            text = response.read().decode('utf-8')
    return list(csv.DictReader(text.splitlines()))


def form_label(suffix):
    return ' '.join(FORM_WORDS.get(w, w.capitalize()) for w in suffix.split('-'))


def main():
    directory = sys.argv[1] if len(sys.argv) > 1 else None
    pokemon = {r['identifier']: r for r in rows('pokemon.csv', directory)}
    species_identifier = {
        r['id']: r['identifier'] for r in rows('pokemon_species.csv', directory)
    }
    species_by_identifier = {v: k for k, v in species_identifier.items()}
    names = {}  # species id -> language code -> name
    wanted = {v: k for k, v in LANGUAGES.items()}
    for r in rows('pokemon_species_names.csv', directory):
        code = wanted.get(r['local_language_id'])
        if code and r['name']:
            names.setdefault(r['pokemon_species_id'], {})[code] = r['name']

    listed = json.load(
        open(os.path.join(ROOT, 'assets', 'pokemonList.json'), encoding='utf-8')
    )['pokemonList']

    table, missing = {}, []
    for entry in listed:
        identifier = entry['name']
        row = pokemon.get(identifier)
        species_id = row['species_id'] if row else species_by_identifier.get(identifier)
        species = names.get(species_id) if species_id else None
        if not species or 'en' not in species:
            missing.append(identifier)
            continue
        suffix = ''
        base = species_identifier.get(species_id, '')
        if identifier != base and identifier.startswith(base + '-'):
            suffix = form_label(identifier[len(base) + 1:])
        item = {}
        for code in LANGUAGES:
            name = species.get(code, species['en'])
            item[code] = f'{name} ({suffix})' if suffix else name
        # Only what differs from English is stored; the app falls back to it.
        value = {'en': item['en']}
        value.update({c: n for c, n in item.items() if c != 'en' and n != item['en']})
        table[identifier] = value

    with open(os.path.join(ROOT, 'assets', 'pokemonNames.json'), 'w', encoding='utf-8') as out:
        json.dump(table, out, ensure_ascii=False, separators=(',', ':'), sort_keys=False)
        out.write('\n')
    print(f'{len(table)} names written, {len(missing)} without data: {missing[:10]}')


if __name__ == '__main__':
    main()
