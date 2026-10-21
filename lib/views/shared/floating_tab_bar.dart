import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_colors.dart';
import '../../theme/shapes.dart';

/// One tab of the [FloatingTabBar].
class FloatingTabItem {
  const FloatingTabItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// A tab bar that floats above the content as a frosted pill, instead of a
/// bar fixed to the bottom of the screen: translucent, blurred, with a soft
/// shadow and a capsule behind the current tab.
///
/// Use it as the `bottomNavigationBar` of a `Scaffold` with `extendBody: true`
/// so the content scrolls underneath it and learns its height from
/// `MediaQuery.padding.bottom`.
class FloatingTabBar extends StatelessWidget {
  const FloatingTabBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<FloatingTabItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  /// Widest the pill gets on a tablet or a phone held sideways.
  static const maxWidth = 460.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final inset = MediaQuery.viewPaddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h + inset),
      child: Align(
        alignment: Alignment.bottomCenter,
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxWidth),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radiusPill),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: dark ? 0.45 : 0.14),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radiusPill),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.surface.withValues(alpha: 0.78),
                    borderRadius: BorderRadius.circular(radiusPill),
                    border: Border.all(
                      color: colors.border.withValues(alpha: 0.7),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(5.r),
                    // The labels are short and the pill is narrow: they follow
                    // the system font size, up to a point.
                    child: MediaQuery.withClampedTextScaling(
                      maxScaleFactor: 1.25,
                      child: Row(
                        children: [
                          for (final (i, item) in items.indexed)
                            Expanded(
                              child: _TabButton(
                                item: item,
                                selected: i == currentIndex,
                                onTap: () {
                                  if (i != currentIndex) {
                                    HapticFeedback.selectionClick();
                                  }
                                  onTap(i);
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final FloatingTabItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = selected ? colors.strong : colors.subtle;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(vertical: 7.h, horizontal: 2.w),
          decoration: BoxDecoration(
            color: selected
                ? colors.strong.withValues(alpha: 0.09)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(radiusPill),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? item.selectedIcon : item.icon,
                size: 24.r,
                color: color,
              ),
              SizedBox(height: 2.h),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontSize: 10.5.sp,
                  letterSpacing: 0,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
