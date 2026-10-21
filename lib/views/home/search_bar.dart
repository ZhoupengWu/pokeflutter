import 'package:flutter/material.dart';
import '../../l10n/l10n_extensions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_colors.dart';
import '../../theme/shapes.dart';

class SearchBarWidget extends StatefulWidget {
  final ValueChanged<String> onSearch;
  final VoidCallback? onFilterTap;
  final int activeFilterCount;

  const SearchBarWidget({
    super.key,
    required this.onSearch,
    this.onFilterTap,
    this.activeFilterCount = 0,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _controller.clear();
    widget.onSearch('');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: _searchBar(context)),
          SizedBox(width: 8.w),
          _filterButton(),
        ],
      ),
    );
  }

  Widget _filterButton() {
    final hasActive = widget.activeFilterCount > 0;

    return Semantics(
      button: true,
      label: hasActive
          ? context.l10n.filterByTypeSelected(widget.activeFilterCount)
          : context.l10n.filterByType,
      excludeSemantics: true,
      onTap: widget.onFilterTap,
      child: GestureDetector(
        onTap: widget.onFilterTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 48.r,
              width: 48.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hasActive ? context.colors.strong : context.colors.fill,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.filter_alt_rounded,
                size: 24.r,
                color: hasActive
                    ? context.colors.onStrong
                    : context.colors.muted,
              ),
            ),
            if (hasActive)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: EdgeInsets.all(4.r),
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${widget.activeFilterCount}',
                    style: TextStyle(
                      fontSize: 9.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _searchBar(BuildContext context) => Container(
    // A filled field without an outline, as in iOS.
    decoration: BoxDecoration(
      color: context.colors.fill,
      borderRadius: BorderRadius.circular(radiusControl.r),
    ),
    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.search_rounded, size: 24.r, color: context.colors.subtle),
        SizedBox(width: 8.w),
        Expanded(
          child: TextField(
            controller: _controller,
            onChanged: widget.onSearch,
            // On phones a tap elsewhere (a Pokémon, the background) does not
            // drop the focus by itself, so the cursor would stay in the field
            // while browsing and after coming back from a detail page.
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: context.colors.strong),
            decoration: InputDecoration(
              hintText: context.l10n.searchHint,
              hintStyle: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: context.colors.subtle),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8.h),
            ),
          ),
        ),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (_, value, _) {
            if (value.text.isEmpty) return const SizedBox.shrink();
            return Semantics(
              button: true,
              label: context.l10n.clearSearch,
              excludeSemantics: true,
              onTap: _clearSearch,
              child: GestureDetector(
                onTap: _clearSearch,
                child: Icon(
                  Icons.close_rounded,
                  size: 20.r,
                  color: context.colors.subtle,
                ),
              ),
            );
          },
        ),
      ],
    ),
  );
}
