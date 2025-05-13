
import 'package:delta_explorer/quick_quiz/pages/score.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../Model/quiz_model.dart';
import '../utils/utils.dart';
import '../widgets/option_tile.dart';
import '../widgets/timer_indicator.dart';

class QuizPage extends StatefulWidget {
  /// Instance of quiz that holds all information
  final Quiz quiz;

  final Color primaryColor;

  /// Constructor
  const QuizPage(
      {super.key,
      required this.quiz,
      this.primaryColor = const Color(0xffDA3732)});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  /// Instance of timer to show countdown during the quiz
  late Timer _timer;

  /// Remaining time for the current quiz
  late int remainingTime;

  /// Instance that holds index of the current question being displayed
  int currentQuestionIndex = 0;

  /// Holds the selected option index for the current question being displayed
  int? selectedOption;

  /// Counter to track number of times user has retried the quiz
  int retryCount = 0;

  @override
  void initState() {
    super.initState();

    /// Initializing remaining time with quiz's total time limit
    remainingTime = widget.quiz.timerDuration!;

    /// Start the timer countdown
    startTimer();
  }

  @override
  void dispose() {
    /// Cancel timer when widget is removed
    _timer.cancel();
    super.dispose();
  }

  /// Reset quiz state to restart quiz from the start
  void resetQuiz() {
    /// Cancel current timer
    _timer.cancel();

    setState(() {
      /// Reset remaining time, currentQuestionIndex, selectedOption and increased retryCount
      remainingTime = widget.quiz.timerDuration!;
      currentQuestionIndex = 0;
      for (var item in widget.quiz.questions) {
        item.selectedAnswerIndex = null;
      }
      selectedOption = null;
      retryCount++;
    });

    /// Restart timer for new session
    startTimer();
  }

  /// Function that starts timer that decreases remaining time each second
  void startTimer() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (remainingTime > 0) {
          setState(() {
            remainingTime--;
          });
        } else {
          navigateToScore();
        }
      },
    );
  }

  /// Navigates to score page
  void navigateToScore() {
    _timer.cancel();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Score(
          quiz: widget.quiz,
          duration: (widget.quiz.timerDuration! - remainingTime),
          onRetry: resetQuiz,
        ),
      ),
    );
  }

  /// Displays next question or navigates to score page for last question
  void goToNextQuestion() {
    if (currentQuestionIndex < widget.quiz.questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedOption = null;
      });
    } else if (currentQuestionIndex == widget.quiz.questions.length - 1) {
      navigateToScore();
    }
  }

  @override
  Widget build(BuildContext context) {
    QuestionModel currentQuestion = widget.quiz.questions[currentQuestionIndex];
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${currentQuestionIndex + 1} of ${widget.quiz.questions.length}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                InkWell(
                  onTap: () {
                    goToNextQuestion();
                  },
                  child: const Text(
                    'Skip',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TimerIndicator(
              key: ValueKey(retryCount),
              totalTime: widget.quiz.timerDuration!.toDouble(),
              primaryColor: widget.primaryColor,
            ),
            const SizedBox(height: 4),
            Text(
              getformatTime(remainingTime),
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              currentQuestion.question,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: currentQuestion.options.length,
                itemBuilder: (context, index) {
                  return OptionTile(
                      optionText: currentQuestion.options[index],
                      isSelected: selectedOption == index,
                      onTap: () {
                        setState(() {
                          selectedOption = index;
                        });
                      },
                      serialNumber: "${index + 1}",
                      primaryColor: widget.primaryColor);
                },
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: selectedOption != null
                    ? () {
                        currentQuestion.selectedAnswerIndex = selectedOption;
                        goToNextQuestion();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  backgroundColor: widget.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text(
                  'Next',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
