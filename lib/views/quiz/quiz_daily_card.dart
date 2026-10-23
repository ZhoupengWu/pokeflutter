import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/quiz_controller.dart';
import '../../l10n/l10n_extensions.dart';
import '../../theme/app_colors.dart';
import '../../theme/shapes.dart';
import 'quiz_widgets.dart';

/// The daily challenge on the start screen: a button to play today's
/// questions, or today's result once played, with the streak of days.
class QuizDailyCard extends StatelessWidget {
  const QuizDailyCard({super.key, required this.controller});

  final QuizController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final done = controller.dailyDone;
    final daily = controller.daily;
    final streak = controller.dailyStreak;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: context.colors.fill,
        borderRadius: BorderRadius.circular(radiusCard.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.quizDailyTitle, style: textTheme.titleSmall),
          SizedBox(height: 4.h),
          Text(
            done
                ? l10n.quizDailyDone(
                    daily.correct,
                    daily.outcomes.length,
                    daily.score,
                  )
                : l10n.quizDailyHint,
            style: textTheme.bodySmall?.copyWith(color: context.colors.muted),
          ),
          if (streak > 0) ...[
            SizedBox(height: 4.h),
            Text(
              '🔥 ${l10n.quizDailyStreak(streak)}',
              style: textTheme.bodySmall?.copyWith(color: context.colors.muted),
            ),
          ],
          if (!done) ...[
            SizedBox(height: 12.h),
            QuizPrimaryButton(
              label: l10n.quizDailyPlay,
              onPressed: controller.canStartDaily
                  ? controller.startDaily
                  : null,
            ),
          ],
        ],
      ),
    );
  }
}
