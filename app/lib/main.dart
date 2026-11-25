
import 'package:flutter/material.dart';
import 'screens/notes_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AIStudyCompanion());
}

class AIStudyCompanion extends StatelessWidget {
  const AIStudyCompanion({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Study Companion',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        useMaterial3: true,
      ),
      home: const NotesScreen(),
    );
  }
}
