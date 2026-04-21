import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exam App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ExamScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  int currentQuestionIndex = 0;
  int? selectedOptionIndex;
  bool showAnswer = false;
  final Map<int, int?> userAnswers = {};

  // Timer variables
  int _remainingSeconds = 2700; // 45 minutes = 2700 seconds
  Timer? _timer;
  bool _isTimeExpired = false;

  final List<Question> questions = [
    Question(
      text:
          "Which callback is the first to be called in the Android Activity Lifecycle?",
      options: ["onStart()", "onCreate()", "onResume()"],
      correctIndex: 1,
    ),
    Question(
      text:
          "Which method is called when the Activity becomes visible to the user?",
      options: ["onCreate()", "onStart()", "onResume()"],
      correctIndex: 1,
    ),
    Question(
      text: "What does the 'setState()' method do in Flutter?",
      options: [
        "Rebuilds the entire app",
        "Notifies the framework that the internal state has changed",
        "Creates a new State object",
      ],
      correctIndex: 1,
    ),
    Question(
      text: "Which widget is used for scrolling content in Flutter?",
      options: ["Container", "Column", "SingleChildScrollView"],
      correctIndex: 2,
    ),
    Question(
      text: "What is the purpose of 'pubspec.yaml' in Flutter?",
      options: [
        "To write application logic",
        "To declare dependencies and assets",
        "To define the app's theme",
      ],
      correctIndex: 1,
    ),
    Question(
      text: "Which command is used to get dependencies in Flutter?",
      options: ["flutter run", "flutter get", "flutter pub get"],
      correctIndex: 2,
    ),
    Question(
      text: "What does 'Hot Reload' do in Flutter?",
      options: [
        "Restarts the entire app",
        "Injects updated code without losing state",
        "Rebuilds the APK",
      ],
      correctIndex: 1,
    ),
    Question(
      text: "Which layout widget arranges children in a horizontal line?",
      options: ["Column", "Row", "Stack"],
      correctIndex: 1,
    ),
    Question(
      text:
          "What is the default return type of 'build' method in StatelessWidget?",
      options: ["Widget", "Element", "RenderObject"],
      correctIndex: 0,
    ),
    Question(
      text: "Which state management solution is built into Flutter?",
      options: ["Provider", "Bloc", "setState"],
      correctIndex: 2,
    ),
  ];

  int get totalQuestions => questions.length;
  String get subject => "Android Development";

  String get timeRemaining {
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  void initState() {
    super.initState();
    _loadSelectedOption();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        // Time's up!
        _timer?.cancel();
        _isTimeExpired = true;
        _submitQuiz(); // Auto-submit when time expires
      }
    });
  }

  void _loadSelectedOption() {
    setState(() {
      selectedOptionIndex = userAnswers[currentQuestionIndex];
      showAnswer = false;
    });
  }

  void _selectOption(int index) {
    if (_isTimeExpired) return; // Can't answer if time expired

    setState(() {
      selectedOptionIndex = index;
      userAnswers[currentQuestionIndex] = index;
      showAnswer = false;
    });
  }

  void _nextQuestion() {
    if (_isTimeExpired) return;

    if (currentQuestionIndex < totalQuestions - 1) {
      setState(() {
        currentQuestionIndex++;
        _loadSelectedOption();
      });
    }
  }

  void _previousQuestion() {
    if (_isTimeExpired) return;

    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
        _loadSelectedOption();
      });
    }
  }

  void _showAnswer() {
    if (_isTimeExpired) return;

    setState(() {
      showAnswer = true;
    });
  }

  void _submitQuiz() {
    _timer?.cancel();

    int score = 0;
    for (int i = 0; i < totalQuestions; i++) {
      if (userAnswers[i] == questions[i].correctIndex) {
        score++;
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              _isTimeExpired ? Icons.timer_off : Icons.quiz,
              color: Colors.deepPurple,
            ),
            const SizedBox(width: 8),
            Text(_isTimeExpired ? "Time's Up!" : "Quiz Submitted"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your Score: $score / $totalQuestions",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: score / totalQuestions,
              backgroundColor: Colors.grey.shade200,
              color: score / totalQuestions >= 0.6
                  ? Colors.green
                  : Colors.orange,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 16),
            Text(
              "${(score / totalQuestions * 100).toStringAsFixed(1)}% - ${score >= totalQuestions * 0.6 ? "Passed" : "Failed"}",
              style: const TextStyle(fontSize: 16),
            ),
            if (_isTimeExpired)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  "Time has expired! Your answers have been automatically submitted.",
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Close"),
          ),
          if (score < totalQuestions)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  // Reset everything
                  _remainingSeconds = 2700; // Reset to 45 minutes
                  _isTimeExpired = false;
                  userAnswers.clear();
                  selectedOptionIndex = null;
                  currentQuestionIndex = 0;
                  _loadSelectedOption();
                  _startTimer(); // Restart timer
                });
              },
              child: const Text("Retry"),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = questions[currentQuestionIndex];

    // Get timer color based on remaining time
    Color timerColor = Colors.deepPurple;
    if (_remainingSeconds <= 300) {
      // Last 5 minutes
      timerColor = Colors.red;
    } else if (_remainingSeconds <= 600) {
      // Last 10 minutes
      timerColor = Colors.orange;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header with University Logo, Name, and Subject
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Logo and University Name Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // University Logo
                      Image.asset(
                        'assets/images/dire_dawa_logo.jpg', // Change this to your actual image filename
                        height: 50,
                        width: 50,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.school,
                              color: Colors.deepPurple,
                              size: 30,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      // University Name
                      Text(
                        "DIRE DAWA UNIVERSITY",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple.shade800,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Subject and Time Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Subject: $subject",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: timerColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: timerColor),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.timer, size: 18, color: timerColor),
                            const SizedBox(width: 4),
                            Text(
                              "Time Remaining: $timeRemaining",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: timerColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Warning banner for last minute
            if (_remainingSeconds <= 60)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Less than 1 minute remaining!",
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (_remainingSeconds <= 60) const SizedBox(height: 12),

            // Question Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Question ${currentQuestionIndex + 1} of $totalQuestions",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.deepPurple.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        currentQuestion.text,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: List.generate(currentQuestion.options.length, (
                  index,
                ) {
                  bool isSelected = selectedOptionIndex == index;
                  bool isCorrect =
                      showAnswer && index == currentQuestion.correctIndex;
                  bool isWrong =
                      showAnswer &&
                      isSelected &&
                      index != currentQuestion.correctIndex;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? Colors.deepPurple
                            : (showAnswer
                                  ? Colors.grey.shade300
                                  : Colors.grey.shade300),
                        width: isSelected ? 2 : 1,
                      ),
                      color: isCorrect
                          ? Colors.green.shade50
                          : (isWrong ? Colors.red.shade50 : Colors.white),
                    ),
                    child: RadioListTile<int>(
                      value: index,
                      groupValue: selectedOptionIndex,
                      onChanged: (_isTimeExpired || showAnswer)
                          ? null
                          : (value) => _selectOption(value!),
                      title: Text(
                        currentQuestion.options[index],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected
                              ? FontWeight.w500
                              : FontWeight.normal,
                          color: isCorrect
                              ? Colors.green.shade800
                              : (isWrong
                                    ? Colors.red.shade800
                                    : Colors.black87),
                        ),
                      ),
                      activeColor: Colors.deepPurple,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Show Answer Feedback
            if (showAnswer && selectedOptionIndex != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: selectedOptionIndex == currentQuestion.correctIndex
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        selectedOptionIndex == currentQuestion.correctIndex
                            ? Icons.check_circle
                            : Icons.cancel,
                        color:
                            selectedOptionIndex == currentQuestion.correctIndex
                            ? Colors.green.shade800
                            : Colors.red.shade800,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          selectedOptionIndex == currentQuestion.correctIndex
                              ? "Correct! Well done."
                              : "Incorrect. The correct answer is: ${currentQuestion.options[currentQuestion.correctIndex]}",
                          style: TextStyle(
                            color:
                                selectedOptionIndex ==
                                    currentQuestion.correctIndex
                                ? Colors.green.shade800
                                : Colors.red.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const Spacer(),

            // Navigation Buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Previous Button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: (_isTimeExpired || currentQuestionIndex == 0)
                          ? null
                          : _previousQuestion,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text("Previous"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.deepPurple.shade300),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Next Button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                          (_isTimeExpired ||
                              currentQuestionIndex == totalQuestions - 1)
                          ? null
                          : _nextQuestion,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text("Next"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.deepPurple.shade300),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Show Answer Button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: (_isTimeExpired || selectedOptionIndex == null)
                          ? null
                          : _showAnswer,
                      icon: const Icon(Icons.visibility),
                      label: const Text("Show Answer"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.orange.shade400),
                        foregroundColor: Colors.orange.shade800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Submit Quiz Button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isTimeExpired ? null : _submitQuiz,
                      icon: const Icon(Icons.check_circle),
                      label: const Text("Submit Quiz"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: _isTimeExpired
                            ? Colors.grey
                            : Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Question {
  final String text;
  final List<String> options;
  final int correctIndex;

  Question({
    required this.text,
    required this.options,
    required this.correctIndex,
  });
}
