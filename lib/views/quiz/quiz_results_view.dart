import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/quiz_controller.dart';
import '../../l10n/l10n_extensions.dart';
import '../../theme/app_colors.dart';
import 'quiz_widgets.dart';

class QuizResultsView extends StatelessWidget {
  const QuizResultsView({super.key, required this.controller});

  final QuizController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final result = controller.result;
    final pct = (result.accuracy * 100).round();

    final Color scoreColor;
    final String verdict;
    if (pct >= 80) {
      scoreColor = successGreen;
      verdict = l10n.quizVerdictMaster;
    } else if (pct >= 50) {
      scoreColor = const Color(0xFFFF9741);
      verdict = l10n.quizVerdictOk;
    } else {
      scoreColor = dangerRed;
      verdict = l10n.quizVerdictLow;
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Column(
        children: [
          Text(l10n.quizResults, style: textTheme.displaySmall),
          const Spacer(),
          // Score circle
          Container(
            width: 160.r,
            height: 160.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scoreColor.withValues(alpha: 0.1),
              border: Border.all(color: scoreColor, width: 4),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$pct%',
                  style: textTheme.displaySmall?.copyWith(
                    color: scoreColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${result.correct} / ${result.totalQuestions}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: context.colors.muted,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            verdict,
            style: textTheme.titleMedium?.copyWith(
              color: scoreColor,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          if (controller.isNewRecord) ...[
            SizedBox(height: 4.h),
            Text(
              l10n.quizNewRecord,
              style: textTheme.titleSmall?.copyWith(
                color: const Color(0xFFFF9741),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          SizedBox(height: 16.h),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              QuizStatPill(
                label: l10n.quizCorrectLabel,
                value: result.correct,
                color: successGreen,
              ),
              QuizStatPill(
                label: l10n.quizWrongLabel,
                value: result.wrong,
                color: dangerRed,
              ),
              QuizStatPill(
                label: l10n.quizScoreLabel,
                value: result.score,
                color: context.colors.muted,
              ),
              QuizStatPill(
                label: l10n.quizBestStreakLabel,
                value: result.bestStreak,
                color: const Color(0xFFFF9741),
              ),
            ],
          ),
          const Spacer(),
          QuizPrimaryButton(
            label: l10n.quizPlayAgain,
            onPressed: controller.start,
          ),
          TextButton(
            onPressed: controller.backToStart,
            child: Text(l10n.quizChangeDifficulty),
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }
}
