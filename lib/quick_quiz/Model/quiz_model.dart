class Quiz {
  /// List of questions in the quiz
  final List<QuestionModel> questions;

  ///Timer duration in seconds, default is 120 seconds
  int? timerDuration = 120;

  /// Constructor
  Quiz({
    required this.questions,
    this.timerDuration,
  });

  /// Getter for total number of questions
  int get totalQuestions => questions.length;

  /// Calculates the total number of skipped questions
  int get totalSkippedQuestions {
    return questions
        .where((question) => question.selectedAnswerIndex == null)
        .length;
  }

  /// Calculates the total number of correct answers
  int get totalCorrectAnswers {
    return questions
        .where((question) =>
            question.selectedAnswerIndex == question.correctAnswerIndex)
        .length;
  }

  /// Calculates the total number of incorrect answers
  int get totalIncorrectAnswers {
    return questions
        .where((question) =>
            question.selectedAnswerIndex != null &&
            question.selectedAnswerIndex != question.correctAnswerIndex)
        .length;
  }

  /// Calculates the accuracy as a percentage
  int get totalAccuracy {
    return ((totalCorrectAnswers / totalQuestions) * 100).toInt();
  }
}

class QuestionModel {
  /// Question
  final String question;

  /// List of options
  final List<String> options;

  /// Index of correct answer in options list
  final int correctAnswerIndex;

  /// Index of user's selected answer. Null if no answer is selected
  int? selectedAnswerIndex;

  /// Constructor
  QuestionModel(
      {required this.question,
      required this.options,
      required this.correctAnswerIndex}) {
        setCorrectAnswerIndex(correctAnswerIndex);
      }

      void setCorrectAnswerIndex(int index) {
        if (index < 0 || index >= options.length) {
          throw ArgumentError("Correct Answer Index of question \n\"$question\"\nmust be within the range of available options.");
        }
      }
}
