
# MCQ Quiz App

The MCQ Quiz App is an interactive platform for creating and managing multiple-choice quizzes. Developed using Flutter and Firebase, the app offers seamless backend integration with Firebase Firestore to store and retrieve quiz questions. Key features include a timed quiz interface, real-time score tracking, and dynamic question navigation. Users can participate in quizzes, receive immediate feedback on their performance, and view their final scores on a dedicated result screen. The app provides a user-friendly experience with a clean design, making it suitable for both educational and entertainment purposes.


## Features

Features

1. MCQ Management:

-> Add MCQs:
Users can add new multiple-choice questions.
Input fields for the question, multiple    options, and the correct answer index.

-> Edit MCQs:
Users can edit existing questions and their respective options.

-> Delete MCQs:
Users can delete questions from the database.

2. Quiz Mode:

-> Dynamic Question Display:
Fetches questions from Firebase Firestore and displays them one by one.

-> Timer:
Each question has a countdown timer (e.g., 60 seconds) to add a sense of urgency.

-> Answer Selection:
Users can select an answer from multiple options.

-> Score Calculation:
Keeps track of the user’s score based on the correctness of their answers.

-> Automatic Next Question:
Automatically moves to the next question when the timer runs out or when the user submits an answer.

-> End Quiz:
Automatically ends the quiz when all questions have been answered or the timer runs out.

3. Result Screen:

-> Score Display:
Displays the user's score and the total number of questions.

-> Retake Quiz:
Provides an option to retake the quiz.

-> Go to Home:
Allows users to navigate back to the home screen.

4. Additional Functionalities
-> 
Real-time Data Sync:
Uses Firebase Firestore for real-time data synchronization, ensuring that all users see the most up-to-date questions and options.

-> User-Friendly Interface:
Designed with a clean and intuitive interface for easy navigation and interaction.

-> Responsive Design:
Ensures a seamless experience across different device sizes and orientations.

5. Advanced Features
-> Progress Tracking:
Visual indicators for the current question and progress through the quiz.

-> Error Handling:
Handles various error scenarios like network issues or Firestore read/write failures gracefully.

-> Authentication (Optional):
Firebase Authentication for user login and personalized quiz history (if implemented).



## Tech Stack

**Front-End:** Dart, Flutter

**Server:** Firebase

**Database:** Firestore

