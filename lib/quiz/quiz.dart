import 'package:delta_explorer/quiz/history.dart';
import 'package:delta_explorer/quiz/quizController.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../components/loginRequest.dart';
import '../constants/quiz.dart';
import '../quick_quiz/pages/quiz.dart';

class DeltaQuiz extends StatelessWidget {
  const DeltaQuiz({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Delta Explorer Quiz',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Nunito',

        textTheme: const TextTheme(
          // Defining text styles
          displayLarge: TextStyle(
            fontSize: 32.0,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          titleLarge: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          bodyLarge: TextStyle(fontSize: 18.0, color: Colors.black87),
          bodyMedium: TextStyle(fontSize: 16.0, color: Colors.black54),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            // Consistent button styling
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            textStyle: const TextStyle(fontSize: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: Colors.blue,
            // Primary color
            foregroundColor: Colors.white,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            textStyle: const TextStyle(fontSize: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            side: const BorderSide(color: Colors.blue),
            // Use primary color for the border.  Added const
            foregroundColor: Colors.blue,
          ),
        ),
        cardTheme: CardTheme(
          // Consistent card styling
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.only(bottom: 20),
        ),
        appBarTheme: const AppBarTheme(
          // App bar styling
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          backgroundColor: Colors.blue,
          elevation: 0, // remove shadow
          centerTitle: true,
        ),
      ),
      home: const QuizStartScreen(),
    );
  }
}

class QuizStartScreen extends StatefulWidget {
  const QuizStartScreen({super.key});

  @override
  State<QuizStartScreen> createState() => _QuizStartScreenState();
}

class _QuizStartScreenState extends State<QuizStartScreen> {
  late QuizController controller = QuizController();
  bool isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    controller.fetchPastQuiz().then((_) {
      setState(() {
        isDataLoaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Avvia Quiz')),
      body:
          controller.isUserAuth() == null
              ? requestLogin()
              : isDataLoaded
              ? Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 30.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    drawCard(),
                    const SizedBox(height: 30),
                    drawStartQuizBtn(),
                    const SizedBox(height: 15),
                    drawPastQuizBtn(),
                  ],
                ),
              )
              : CircularProgressIndicator(),
    );
  }

  Widget drawPastQuizBtn() {
    return OutlinedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HistoryQuiz()),
        );
      },
      child: const Text("Vedi Risultati Passati"),
    );
  }

  Widget drawStartQuizBtn() {
    return ElevatedButton(
      onPressed:
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const QuizScreen()),
          ),
      child: const Text("Avvia Quiz"),
    );
  }

  Widget drawCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: drawLastQuizInfo(),
      ),
    );
  }

  Widget drawLastQuizInfo() {
    var quiz = controller.getPastQuiz().last;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("Ultimo Quiz", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(quiz['created_at']))}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              "Punteggio: ${((quiz["score"] / QuizConstant.totalQuestion) * 100).toStringAsFixed(2)}%",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              "Durata: ${quiz["duration"]} sec",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ],
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

    controller.getQuestions().then((_) {
      controller.buildQuestionModel().then((_) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: Center(
        child:
            isLoading
                ? const CircularProgressIndicator(strokeWidth: 3.0)
                : QuizPage(quiz: controller.buildQuiz()),
      ),
    );
  }
}
