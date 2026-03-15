import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/palette.dart';
import '../utils/favourites_manager.dart';
import 'widgets/grid_item.dart';

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
              child: Text('Favourites', style: textTheme.displaySmall),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                "Pokémon you've saved for quick access.",
                style: textTheme.bodyLarge?.copyWith(
                  color: gray[400],
                  height: 1.5,
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: FavouritesManager.instance.notifier,
                builder: (context, favourites, _) {
                  if (favourites.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.favorite_border_rounded,
                            size: 64.r,
                            color: gray[200],
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'No favourites yet',
                            style: textTheme.titleMedium?.copyWith(
                              color: gray[300],
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Tap the ♥ on any Pokémon to save it here.',
                            style: textTheme.bodySmall?.copyWith(
                              color: gray[300],
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
                      itemBuilder: (_, index) =>
                          GridItem(pokemon: favourites[index]),
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