import 'package:delta_explorer/constants/quiz.dart';
import 'package:delta_explorer/database/supabase.dart';

import '../quick_quiz/Model/quiz_model.dart';

class QuizController {
  final SupabaseDB _db = SupabaseDB();
  List<Map<String, dynamic>> _questions = [];
  final List<QuestionModel> _questionModel = [];

  List<Map<String, dynamic>> _pastQuiz = [];

  Future<void> getQuestions() async {
    var list = await _db.getQuestions();
    list.shuffle();
    list = list.sublist(0, 7); //random 7 question per quiz
    print("Domande: $list");
    _questions = list;
  }

  Quiz buildQuiz() {
    print("modello: ${_questionModel.length}");

    return Quiz(questions: _questionModel, timerDuration: 30);
  }

  Future<void> buildQuestionModel() async {
    _questionModel.clear();

    for (var question in _questions) {
      List<String> options = [];
      String? correctAnswer;

      var response = await _db.getAnswers(question["id"]);

      for (var answer in response) {
        options.add(answer["answer"]);
        if (answer["correct"] == true) {
          correctAnswer = answer["answer"];
        }
      }

      options.shuffle();

      // Trova il nuovo indice della risposta corretta
      int correctIndex = options.indexOf(correctAnswer!);

      _questionModel.add(
        QuestionModel(
          question: question["question"],
          options: options,
          correctAnswerIndex: correctIndex,
        ),
      );
    }
  }

  Future<void> saveResult(
    int accuracy,
    int duration,
    int skipped,
    int incorrect,
    int score,
  ) async {
    await _db.saveQuizResult(accuracy, duration, skipped, incorrect, score);
  }

  Future<void> fetchPastQuiz({single = false})async{
    _pastQuiz = await _db.getPastQuiz();
  }

  List<Map<String, dynamic>> getPastQuiz(){
    return _pastQuiz;
  }










  /*only for populate database*/
  Future<void> populateQuestion() async {
    var questionList = QuizConstant().getQuestions();

    for (var questionMap in questionList) {
      await _db.insertQuestionQuiz(
        questionMap["question"],
        questionMap["options"],
      );
    }
  }
}
