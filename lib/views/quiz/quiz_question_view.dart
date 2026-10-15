import 'package:flutter/material.dart';
import '../shared/pokemon_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/quiz_controller.dart';
import '../../l10n/l10n_extensions.dart';
import '../../model/quiz_model.dart';
import '../../theme/app_colors.dart';
import '../../core/capitalize.dart';
import '../../core/pokemon_constants.dart';
import '../../theme/responsive.dart';
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
    final pokemon = controller.pokemon;

    // Accent colour from the Pokémon's first type (neutral until loaded).
    final accent = pokemon == null
        ? context.colors.border
        : listPokemonTypeColor[pokemon.typesList.first.toLowerCase()] ??
              context.colors.border;

    return LayoutBuilder(
      builder: (context, box) =>
          sideBySide(box) ? _wide(context, accent) : _narrow(context, accent),
    );
  }

  /// The sprite card takes the space the other parts leave. When they do not
  /// fit (a small screen with a large system font) the page scrolls and the
  /// card keeps a minimum height.
  Widget _narrow(BuildContext context, Color accent) {
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
            children: [
              _Header(controller: controller, accent: accent),
              Expanded(child: _card(accent)),
              SizedBox(height: 16.h),
              _label(context),
              SizedBox(height: 12.h),
              _options(context),
              _feedbackArea(context, accent),
            ],
          ),
        ),
      ],
    );
  }

  /// Sideways: the sprite on the left, question, options and feedback on the
  /// right.
  Widget _wide(BuildContext context, Color accent) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _Header(controller: controller, accent: accent),
              Expanded(child: _card(accent)),
              SizedBox(height: 16.h),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 16.h),
                _label(context),
                SizedBox(height: 12.h),
                _options(context),
                _feedbackArea(context, accent),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _card(Color accent) => ConstrainedBox(
    constraints: BoxConstraints(minHeight: 160.h),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: _SpriteCard(controller: controller),
    ),
  );

  Widget _label(BuildContext context) {
    final l10n = context.l10n;
    final question = controller.question;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Text(
        question.mode == QuizMode.guessName
            ? l10n.quizWhoIsThis
            : l10n.quizWhatType(question.subject.name.capitalize()),
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Answer options, two per row.
  Widget _options(BuildContext context) {
    final l10n = context.l10n;
    final question = controller.question;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          for (var row = 0; row < question.options.length; row += 2) ...[
            if (row > 0) SizedBox(height: 8.h),
            SizedBox(
              height: scaledByText(context, 60),
              child: Row(
                children: [
                  for (var i = row; i < row + 2; i++) ...[
                    if (i > row) SizedBox(width: 8.w),
                    Expanded(
                      child: i < question.options.length
                          ? QuizOptionButton(
                              label: question.mode == QuizMode.guessType
                                  ? l10n.typeName(question.options[i])
                                  : question.options[i].capitalize(),
                              state: _optionState(i),
                              onTap: () => controller.answer(i),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Verdict, reveal and Next button, once answered.
  Widget _feedbackArea(BuildContext context, Color accent) => SizedBox(
    // Room for the verdict, a 2-line reveal and the button.
    height: scaledByText(context, 132, share: 0.8),
    child: controller.answered
        ? _Feedback(controller: controller, accent: accent)
        : null,
  );
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
    // A square that fills the card within reason. No LayoutBuilder here: the
    // page measures its content when it has to scroll.
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 240, maxHeight: 240),
        child: AspectRatio(
          aspectRatio: 1,
          child: Padding(
            padding: EdgeInsets.all(12.r),
            child: PokemonImage(
              // The small sprite blacked out is the "silhouette".
              hidden ? pokemon.urlSprite : pokemon.urlImage,
              fit: BoxFit.contain,
              color: hidden ? Colors.black : null,
              colorBlendMode: BlendMode.srcATop,
              semanticLabel: hidden
                  ? context.l10n.quizSilhouette
                  : pokemon.name.capitalize(),
              errorBuilder: (_, _, _) => Icon(
                Icons.catching_pokemon,
                size: 96.r,
                color: Colors.white38,
              ),
            ),
          ),
        ),
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
