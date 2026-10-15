import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../l10n/l10n_extensions.dart';
import '../../model/pokemon_species.dart';
import '../../theme/app_colors.dart';
import 'about_sections.dart';

/// The Pokédex entry: category ("Mouse Pokémon"), description in the app's
/// language (English when the entry has no translation), habitat and
/// legendary / mythical tags.
class SpeciesSection extends StatelessWidget {
  const SpeciesSection({
    super.key,
    required this.species,
    required this.accent,
  });

  final PokemonSpecies species;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final language = Localizations.localeOf(context).languageCode;
    final category = species.categoryFor(language);
    final description = species.descriptionFor(language);
    final habitat = species.habitat;
    final tags = [
      if (species.isLegendary) l10n.speciesLegendary,
      if (species.isMythical) l10n.speciesMythical,
      if (habitat != null) l10n.habitatValue(l10n.habitatName(habitat)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(l10n.detailEntry, accent: accent),
        if (category != null) ...[
          SizedBox(height: 4.h),
          Text(
            category,
            style: textTheme.labelLarge?.copyWith(color: colors.muted),
          ),
        ],
        if (description != null) ...[
          SizedBox(height: 8.h),
          Text(
            description,
            style: textTheme.bodyMedium?.copyWith(
              color: colors.strong,
              height: 1.4,
            ),
          ),
        ],
        if (tags.isNotEmpty) ...[
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 6.h,
            children: [for (final tag in tags) _Tag(tag, accent: accent)],
          ),
        ],
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.label, {required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
    decoration: BoxDecoration(
      color: accent.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(20.r),
      border: Border.all(color: accent.withValues(alpha: 0.3)),
    ),
    child: Text(
      label,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: accent,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
