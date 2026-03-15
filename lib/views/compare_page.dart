import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/palette.dart';

class ComparePage extends StatelessWidget {
  const ComparePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Compare', style: textTheme.displaySmall),
              SizedBox(height: 8.h),
              Text(
                'Select two Pokémon to compare their stats side by side.',
                style: textTheme.bodyLarge?.copyWith(
                  color: gray[400],
                  height: 1.5,
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.compare_arrows_rounded,
                        size: 64.r,
                        color: gray[200],
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Coming soon',
                        style: textTheme.titleMedium?.copyWith(
                          color: gray[300],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}