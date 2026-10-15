import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/compare_controller.dart';
import '../../l10n/l10n_extensions.dart';
import '../../model/pokemon_list_item.dart';
import '../../theme/app_colors.dart';
import 'pokemon_picker_sheet.dart';
import 'pokemon_slot.dart';
import 'stats_comparison.dart';

/// The Compare tab: pick two Pokémon and see their base stats side by side.
class ComparePage extends StatefulWidget {
  /// Pass a [controller] to drive the page from a test.
  const ComparePage({super.key, this.controller});

  final CompareController? controller;

  @override
  State<ComparePage> createState() => _ComparePageState();
}

class _ComparePageState extends State<ComparePage> {
  late final CompareController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? CompareController();
    _controller.init();
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  Future<void> _pick(CompareSlot slot) async {
    final result = await showModalBottomSheet<PokemonListItem>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (_) => PokemonPickerSheet(allPokemon: _controller.allPokemon),
    );
    if (result != null) await _controller.select(slot, result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            final a = _controller.slot(CompareSlot.a);
            final b = _controller.slot(CompareSlot.b);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),
                Padding(
                  padding: EdgeInsets.only(
                    left: 24.w,
                    right: 24.w,
                    bottom: 4.h,
                  ),
                  child: Text(l10n.compareTitle, style: textTheme.displaySmall),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Text(
                    l10n.compareSubtitle,
                    style: textTheme.bodyLarge?.copyWith(
                      color: context.colors.muted,
                      height: 1.5,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                // ── Selector row ────────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: PokemonSlotCard(
                          state: a,
                          label: l10n.compareSlotA,
                          onTap: a.failed
                              ? () => _controller.retry(CompareSlot.a)
                              : () => _pick(CompareSlot.a),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Text(
                          l10n.compareVersus,
                          style: textTheme.titleLarge?.copyWith(
                            color: context.colors.subtle,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Expanded(
                        child: PokemonSlotCard(
                          state: b,
                          label: l10n.compareSlotB,
                          onTap: b.failed
                              ? () => _controller.retry(CompareSlot.b)
                              : () => _pick(CompareSlot.b),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // ── Stats comparison or a hint ──────────────────────────────
                Expanded(
                  child: _controller.canCompare
                      ? SingleChildScrollView(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          child: StatsComparison(a: a.pokemon!, b: b.pokemon!),
                        )
                      : Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            child: Text(
                              _controller.anyFailed
                                  ? l10n.compareFailed
                                  : _controller.nothingSelected
                                  ? l10n.compareEmpty
                                  : l10n.compareSelectSecond,
                              style: textTheme.bodyMedium?.copyWith(
                                color: context.colors.subtle,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
