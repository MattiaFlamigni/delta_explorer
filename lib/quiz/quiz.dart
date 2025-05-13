import 'package:delta_explorer/quiz/quizController.dart';
import 'package:flutter/material.dart';
import 'package:quick_quiz/quick_quiz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://cvperzyahqhkdcjjtqvm.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN2cGVyenlhaHFoa2Rjamp0cXZtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDMyOTM3MjcsImV4cCI6MjA1ODg2OTcyN30.jj0Rkztp-QwX9sPXaAXXp8eGLz9YJ5ni1Z1EplxIX6I',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Quick Quiz Example'),
        ),
        body: Builder(
          builder: (context) => Center(
            child: TextButton(
              child: const Text(
                "Play Quiz",
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const QuizScreen(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});


  @override
  State<QuizScreen> createState() => _QuizScreenState();
}


class _QuizScreenState extends State<QuizScreen> {
  final QuizController controller = QuizController();
  bool isLoading = true;



  @override
  void initState() {
    super.initState();

    //controller.populateQuestion().then((_){setState(() {});});   N.B. la riga sotto va chiamata dentro la prima, serve solo per popolare il database in automatico
    controller.getQuestions().then((_) =>controller.buildQuestionModel().then((_) => setState(() {isLoading = false;})));


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
      ),
      body: isLoading? Text("loading") : QuizPage(quiz: controller.buildQuiz())
    );
  }


  Future<void> populate()async{

  }






}
