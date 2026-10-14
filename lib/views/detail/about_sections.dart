import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../l10n/l10n_extensions.dart';
import '../../model/pokemon.dart';
import '../../utils/app_colors.dart';
import '../../utils/capitalize.dart';
import '../widgets/styled_text.dart';

/// Heading of a section on the detail card, in the Pokémon's colour.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, required this.accent});

  final String title;
  final Color accent;

  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: accent,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

/// Weight and height.
class AboutSection extends StatelessWidget {
  const AboutSection({super.key, required this.pokemon, required this.accent});

  final Pokemon pokemon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(l10n.detailAbout, accent: accent),
        SizedBox(height: 12.h),
        Row(
          children: [
            _InfoTile(
              icon: Icons.monitor_weight_outlined,
              label: l10n.detailWeight,
              value: l10n.weightValue(l10n.decimal(pokemon.weight)),
            ),
            Container(height: 32.h, width: 1.w, color: context.colors.border),
            _InfoTile(
              icon: Icons.height_rounded,
              label: l10n.detailHeight,
              value: l10n.heightValue(l10n.decimal(pokemon.height)),
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    return Expanded(
      child: Semantics(
        label: '$label: $value',
        excludeSemantics: true,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16.r, color: colors.muted),
                SizedBox(width: 4.w),
                StyledText(
                  text: value,
                  style: textTheme.bodyMedium!.copyWith(color: colors.strong),
                  textHeight: 20.h,
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: textTheme.bodySmall?.copyWith(color: colors.subtle),
            ),
          ],
        ),
      ),
    );
  }
}

class AbilitiesSection extends StatelessWidget {
  const AbilitiesSection({
    super.key,
    required this.pokemon,
    required this.accent,
  });

  final Pokemon pokemon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(context.l10n.detailAbilities, accent: accent),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 6.h,
          children: [
            for (final ability in pokemon.abilities)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: accent.withValues(alpha: 0.3)),
                ),
                child: Text(
                  ability.replaceAll('-', ' ').capitalize(),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: accent),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class StatsSection extends StatelessWidget {
  const StatsSection({super.key, required this.pokemon, required this.accent});

  final Pokemon pokemon;
  final Color accent;

  /// Highest base stat of any Pokémon (Blissey's HP), the full-bar value.
  static const _maxStat = 255.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(l10n.detailBaseStats, accent: accent),
        SizedBox(height: 12.h),
        for (final stat in pokemon.stats)
          Semantics(
            label: '${l10n.statLabel(stat.name)}: ${stat.value}',
            excludeSemantics: true,
            child: Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                children: [
                  SizedBox(
                    width: 40.w,
                    child: Text(
                      l10n.statLabel(stat.name),
                      style: textTheme.bodySmall?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  SizedBox(
                    width: 28.w,
                    child: Text(
                      stat.value.toString(),
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.strong,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4.r),
                      child: LinearProgressIndicator(
                        value: stat.value / _maxStat,
                        minHeight: 6.h,
                        backgroundColor: colors.fill,
                        valueColor: AlwaysStoppedAnimation<Color>(accent),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
