import 'package:flutter/material.dart';

import '../Model/quiz_model.dart';

/// Stateless widget to display the review of the quiz
class ReviewAnswer extends StatelessWidget {
  /// Quiz object containing all information of quiz
  final Quiz quiz;

  /// Constructor
  const ReviewAnswer({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(top: 50.0, left: 16.0, right: 16.0),
              child: Row(
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  const Text(
                    "Review Answers",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.black,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: quiz.questions.length,
                itemBuilder: (context, index) {
                  final question = quiz.questions[index];
                  final userAnswerIndex = question.selectedAnswerIndex;
                  final correctAnswerIndex = question.correctAnswerIndex;

                  // Colors for answers text
                  final userAnswerColor = userAnswerIndex == correctAnswerIndex
                      ? Colors.greenAccent[700]
                      : Colors.redAccent[700];
                  const correctAnswerColor = Colors.blueAccent;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${index + 1}. ${question.question}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1D2671),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              userAnswerIndex != null
                                  ? "Your Answer: ${question.options[userAnswerIndex]}"
                                  : "You skipped this question",
                              style: TextStyle(color: userAnswerColor),
                            ),
                            Text(
                              "Correct Answer: ${question.options[correctAnswerIndex]}",
                              style: const TextStyle(color: correctAnswerColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
