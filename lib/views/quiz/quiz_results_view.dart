import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../controllers/quiz_controller.dart';
import '../../data/quiz_stats_store.dart';
import '../../data/share_service.dart';
import '../../l10n/l10n_extensions.dart';
import '../../theme/app_colors.dart';
import '../../theme/responsive.dart';
import 'quiz_widgets.dart';

class QuizResultsView extends StatelessWidget {
  const QuizResultsView({super.key, required this.controller});

  final QuizController controller;

  /// The text the Share button hands to the system: what was played, the
  /// score and one square per question (green right, red wrong).
  String shareText(BuildContext context) {
    final l10n = context.l10n;
    final result = controller.result;
    final grid = result.outcomes.map((ok) => ok ? '🟩' : '🟥').join();
    return controller.isDaily
        ? l10n.quizShareDaily(
            QuizStatsStore.dateKey(controller.dailyDate),
            result.correct,
            result.totalQuestions,
            result.score,
            grid,
          )
        : l10n.quizShareGame(
            difficultyName(l10n, controller.gameDifficulty),
            result.correct,
            result.totalQuestions,
            result.score,
            grid,
          );
  }

  Future<void> _share(BuildContext context) async {
    final share = context.read<ShareService>();
    final text = shareText(context);
    try {
      await share.shareText(text);
    } catch (_) {
      // No share sheet available (or it failed): nothing else to offer.
    }
  }

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

    // Scrolls when the content outgrows the screen (large font, landscape).
    return LayoutBuilder(
      builder: (context, box) => SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: box.maxHeight - 32.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                controller.isDaily ? l10n.quizDailyTitle : l10n.quizResults,
                style: textTheme.displaySmall,
              ),
              SizedBox(height: 16.h),
              // Score circle
              Container(
                width: scaledByText(context, 160.r, share: 0.8),
                height: scaledByText(context, 160.r, share: 0.8),
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
              SizedBox(height: 16.h),
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
              if (controller.isDaily && controller.dailyStreak > 0) ...[
                SizedBox(height: 4.h),
                Text(
                  '🔥 ${l10n.quizDailyStreak(controller.dailyStreak)}',
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
              SizedBox(height: 24.h),
              QuizPrimaryButton(
                label: l10n.quizShare,
                onPressed: () => _share(context),
              ),
              SizedBox(height: 8.h),
              if (!controller.isDaily)
                TextButton(
                  onPressed: controller.start,
                  child: Text(l10n.quizPlayAgain),
                ),
              TextButton(
                onPressed: controller.backToStart,
                child: Text(
                  controller.isDaily ? l10n.back : l10n.quizChangeDifficulty,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
