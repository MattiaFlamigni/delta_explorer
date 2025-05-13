import 'package:delta_explorer/constants/quiz.dart';
import 'package:delta_explorer/quiz/quizController.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryQuiz extends StatefulWidget {
  const HistoryQuiz({super.key});

  @override
  State<HistoryQuiz> createState() => _HistoryQuizState();
}

class _HistoryQuizState extends State<HistoryQuiz> {
  QuizController controller = QuizController();
  bool isLoading = true;


  @override
  void initState() {
    super.initState();
    controller.fetchPastQuiz().then((_){setState(() {
      isLoading=false;
    });});
  }

  @override
  Widget build(BuildContext context) {
    return  isLoading ?  Center(child: CircularProgressIndicator()) : Scaffold(
      appBar: AppBar(
        title: const Text('History of Quizzes'),
      ),
      body: ListView.builder(
        itemCount: controller.getPastQuiz().length,
        itemBuilder: (context, index) {
          final quiz = controller.getPastQuiz()[index];
          return drawCard(quiz);
        },
      ),
    );
  }


  Widget drawCard(Map<String, dynamic> quiz){
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: quizInfo(quiz)
      ),
    );
  }

  Widget quizInfo(Map<String, dynamic> quiz){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(quiz['created_at']))}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Score: ${(quiz['score'] * 100 / QuizConstant.totalQuestion).toStringAsFixed(2)}%',
              style: const TextStyle(fontSize: 14, color: Colors.green),
            ),
            Text(
              'Duration: ${quiz['duration']}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Correct: ${quiz['score']}',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Incorrect: ${quiz['incorrect']}',
              style: const TextStyle(fontSize: 14, color: Colors.red),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Skipped: ${quiz['skipped']}',
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}
