import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../l10n/l10n_extensions.dart';
import '../../model/pokemon_list_item.dart';
import '../../theme/app_colors.dart';
import 'about_sections.dart';
import 'pokemon_detail_page.dart';
import '../../theme/shapes.dart';

/// The other forms of the species (Mega, regional, Gigantamax…) as chips; the
/// one on screen is marked and the others open their own detail page.
class FormsSection extends StatelessWidget {
  const FormsSection({
    super.key,
    required this.forms,
    required this.currentName,
    required this.accent,
  });

  final List<PokemonListItem> forms;

  /// API name of the form on screen.
  final String currentName;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(l10n.detailForms, accent: accent),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 6.h,
          children: [
            for (final form in forms)
              _FormChip(
                label: context.pokemonName(form.name),
                selected: form.name == currentName,
                accent: accent,
                textStyle: textTheme.bodySmall,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => PokemonDetailPage(pokemon: form),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _FormChip extends StatelessWidget {
  const _FormChip({
    required this.label,
    required this.selected,
    required this.accent,
    required this.textStyle,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color accent;
  final TextStyle? textStyle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final shape = BorderRadius.circular(radiusPill);
    return Semantics(
      button: !selected,
      selected: selected,
      label: selected ? '$label, ${context.l10n.evolutionCurrent}' : label,
      excludeSemantics: true,
      onTap: selected ? null : onTap,
      child: Material(
        color: selected ? accent : accent.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: shape,
          side: BorderSide(color: accent.withValues(alpha: 0.3)),
        ),
        child: InkWell(
          borderRadius: shape,
          onTap: selected ? null : onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            child: Text(
              label,
              style: textStyle?.copyWith(
                color: selected ? context.colors.surface : accent,
                fontWeight: selected ? FontWeight.w700 : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
