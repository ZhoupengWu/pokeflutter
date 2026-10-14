import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/quiz_controller.dart';
import '../../l10n/l10n_extensions.dart';
import '../../model/quiz_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/capitalize.dart';
import '../../utils/pokemon_constants.dart';
import 'quiz_widgets.dart';

class QuizQuestionView extends StatelessWidget {
  const QuizQuestionView({super.key, required this.controller});

  final QuizController controller;

  OptionState _optionState(int index) {
    if (!controller.answered) return OptionState.idle;
    if (index == controller.question.correctIndex) return OptionState.correct;
    if (index == controller.selectedOption) return OptionState.wrong;
    return OptionState.idle;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final question = controller.question;
    final pokemon = controller.pokemon;

    // Accent colour from the Pokémon's first type (neutral until loaded).
    final accent = pokemon == null
        ? context.colors.border
        : listPokemonTypeColor[pokemon.typesList.first.toLowerCase()] ??
              context.colors.border;

    return Column(
      children: [
        _Header(controller: controller, accent: accent),

        // ── Sprite card ────────────────────────────────────────────────────
        Expanded(
          flex: 3,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: EdgeInsets.symmetric(horizontal: 24.w),
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: _SpriteCard(controller: controller),
          ),
        ),

        SizedBox(height: 16.h),

        // ── Question label ─────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Text(
            question.mode == QuizMode.guessName
                ? l10n.quizWhoIsThis
                : l10n.quizWhatType(question.subject.name.capitalize()),
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
        ),

        SizedBox(height: 12.h),

        // ── Answer options ─────────────────────────────────────────────────
        Expanded(
          flex: 4,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 8.w,
              mainAxisSpacing: 8.h,
              childAspectRatio: 2.8,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (var i = 0; i < question.options.length; i++)
                  QuizOptionButton(
                    label: question.mode == QuizMode.guessType
                        ? l10n.typeName(question.options[i])
                        : question.options[i].capitalize(),
                    state: _optionState(i),
                    onTap: () => controller.answer(i),
                  ),
              ],
            ),
          ),
        ),

        // ── Feedback + Next button ─────────────────────────────────────────
        SizedBox(
          height: 132, // room for verdict, 2-line reveal and the button
          child: controller.answered
              ? _Feedback(controller: controller, accent: accent)
              : null,
        ),
      ],
    );
  }
}

// ── Progress, score and timer ────────────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header({required this.controller, required this.accent});

  final QuizController controller;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final style = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: context.colors.muted);
    final result = controller.result;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.quizQuestionCounter(
                  controller.index + 1,
                  controller.questions.length,
                ),
                style: style,
              ),
              Text(
                [
                  if (result.streak >= 2)
                    '🔥 ${l10n.quizStreak(result.streak)}',
                  l10n.quizPoints(result.score),
                ].join('   '),
                style: style,
              ),
            ],
          ),
          SizedBox(height: 6.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: (controller.index + 1) / controller.questions.length,
              minHeight: 6.h,
              backgroundColor: context.colors.fill,
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
          if (controller.difficulty.isTimed) ...[
            SizedBox(height: 6.h),
            _TimerBar(controller: controller),
          ],
        ],
      ),
    );
  }
}

class _TimerBar extends StatelessWidget {
  const _TimerBar({required this.controller});

  final QuizController controller;

  @override
  Widget build(BuildContext context) {
    final total = controller.difficulty.secondsPerQuestion!;
    return ValueListenableBuilder<double>(
      valueListenable: controller.timeLeft,
      builder: (context, fraction, _) {
        final color = fraction > 0.5
            ? successGreen
            : fraction > 0.25
            ? const Color(0xFFFF9741)
            : dangerRed;
        return Semantics(
          label: context.l10n.quizTimeLeft((fraction * total).ceil()),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 4.h,
              backgroundColor: context.colors.fill,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        );
      },
    );
  }
}

// ── Sprite (silhouette until answered in "guess the name" questions) ─────────
class _SpriteCard extends StatelessWidget {
  const _SpriteCard({required this.controller});

  final QuizController controller;

  @override
  Widget build(BuildContext context) {
    final pokemon = controller.pokemon;

    if (controller.isLoadingPokemon) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    if (pokemon == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 40.r, color: Colors.white),
            SizedBox(height: 4.h),
            Text(
              context.l10n.quizLoadFailed,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white),
            ),
            TextButton(
              onPressed: controller.retry,
              child: Text(
                context.l10n.retry,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    final hidden =
        controller.question.mode == QuizMode.guessName && !controller.answered;
    return Center(
      child: Image.network(
        // The small sprite blacked out is the "silhouette".
        hidden ? pokemon.urlSprite : pokemon.urlImage,
        height: 140.r,
        width: 140.r,
        fit: BoxFit.contain,
        color: hidden ? Colors.black : null,
        colorBlendMode: BlendMode.srcATop,
        semanticLabel: hidden
            ? context.l10n.quizSilhouette
            : pokemon.name.capitalize(),
        errorBuilder: (_, _, _) =>
            Icon(Icons.catching_pokemon, size: 96.r, color: Colors.white38),
      ),
    );
  }
}

// ── Result of the answer and the Next button ─────────────────────────────────
class _Feedback extends StatelessWidget {
  const _Feedback({required this.controller, required this.accent});

  final QuizController controller;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final question = controller.question;
    final pokemon = controller.pokemon!;
    final correct = controller.selectedOption == question.correctIndex;

    final verdict = controller.timedOut
        ? l10n.quizTimeUp
        : correct
        ? l10n.quizCorrect(controller.lastPoints)
        : l10n.quizWrong;
    final name = pokemon.name.capitalize();
    final reveal = question.mode == QuizMode.guessName
        ? l10n.quizAnswerName(name)
        : l10n.quizAnswerTypes(name, l10n.typeList(pokemon.typesList));

    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 4.h, 24.w, 8.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Semantics(
            liveRegion: true,
            child: Text(
              verdict,
              style: textTheme.titleSmall?.copyWith(
                color: correct ? successGreen : dangerRed,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            reveal,
            style: textTheme.bodySmall?.copyWith(color: context.colors.muted),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8.h),
          QuizPrimaryButton(
            label: controller.isLastQuestion
                ? l10n.quizSeeResults
                : l10n.quizNext,
            onPressed: controller.next,
            color: accent,
            verticalPadding: 12.h,
          ),
        ],
      ),
    );
  }
}
