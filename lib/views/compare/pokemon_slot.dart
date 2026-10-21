import 'package:flutter/material.dart';
import '../shared/pokemon_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/compare_controller.dart';
import '../../l10n/l10n_extensions.dart';
import '../../model/pokemon.dart';
import '../../theme/app_colors.dart';
import '../../core/pokemon_constants.dart';

/// One of the two cards at the top of Compare: empty, loading, failed
/// (tap to retry) or showing the chosen Pokémon (tap to change).
class PokemonSlotCard extends StatelessWidget {
  const PokemonSlotCard({
    super.key,
    required this.state,
    required this.label,
    required this.onTap,
  });

  final SlotState state;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pokemon = state.pokemon;
    final color = pokemon != null
        ? listPokemonTypeColor[pokemon.typesList.first.toLowerCase()] ??
              context.colors.border
        : context.colors.fill;

    return Semantics(
      button: true,
      label: state.failed
          ? l10n.compareSlotFailedSemantics(label)
          : pokemon != null
          ? l10n.compareSlotLoadedSemantics(
              label,
              context.pokemonName(pokemon.name),
            )
          : l10n.compareSlotSelectSemantics(label),
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(20.r),
        animationDuration: const Duration(milliseconds: 250),
        child: InkWell(
          borderRadius: BorderRadius.circular(20.r),
          onTap: onTap,
          child: SizedBox(
            height: 140.h,
            child: state.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : state.failed
                ? _CenteredHint(
                    icon: Icons.refresh_rounded,
                    text: l10n.compareTapToRetry,
                  )
                : pokemon != null
                ? _Loaded(pokemon: pokemon)
                : _CenteredHint(
                    icon: Icons.add_circle_outline_rounded,
                    text: label,
                  ),
          ),
        ),
      ),
    );
  }
}

class _CenteredHint extends StatelessWidget {
  const _CenteredHint({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final subtle = context.colors.subtle;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 32.r, color: subtle),
        SizedBox(height: 8.h),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: subtle),
        ),
      ],
    );
  }
}

class _Loaded extends StatelessWidget {
  const _Loaded({required this.pokemon});

  final Pokemon pokemon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            context.pokemonName(pokemon.name),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          PokemonImage(
            pokemon.urlImage,
            height: 72.r,
            width: 72.r,
            fit: BoxFit.contain,
            excludeFromSemantics: true,
            errorBuilder: (_, _, _) =>
                Icon(Icons.catching_pokemon, size: 48.r, color: Colors.white38),
          ),
        ],
      ),
    );
  }
}
