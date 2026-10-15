import 'dart:math' as math;
import 'package:flutter/widgets.dart';

/// Widest a page's content gets; wider screens (tablets, landscape) centre it.
const double maxContentWidth = 720;

/// Largest short side, in dp, the layout scales up to. A phone is up to ~430 dp
/// wide; beyond that sizes stay put and the extra room is used by more grid
/// columns instead of by bigger controls.
const double _maxScaledShortSide = 480;

// Reference phone: designed for 360 × 979 and checked on 390 × 844. On it the
// vertical scale is this fraction of the horizontal one.
const _referenceScreen = Size(390, 844);
const _referenceDesign = Size(360, 979);
final double _heightToWidthScale =
    (_referenceScreen.height / _referenceDesign.height) /
    (_referenceScreen.width / _referenceDesign.width);

/// The `flutter_screenutil` design size to use on a [screen] of this size.
///
/// Reproduces the phone design (360 × 979) on a normal portrait phone, and
/// keeps the same on-screen proportions in landscape and on tablets: scale is
/// driven by the screen's short side, capped, rather than by its width alone
/// (which made landscape controls tiny and tablet controls huge).
Size designSizeFor(Size screen) {
  final shortSide = math.min(screen.width, screen.height);
  final scale =
      math.min(shortSide, _maxScaledShortSide) / _referenceDesign.width;
  return Size(
    screen.width / scale,
    screen.height / (scale * _heightToWidthScale),
  );
}

/// Centres [child] and limits its width to [maxWidth] ([maxContentWidth] by
/// default).
class ContentWidth extends StatelessWidget {
  const ContentWidth({
    super.key,
    required this.child,
    this.maxWidth = maxContentWidth,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    ),
  );
}

/// How much the system font size enlarges text (1 = normal, 2 = 200 %).
double textScaleOf(BuildContext context) =>
    MediaQuery.textScalerOf(context).scale(16) / 16;

/// [base] grown by [share] of the growth of text beyond 1×, for boxes of fixed
/// height that hold text. The growth counted stops at 2×, the largest size
/// Android offers.
double scaledByText(BuildContext context, double base, {double share = 0.5}) =>
    base * (1 + (textScaleOf(context) - 1).clamp(0.0, 1.0) * share);

/// Whether a page given [box] should lay its parts out side by side: it is
/// wide enough and clearly wider than tall (a phone or tablet held sideways).
bool sideBySide(BoxConstraints box) =>
    box.maxWidth >= 640 && box.maxWidth > box.maxHeight * 1.2;
