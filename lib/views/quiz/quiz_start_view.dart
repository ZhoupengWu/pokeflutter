import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/quiz_controller.dart';
import '../../l10n/l10n_extensions.dart';
import '../../model/quiz_model.dart';
import '../../utils/app_colors.dart';
import 'quiz_widgets.dart';

class QuizStartView extends StatelessWidget {
  const QuizStartView({super.key, required this.controller});

  final QuizController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final difficulty = controller.difficulty;
    final record = controller.record;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Column(
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
          const Spacer(),
          Center(
            child: ExcludeSemantics(
              child: Icon(
                Icons.quiz_rounded,
                size: 96.r,
                color: context.colors.border,
              ),
            ),
          ),
          const Spacer(),
          QuizPrimaryButton(
            label: controller.isLoadingList ? l10n.quizLoading : l10n.quizStart,
            onPressed: controller.canStart ? controller.start : null,
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}
