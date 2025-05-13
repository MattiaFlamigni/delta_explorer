import 'package:delta_explorer/constants/quiz.dart';
import 'package:delta_explorer/quick_quiz/pages/review_answer.dart';
import 'package:delta_explorer/quiz/quizController.dart';
import 'package:flutter/material.dart';

import '../Model/quiz_model.dart';
import '../utils/utils.dart';
import '../widgets/action_button.dart';
import '../widgets/score_indicator.dart';
import '../widgets/stat_item.dart';

/// Widget that displays the summary of the quiz
class Score extends StatefulWidget {
  /// Quiz object containing all information about the quiz
  final Quiz quiz;

  /// Duration the quiz lasted
  final int duration;

  /// Callback function to retry the quiz
  final VoidCallback onRetry;

  /// Constructor
  const Score({
    super.key,
    required this.quiz,
    required this.duration,
    required this.onRetry,
  });

  @override
  State<Score> createState() => _ScoreState();
}

class _ScoreState extends State<Score> {
  QuizController controller = QuizController();

  @override
  void initState() {
    // TODO: implement initState
    print("salvando");
    super.initState();
    controller.saveResult(widget.quiz.totalAccuracy, widget.duration, widget.quiz.totalSkippedQuestions, widget.quiz.totalIncorrectAnswers, QuizConstant.totalQuestion-widget.quiz.totalIncorrectAnswers);
  }


  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF8360c3), Color(0xFF2ebf91)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 100, bottom: 20),
              child: Column(
                children: [
                  Text(
                    getFormattedDateTime(),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Quiz Summary",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                            color: Colors.black38,
                            offset: Offset(2, 2),
                            blurRadius: 4)
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(150, 150),
                        painter:
                            ScoreIndicator(accuracy: widget.quiz.totalAccuracy),
                      ),
                      Column(
                        children: [
                          Text(
                            "${widget.quiz.totalCorrectAnswers}",
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                    color: Colors.black54,
                                    offset: Offset(2, 2),
                                    blurRadius: 5)
                              ],
                            ),
                          ),
                          Text(
                            "Out of ${widget.quiz.totalQuestions}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      const Positioned(
                        bottom: 0,
                        child: Text(
                          "Score",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ScoreLabel(
                          icon: Icons.bar_chart,
                          label: "Accuracy",
                          value: "${widget.quiz.totalAccuracy}%"),
                      ScoreLabel(
                        icon: Icons.timer,
                        label: "Duration",
                        value: getformatTime(widget.duration),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ScoreLabel(
                          icon: Icons.remove_circle_outline,
                          label: "Skipped",
                          value: "${widget.quiz.totalSkippedQuestions}"),
                      ScoreLabel(
                          icon: Icons.cancel,
                          label: "Incorrect",
                          value: "${widget.quiz.totalIncorrectAnswers}"),
                    ],
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ActionButton(
                            icon: Icons.refresh,
                            label: "Retry Quiz",
                            onPressed: () {
                              widget.onRetry();
                              Navigator.pop(context);
                            }),
                        ActionButton(
                            icon: Icons.check,
                            label: "Review Answer",
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ReviewAnswer(quiz: widget.quiz),
                                ),
                              );
                            }),
                        ActionButton(
                            icon: Icons.home,
                            label: "Home",
                            onPressed: () {
                              Navigator.of(context)
                                  .popUntil((route) => route.isFirst);
                            }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
