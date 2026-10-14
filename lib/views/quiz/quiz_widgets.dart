import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../l10n/l10n_extensions.dart';
import '../../model/quiz_model.dart';
import '../../utils/app_colors.dart';

/// Green used for correct answers and good scores.
const quizGreen = Color(0xFF38BF4B);

/// Red used for wrong answers and low scores.
const quizRed = Color(0xFFE0306A);

String difficultyName(AppLocalizations l10n, QuizDifficulty difficulty) =>
    switch (difficulty) {
      QuizDifficulty.easy => l10n.difficultyEasy,
      QuizDifficulty.normal => l10n.difficultyNormal,
      QuizDifficulty.hard => l10n.difficultyHard,
    };

String difficultyHint(AppLocalizations l10n, QuizDifficulty difficulty) {
  final seconds = difficulty.secondsPerQuestion;
  return seconds == null
      ? l10n.difficultyEasyHint
      : l10n.difficultyTimedHint(seconds);
}

/// Full-width rounded button in the app's main accent colour.
class QuizPrimaryButton extends StatelessWidget {
  const QuizPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
    this.verticalPadding,
  });

  final String label;
  final VoidCallback? onPressed;

  /// Background; defaults to the theme's strong colour.
  final Color? color;
  final double? verticalPadding;

  @override
  Widget build(BuildContext context) {
    final background = color ?? context.colors.strong;
    // White on a type colour, the theme's contrast colour on the accent.
    final foreground = color == null ? context.colors.onStrong : Colors.white;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          padding: EdgeInsets.symmetric(vertical: verticalPadding ?? 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(color: foreground),
        ),
      ),
    );
  }
}

enum OptionState { idle, correct, wrong }

/// One answer of a question. A real button for screen readers: it announces
/// whether the answer was right or wrong once the question is answered.
class QuizOptionButton extends StatelessWidget {
  const QuizOptionButton({
    super.key,
    required this.label,
    required this.state,
    required this.onTap,
  });

  final String label;
  final OptionState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final Color fill;
    final Color border;
    final Color text;
    switch (state) {
      case OptionState.correct:
        fill = quizGreen.withValues(alpha: 0.15);
        border = text = quizGreen;
      case OptionState.wrong:
        fill = quizRed.withValues(alpha: 0.15);
        border = text = quizRed;
      case OptionState.idle:
        fill = colors.fill;
        border = colors.border;
        text = colors.strong;
    }

    final semanticsLabel = switch (state) {
      OptionState.correct => context.l10n.quizOptionCorrect(label),
      OptionState.wrong => context.l10n.quizOptionWrong(label),
      OptionState.idle => label,
    };

    return Semantics(
      button: true,
      label: semanticsLabel,
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: fill,
        animationDuration: const Duration(milliseconds: 200),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: BorderSide(color: border, width: 1.5),
        ),
        child: InkWell(
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Center(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: text,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A coloured number with a caption (results screen).
class QuizStatPill extends StatelessWidget {
  const QuizStatPill({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value.toString(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
