import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/quiz_controller.dart';
import '../../l10n/l10n_extensions.dart';
import '../../model/quiz_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/responsive.dart';
import 'quiz_widgets.dart';

class QuizStartView extends StatelessWidget {
  const QuizStartView({super.key, required this.controller});

  final QuizController controller;

  @override
  Widget build(BuildContext context) {
    // Scrolls when the content outgrows the screen (large system font).
    return LayoutBuilder(
      builder: (context, box) {
        final minHeight = box.maxHeight - 32.h;
        final start = QuizPrimaryButton(
          label: controller.isLoadingList
              ? context.l10n.quizLoading
              : context.l10n.quizStart,
          onPressed: controller.canStart ? controller.start : null,
        );
        final icon = Center(
          child: ExcludeSemantics(
            child: Icon(
              Icons.quiz_rounded,
              size: 96.r,
              color: context.colors.border,
            ),
          ),
        );

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: sideBySide(box)
              // Sideways: the setup on the left, the icon and Start on the right.
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _intro(context)),
                    SizedBox(width: 24.w),
                    Expanded(
                      child: SizedBox(
                        height: minHeight,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            icon,
                            SizedBox(height: 16.h),
                            start,
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              // Upright: the three groups spread over the full height.
              : ConstrainedBox(
                  constraints: BoxConstraints(minHeight: minHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _intro(context),
                      SizedBox(height: 16.h),
                      icon,
                      SizedBox(height: 16.h),
                      start,
                    ],
                  ),
                ),
        );
      },
    );
  }

  /// Title, intro, difficulty picker and best score.
  Widget _intro(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final difficulty = controller.difficulty;
    final record = controller.record;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.quizTitle, style: textTheme.displaySmall),
        SizedBox(height: 8.h),
        Text(
          l10n.quizIntro,
          style: textTheme.bodyLarge?.copyWith(
            color: context.colors.muted,
            height: 1.5,
          ),
        ),
        SizedBox(height: 24.h),
        Text(l10n.quizDifficulty, style: textTheme.titleSmall),
        SizedBox(height: 8.h),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<QuizDifficulty>(
            showSelectedIcon: false,
            segments: [
              for (final d in QuizDifficulty.values)
                ButtonSegment(value: d, label: Text(difficultyName(l10n, d))),
            ],
            selected: {difficulty},
            onSelectionChanged: (values) =>
                controller.setDifficulty(values.first),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          difficultyHint(l10n, difficulty),
          style: textTheme.bodySmall?.copyWith(color: context.colors.muted),
        ),
        SizedBox(height: 4.h),
        Text(
          record.gamesPlayed == 0
              ? l10n.quizNoBestScore
              : l10n.quizBestScore(record.bestScore),
          style: textTheme.bodySmall?.copyWith(color: context.colors.subtle),
        ),
      ],
    );
  }
}
