import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/palette.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

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

  Widget _filterButton() => Container(
    height: 48.r,
    width: 48.r,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16.r),
      color: gray[200],
    ),
    alignment: Alignment.center,
    child: Icon(Icons.filter_alt_rounded, size: 24.r),
  );

  Widget _searchBar(BuildContext context) => Container(
    // Let the container size itself to its content — no fixed .h height
    // that fights with the font scaling.
    decoration: BoxDecoration(
      border: Border.all(width: 1.w, color: gray[200]!),
      borderRadius: BorderRadius.circular(16.r),
    ),
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.search_rounded, size: 24.r),
        SizedBox(width: 8.w),
        Text(
          'Search a pokémon',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: gray[300]),
        ),
      ],
    ),
  );
}