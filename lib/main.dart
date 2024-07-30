import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mcq_quiz/screens/add_mcqs_screen.dart';
import 'package:mcq_quiz/screens/edit_mcqs_screen.dart';
import 'package:mcq_quiz/screens/quiz_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MCQ Quiz App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        foregroundColor: Colors.black,
        backgroundColor: Colors.blue,
        elevation: 5,
        title: const Text('MCQ Quiz Management', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.black,
                shadowColor: Colors.black,
                elevation: 5,
                fixedSize: const Size(300, 40),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddMCQFormScreen()),
                );
              },
              child: const Text('Add MCQs', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 25),),
            ),
            const SizedBox(height: 20,),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.black,
                shadowColor: Colors.black,
                elevation: 5,
                fixedSize: const Size(300, 40),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SelectMCQToEditScreen()),
                );
              },
              child: const Text('Edit MCQs', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 25),),
            ),
            const SizedBox(height: 20,),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.black,
                shadowColor: Colors.black,
                elevation: 5,
                fixedSize: const Size(300, 40),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QuizScreen()),
                );
              },
              child: const Text('Start Quiz', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 25),),
            ),
          ],
        ),
      ),
    );
  }
}

class SelectMCQToEditScreen extends StatelessWidget {
  const SelectMCQToEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        foregroundColor: Colors.black,
        backgroundColor: Colors.blue,
        elevation: 5,
        title: const Text('Select MCQ to Edit', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('mcqs').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading MCQs'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No MCQs available'));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return ListTile(
                title: Text(doc['question']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditMCQFormScreen(mcqId: doc.id),
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
