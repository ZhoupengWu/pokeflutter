import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/l10n_extensions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_colors.dart';
import '../../data/favourites_manager.dart';
import '../shared/grid_item.dart';

class FavouritePage extends StatelessWidget {
  const FavouritePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.only(left: 24.w, right: 24.w, bottom: 4.h),
              child: Text(
                context.l10n.favouritesTitle,
                style: textTheme.displaySmall,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                context.l10n.favouritesSubtitle,
                style: textTheme.bodyLarge?.copyWith(
                  color: context.colors.muted,
                  height: 1.5,
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: context.read<FavouritesManager>().notifier,
                builder: (context, favourites, _) {
                  if (favourites.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.favorite_border_rounded,
                            size: 64.r,
                            color: context.colors.border,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            context.l10n.favouritesEmptyTitle,
                            style: textTheme.titleMedium?.copyWith(
                              color: context.colors.subtle,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            context.l10n.favouritesEmptyHint,
                            style: textTheme.bodySmall?.copyWith(
                              color: context.colors.subtle,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: GridView.builder(
                      clipBehavior: Clip.hardEdge,
                      itemCount: favourites.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8.w,
                        mainAxisSpacing: 8.h,
                        mainAxisExtent: 100.h,
                      ),
                      itemBuilder: (_, index) => GridItem(
                        key: ValueKey(favourites[index].name),
                        pokemon: favourites[index],
                        heroScope: 'favourites',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
