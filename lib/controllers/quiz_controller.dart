import 'dart:async';
import 'package:flutter/foundation.dart';
import '../model/pokemon.dart';
import '../model/pokemon_list_item.dart';
import '../model/quiz_model.dart';
import '../utils/pokemon_api.dart';
import '../utils/pokemon_repository.dart';
import '../utils/quiz_logic.dart';
import '../utils/quiz_stats_store.dart';

enum QuizScreen { start, quiz, results }

/// State and rules of a quiz game; the page only renders it.
///
/// Flow: [init] → choose [difficulty] → [start] → for each question
/// [answer] (or the timer runs out) → [next] → results, where the game is
/// saved to the [QuizStatsStore].
class QuizController extends ChangeNotifier {
  QuizController({
    PokemonApi? api,
    PokemonRepository? repository,
    QuizStatsStore? stats,
    this.questionCount = 10,
    this.tick = const Duration(milliseconds: 100),
  }) : _api = api ?? PokemonApi.instance,
       _repository = repository ?? PokemonRepository.instance,
       _stats = stats ?? QuizStatsStore.instance;

  final PokemonApi _api;
  final PokemonRepository _repository;
  final QuizStatsStore _stats;
  final int questionCount;

  /// Resolution of the countdown. Tests may use a coarser one.
  final Duration tick;

  // ── State ─────────────────────────────────────────────────────────────────

  QuizScreen screen = QuizScreen.start;
  QuizDifficulty difficulty = QuizDifficulty.normal;
  List<PokemonListItem> allPokemon = const [];
  Map<QuizDifficulty, QuizRecord> records = {
    for (final d in QuizDifficulty.values) d: const QuizRecord(),
  };

  List<QuizQuestion> questions = [];
  int index = 0;
  late QuizResult result = QuizResult(totalQuestions: questionCount);

  /// Details of the current question's subject (null while loading/failed).
  Pokemon? pokemon;
  bool isLoadingPokemon = true;

  /// Option picked this round (null when none, e.g. the time ran out).
  int? selectedOption;
  bool answered = false;
  bool timedOut = false;

  /// Points earned by the last answer.
  int lastPoints = 0;

  /// True on the results screen when this game beat the saved best score.
  bool isNewRecord = false;

  /// Fraction of the question time left (1 → 0); 1 when untimed.
  final ValueNotifier<double> timeLeft = ValueNotifier(1);

  Timer? _timer;
  int _remainingMs = 0;
  int _epoch = 0; // invalidates loads that finish after a restart

  // ── Derived ───────────────────────────────────────────────────────────────

  QuizQuestion get question => questions[index];

  bool get isLastQuestion => index + 1 >= questions.length;

  /// Whether the user can answer right now.
  bool get canAnswer =>
      screen == QuizScreen.quiz &&
      !answered &&
      !isLoadingPokemon &&
      pokemon != null &&
      question.isResolved;

  QuizRecord get record => records[difficulty]!;

  bool get canStart =>
      allPokemon.where(difficulty.includes).length >= 4 && !isLoadingList;

  bool isLoadingList = true;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  /// Loads the Pokémon list and the saved records.
  Future<void> init() async {
    final list = await _repository.getAll();
    Map<QuizDifficulty, QuizRecord>? saved;
    try {
      saved = await _stats.load();
    } catch (_) {
      saved = null; // records are a nicety; play without them
    }
    allPokemon = list;
    if (saved != null) records = saved;
    isLoadingList = false;
    notifyListeners();
  }

  void setDifficulty(QuizDifficulty value) {
    if (value == difficulty) return;
    difficulty = value;
    notifyListeners();
  }

  Future<void> start() async {
    final generated = QuizLogic.generateQuestions(
      allPokemon,
      count: questionCount,
      difficulty: difficulty,
    );
    if (generated.isEmpty) return;
    _stopTimer();
    questions = generated;
    index = 0;
    result = QuizResult(totalQuestions: generated.length);
    isNewRecord = false;
    screen = QuizScreen.quiz;
    await _loadCurrent();
  }

  /// Loads the details of the current question (also the Retry action).
  Future<void> retry() => _loadCurrent();

  Future<void> _loadCurrent() async {
    final epoch = ++_epoch;
    _stopTimer();
    isLoadingPokemon = true;
    pokemon = null;
    answered = false;
    timedOut = false;
    selectedOption = null;
    lastPoints = 0;
    timeLeft.value = 1;
    notifyListeners();

    final questionIndex = index;
    Pokemon? loaded;
    try {
      loaded = await _api.getPokemonDetails(
        questions[questionIndex].subject.name,
      );
    } on PokemonApiException {
      loaded = null; // the page offers Retry
    }
    if (epoch != _epoch) return;

    pokemon = loaded;
    isLoadingPokemon = false;
    final current = questions[questionIndex];
    if (loaded != null &&
        current.mode == QuizMode.guessType &&
        !current.isResolved) {
      // Type questions get their options from the real types.
      questions[questionIndex] = QuizLogic.resolveTypeQuestion(
        current,
        loaded.typesList,
      );
    }
    notifyListeners();
    if (canAnswer) _startTimer(fresh: true);
  }

  // ── Interaction ───────────────────────────────────────────────────────────

  void answer(int option) {
    if (!canAnswer) return;
    _finishQuestion(option, timedOut: false);
  }

  void _finishQuestion(int? option, {required bool timedOut}) {
    _stopTimer();
    selectedOption = option;
    answered = true;
    this.timedOut = timedOut;
    lastPoints = result.record(isCorrect: option == question.correctIndex);
    notifyListeners();
  }

  Future<void> next() async {
    if (!answered) return;
    if (isLastQuestion) {
      await _finishGame();
      return;
    }
    index++;
    await _loadCurrent();
  }

  Future<void> _finishGame() async {
    _epoch++;
    try {
      isNewRecord = await _stats.submit(difficulty, result);
      records = await _stats.load();
    } catch (_) {
      isNewRecord = false; // storage problems must not block the results
    }
    screen = QuizScreen.results;
    notifyListeners();
  }

  void backToStart() {
    _epoch++;
    _stopTimer();
    screen = QuizScreen.start;
    notifyListeners();
  }

  // ── Countdown ─────────────────────────────────────────────────────────────

  /// Stops the countdown while the quiz is not on screen.
  void pause() => _stopTimer();

  /// Continues the countdown after [pause].
  void resume() {
    if (canAnswer && _remainingMs > 0) _startTimer(fresh: false);
  }

  void _startTimer({required bool fresh}) {
    final seconds = difficulty.secondsPerQuestion;
    if (seconds == null) return;
    _stopTimer();
    if (fresh) _remainingMs = seconds * 1000;
    _timer = Timer.periodic(tick, (_) {
      _remainingMs -= tick.inMilliseconds;
      if (_remainingMs <= 0) {
        _remainingMs = 0;
        timeLeft.value = 0;
        _finishQuestion(null, timedOut: true);
      } else {
        timeLeft.value = _remainingMs / (seconds * 1000);
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _epoch++;
    _stopTimer();
    timeLeft.dispose();
    super.dispose();
  }
}
