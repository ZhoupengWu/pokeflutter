import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../model/pokemon_list_item.dart';
import '../model/pokemon.dart';
import '../model/quiz_model.dart';
import '../utils/pokemon_api.dart';
import '../utils/quiz_logic.dart';
import '../utils/capitalize.dart';
import '../utils/palette.dart';
import '../utils/pokemon_costants.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  // ── State ─────────────────────────────────────────────────────────────────
  List<PokemonListItem> _allPokemon = [];
  List<QuizQuestion> _questions = [];
  int _currentIndex = 0;
  int? _selectedOption; // index picked by user this round
  bool _answered = false;
  final QuizResult _result = QuizResult(totalQuestions: 10);

  // Per-question resolved data
  Pokemon? _currentPokemon;
  bool _loadingPokemon = true;

  // Screen state
  _Screen _screen = _Screen.start;

  @override
  void initState() {
    super.initState();
    _loadPokemonList();
  }

  // ── Data loading ──────────────────────────────────────────────────────────

  Future<void> _loadPokemonList() async {
    final jsonFile = await rootBundle.loadString('assets/pokemonList.json');
    final decoded = jsonDecode(jsonFile);
    final items = (decoded['pokemonList'] as List)
        .map((item) => PokemonListItem(name: item['name'], url: item['url']))
        .toList();
    if (!mounted) return;
    setState(() => _allPokemon = items);
  }

  Future<void> _startQuiz() async {
    final questions = QuizLogic.generateQuestions(_allPokemon, count: 10);
    setState(() {
      _questions = questions;
      _currentIndex = 0;
      _result.correct = 0;
      _result.answered = 0;
      _screen = _Screen.quiz;
    });
    await _loadCurrentPokemon();
  }

  Future<void> _loadCurrentPokemon() async {
    if (_currentIndex >= _questions.length) return;
    setState(() {
      _loadingPokemon = true;
      _currentPokemon = null;
      _answered = false;
      _selectedOption = null;
    });
    final pokemon = await PokemonApi.getPokemonDetails(
      _questions[_currentIndex].subject.name,
    );
    if (!mounted) return;
    setState(() {
      _currentPokemon = pokemon;
      _loadingPokemon = false;
    });
  }

  // ── Interaction ───────────────────────────────────────────────────────────

  void _onOptionTap(int index) {
    if (_answered) return;
    final question = _questions[_currentIndex];
    final isCorrect = index == question.correctIndex;

    setState(() {
      _selectedOption = index;
      _answered = true;
      _result.answered++;
      if (isCorrect) _result.correct++;
    });
  }

  Future<void> _nextQuestion() async {
    if (_currentIndex + 1 >= _questions.length) {
      setState(() => _screen = _Screen.results);
      return;
    }
    setState(() => _currentIndex++);
    await _loadCurrentPokemon();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: switch (_screen) {
          _Screen.start => _buildStart(),
          _Screen.quiz => _buildQuiz(),
          _Screen.results => _buildResults(),
        },
      ),
    );
  }

  // ── Start screen ──────────────────────────────────────────────────────────

  Widget _buildStart() {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quiz', style: textTheme.displaySmall),
          SizedBox(height: 8.h),
          Text(
            'Test your Pokémon knowledge!\n10 questions — guess the name from the sprite.',
            style: textTheme.bodyLarge?.copyWith(color: gray[400], height: 1.5),
          ),
          const Spacer(),
          Center(
            child: Icon(Icons.quiz_rounded, size: 96.r, color: gray[200]),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _allPokemon.isEmpty ? null : _startQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: gray[500],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                elevation: 0,
              ),
              child: Text(
                _allPokemon.isEmpty ? 'Loading…' : 'Start Quiz',
                style: textTheme.titleSmall?.copyWith(color: Colors.white),
              ),
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  // ── Quiz screen ───────────────────────────────────────────────────────────

  Widget _buildQuiz() {
    final question = _questions[_currentIndex];
    final textTheme = Theme.of(context).textTheme;

    // Background colour from Pokémon type (if loaded)
    final bgColor = _currentPokemon != null
        ? (listPokemonTypeColor[_currentPokemon!.typesList[0].toLowerCase()] ??
              gray[200]!)
        : gray[200]!;

    return Column(
      children: [
        // ── Progress bar + counter ─────────────────────────────────────────
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${_currentIndex + 1} / ${_questions.length}',
                    style: textTheme.bodySmall?.copyWith(color: gray[400]),
                  ),
                  Text(
                    '✓ ${_result.correct}   ✗ ${_result.wrong}',
                    style: textTheme.bodySmall?.copyWith(color: gray[400]),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: LinearProgressIndicator(
                  value: (_currentIndex + 1) / _questions.length,
                  minHeight: 6.h,
                  backgroundColor: gray[100],
                  valueColor: AlwaysStoppedAnimation<Color>(bgColor),
                ),
              ),
            ],
          ),
        ),

        // ── Sprite card ────────────────────────────────────────────────────
        Expanded(
          flex: 3,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: EdgeInsets.symmetric(horizontal: 24.w),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: _loadingPokemon || _currentPokemon == null
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : Center(
                    child: Image.network(
                      // Hide the image until answered for guessName mode
                      question.mode == QuizMode.guessName && !_answered
                          ? _currentPokemon!.urlSprite
                          : _currentPokemon!.urlImage,
                      height: 140.r,
                      width: 140.r,
                      fit: BoxFit.contain,
                      color: question.mode == QuizMode.guessName && !_answered
                          ? Colors.black
                          : null,
                      colorBlendMode: BlendMode.srcATop,
                    ),
                  ),
          ),
        ),

        SizedBox(height: 16.h),

        // ── Question label ─────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Text(
            question.mode == QuizMode.guessName
                ? 'Who is this Pokémon?'
                : 'What type is ${question.subject.name.capitalize()}?',
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
              children: List.generate(question.options.length, (i) {
                return _OptionButton(
                  label: question.options[i].capitalize(),
                  state: _optionState(i, question),
                  onTap: () => _onOptionTap(i),
                );
              }),
            ),
          ),
        ),

        // ── Next button ────────────────────────────────────────────────────
        if (_answered)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: bgColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _currentIndex + 1 >= _questions.length
                      ? 'See Results'
                      : 'Next Question',
                  style: textTheme.titleSmall?.copyWith(color: Colors.white),
                ),
              ),
            ),
          )
        else
          SizedBox(height: 60.h),
      ],
    );
  }

  _OptionState _optionState(int index, QuizQuestion question) {
    if (!_answered) return _OptionState.idle;
    if (index == question.correctIndex) return _OptionState.correct;
    if (index == _selectedOption) return _OptionState.wrong;
    return _OptionState.idle;
  }

  // ── Results screen ────────────────────────────────────────────────────────

  Widget _buildResults() {
    final textTheme = Theme.of(context).textTheme;
    final pct = (_result.accuracy * 100).round();

    Color scoreColor;
    String scoreLabel;
    if (pct >= 80) {
      scoreColor = const Color(0xFF38BF4B);
      scoreLabel = 'Pokémon Master! 🏆';
    } else if (pct >= 50) {
      scoreColor = const Color(0xFFFF9741);
      scoreLabel = 'Not bad, keep training!';
    } else {
      scoreColor = const Color(0xFFE0306A);
      scoreLabel = 'Keep studying the Pokédex!';
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Column(
        children: [
          Text('Results', style: textTheme.displaySmall),
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
                  '${_result.correct} / ${_result.totalQuestions}',
                  style: textTheme.bodyMedium?.copyWith(color: gray[400]),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            scoreLabel,
            style: textTheme.titleMedium?.copyWith(
              color: scoreColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StatPill(
                label: 'Correct',
                value: _result.correct,
                color: const Color(0xFF38BF4B),
              ),
              SizedBox(width: 12.w),
              _StatPill(
                label: 'Wrong',
                value: _result.wrong,
                color: const Color(0xFFE0306A),
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _startQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: gray[500],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'Play Again',
                style: textTheme.titleSmall?.copyWith(color: Colors.white),
              ),
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}

// ── Helper enums & widgets ────────────────────────────────────────────────────

enum _Screen { start, quiz, results }

enum _OptionState { idle, correct, wrong }

class _OptionButton extends StatelessWidget {
  final String label;
  final _OptionState state;
  final VoidCallback onTap;

  const _OptionButton({
    required this.label,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color border;
    final Color text;

    switch (state) {
      case _OptionState.correct:
        bg = const Color(0xFF38BF4B).withValues(alpha: 0.15);
        border = const Color(0xFF38BF4B);
        text = const Color(0xFF38BF4B);
      case _OptionState.wrong:
        bg = const Color(0xFFE0306A).withValues(alpha: 0.15);
        border = const Color(0xFFE0306A);
        text = const Color(0xFFE0306A);
      case _OptionState.idle:
        bg = gray[100]!;
        border = gray[200]!;
        text = gray[500]!;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: border, width: 1.5),
        ),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
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
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatPill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
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