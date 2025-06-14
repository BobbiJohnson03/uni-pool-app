import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'models/question_model.dart';
import 'models/session_model.dart';
import 'screens/home_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/voter_join_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/admin_results_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Hive.registerAdapter(SessionModelAdapter());
  Hive.registerAdapter(QuestionModelAdapter());

  runApp(PwaPoolApp());
}

class PwaPoolApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PWA Pool App',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/admin': (context) => AdminScreen(),
        '/voter': (context) => const VoterJoinScreen(),
        '/admin_dashboard': (context) => const AdminDashboardScreen(),
        '/admin_results': (context) => AdminResultsScreen(),
      },
    );
  }
}
