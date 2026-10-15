import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../l10n/l10n_extensions.dart';
import '../../model/pokemon_list_item.dart';
import '../../theme/app_colors.dart';
import '../../core/capitalize.dart';

/// Bottom sheet with a searchable list of every Pokémon. Pops with the
/// chosen [PokemonListItem].
class PokemonPickerSheet extends StatefulWidget {
  const PokemonPickerSheet({super.key, required this.allPokemon});

  final List<PokemonListItem> allPokemon;

  @override
  State<PokemonPickerSheet> createState() => _PokemonPickerSheetState();
}

class _PokemonPickerSheetState extends State<PokemonPickerSheet> {
  String _query = '';

  List<PokemonListItem> get _filtered => _query.isEmpty
      ? widget.allPokemon
      : widget.allPokemon
            .where((p) => p.name.toLowerCase().contains(_query))
            .toList();

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (_, controller) => Column(
        children: [
          SizedBox(height: 8.h),
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: context.colors.border,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: TextField(
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: context.l10n.comparePickerHint,
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: context.colors.border),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 10.h),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Expanded(
            child: ListView.builder(
              controller: controller,
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewPaddingOf(context).bottom,
              ),
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final p = filtered[i];
                return ListTile(
                  title: Text(p.name.capitalize()),
                  onTap: () => Navigator.pop(context, p),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
