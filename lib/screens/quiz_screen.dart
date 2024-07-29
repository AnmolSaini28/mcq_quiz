import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mcq_quiz/models/mcq_model.dart';
import 'package:mcq_quiz/screens/result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late Stream<List<MCQ>> _mcqStream;
  Timer? _timer;
  int _timeLeft = 60;
  int _currentQuestionIndex = 0;
  int _score = 0;
  List<int?> _selectedAnswers = [];

  @override
  void initState() {
    super.initState();
    _mcqStream = FirebaseFirestore.instance.collection('mcqs').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return MCQ(
          id: doc.id,
          question: data['question'],
          options: List<String>.from(data['options']),
          correctAnswerIndex: data['correctAnswerIndex'],
        );
      }).toList();
    });
    _mcqStream.first.then((questions) {
      setState(() {
        _selectedAnswers = List<int?>.filled(questions.length, null);
      });
    });
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _nextQuestion();
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _selectedAnswers.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _timeLeft = 60;
      });
    } else {
      _endQuiz();
    }
  }

  void _submitAnswer(int selectedIndex) {
    setState(() {
      _selectedAnswers[_currentQuestionIndex] = selectedIndex;
      _mcqStream.first.then((questions) {
        final question = questions[_currentQuestionIndex];
        if (question.correctAnswerIndex == selectedIndex) {
          _score++;
        }
        _nextQuestion();
      });
    });
  }

  void _endQuiz() {
    _timer?.cancel();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          score: _score,
          totalQuestions: _selectedAnswers.length,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        foregroundColor: Colors.black,
        backgroundColor: Colors.blue,
        elevation: 5,
        title: const Text('Quiz Screen', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
      ),
      body: StreamBuilder<List<MCQ>>(
        stream: _mcqStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No questions available'));
          }

          final question = snapshot.data![_currentQuestionIndex];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Time Left: $_timeLeft seconds',
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Text(
                  'Question ${_currentQuestionIndex + 1}:',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.blueGrey),
                ),
                const SizedBox(height: 10),
                Text(
                  question.question,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                const SizedBox(height: 20),
                ...question.options.asMap().entries.map((entry) {
                  int index = entry.key;
                  String option = entry.value;
                  return ListTile(
                    title: Text(option, style: const TextStyle(fontSize: 15, color: Colors.black),),
                    leading: Radio<int>(
                      value: index,
                      groupValue: _selectedAnswers[_currentQuestionIndex],
                      onChanged: (value) {
                        _submitAnswer(index);
                      },
                    ),
                  );
                }).toList(),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.black,
                      shadowColor: Colors.black,
                      elevation: 5,
                      fixedSize: const Size(150, 40),
                    ),
                    onPressed: _nextQuestion,
                    child: const Text('Next Question', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

