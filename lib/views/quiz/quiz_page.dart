import 'package:flutter/material.dart';
import '../../controllers/quiz_controller.dart';
import 'quiz_question_view.dart';
import 'quiz_results_view.dart';
import 'quiz_start_view.dart';

/// The Quiz tab: start screen → questions → results.
///
/// The game itself lives in [QuizController]; this page only chooses which
/// screen to show and keeps the countdown from running while the tab is hidden.
class QuizPage extends StatefulWidget {
  /// Pass a [controller] to drive the page from a test; otherwise the page
  /// creates (and disposes) its own.
  const QuizPage({super.key, this.controller});

  final QuizController? controller;

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late final QuizController _controller;
  bool _tabVisible = true;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? QuizController();
    _controller.init();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The shell keeps every tab alive; hidden tabs have tickers disabled.
    final visible = TickerMode.valuesOf(context).enabled;
    if (visible == _tabVisible) return;
    _tabVisible = visible;
    visible ? _controller.resume() : _controller.pause();
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) => switch (_controller.screen) {
            QuizScreen.start => QuizStartView(controller: _controller),
            QuizScreen.quiz => QuizQuestionView(controller: _controller),
            QuizScreen.results => QuizResultsView(controller: _controller),
          },
        ),
      ),
    );
  }
}
