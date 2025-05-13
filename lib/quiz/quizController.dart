import 'package:delta_explorer/constants/quiz.dart';
import 'package:delta_explorer/database/supabase.dart';
import 'package:quick_quiz/quick_quiz.dart';

class QuizController{
  final SupabaseDB _db = SupabaseDB();
  List<Map<String, dynamic>> _questions = [];
  final List<QuestionModel> _questionModel = [];


  Future<void> getQuestions() async {
    var list = await _db.getQuestions();
    list.shuffle(); list = list.sublist(0,7); //random 7 question per quiz
    print("Domande: $list");
    _questions = list;
  }

  Quiz buildQuiz()  {

    print("modello: ${_questionModel.length}");

    return Quiz(questions: _questionModel, timerDuration: 30);
  }

  Future<void> buildQuestionModel() async {

    _questionModel.clear();
    int correctIndex = -1;

    for(var question in _questions){
      List<String> option = [];
      var response = await  _db.getAnswers(question["id"]);
      print("response: $response");
      for(int i=0; i<response.length; i++){
        option.add(response[i]["answer"]);
        if(response[i]["correct"]){
          correctIndex = i;
        }
      }

      _questionModel.add(
        QuestionModel(question: question["question"], options: option, correctAnswerIndex: correctIndex)

      );

    }
  }








  /*only for populate database*/
  Future<void> populateQuestion() async {
    var questionList = QuizConstant().getQuestions();

    for (var questionMap in questionList) {
      await _db.insertQuestionQuiz(
          questionMap["question"],
          questionMap["options"]
      );
    }
  }


}