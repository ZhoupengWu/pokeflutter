import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../l10n/l10n_extensions.dart';
import '../../theme/app_colors.dart';
import '../../core/pokemon_constants.dart';

// ── Empty / error message ─────────────────────────────────────────────────────
class HomeMessage extends StatelessWidget {
  final IconData icon;
  final String text;
  final Widget? action;

  const HomeMessage({
    super.key,
    required this.icon,
    required this.text,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64.r, color: context.colors.border),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: context.colors.subtle),
              textAlign: TextAlign.center,
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}

// ── "Types could not be loaded" banner ────────────────────────────────────────
/// A thin notice under the search bar: either the types could not be loaded
/// (with a Retry), or PokéAPI is unreachable but saved data still works.
class ConnectionBanner extends StatelessWidget {
  final String message;

  /// Shows a Retry button when set.
  final VoidCallback? onRetry;

  const ConnectionBanner({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 0),
      child: Row(
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 16.r,
            color: context.colors.subtle,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: context.colors.subtle),
            ),
          ),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: Text(context.l10n.retry)),
        ],
      ),
    );
  }
}

// ── Active filter chips row ───────────────────────────────────────────────────
class ActiveFilterChips extends StatelessWidget {
  final Set<String> filters;
  final ValueChanged<String> onRemove;
  final VoidCallback onClearAll;

  const ActiveFilterChips({
    super.key,
    required this.filters,
    required this.onRemove,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        children: [
          ...filters.map((type) {
            final color = listPokemonTypeColor[type] ?? context.colors.muted;
            return Container(
              margin: EdgeInsets.only(right: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.typeName(type),
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(color: Colors.white),
                  ),
                  SizedBox(width: 4.w),
                  Semantics(
                    button: true,
                    label: context.l10n.removeFilter(
                      context.l10n.typeName(type),
                    ),
                    excludeSemantics: true,
                    onTap: () => onRemove(type),
                    child: GestureDetector(
                      onTap: () => onRemove(type),
                      child: Icon(
                        Icons.close_rounded,
                        size: 14.r,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          GestureDetector(
            onTap: onClearAll,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                border: Border.all(color: context.colors.subtle),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                context.l10n.clearAll,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: context.colors.muted),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
