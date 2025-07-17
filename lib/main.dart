import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart'; // do Hive.init()
import 'models/question_model.dart';
import 'models/session_model.dart';
import 'models/vote_model.dart'; // <- DODANE
import 'screens/home_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/voter_join_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/admin_results_screen.dart';
import 'screens/voting_screen.dart';
import 'screens/qr_scanner_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicjalizacja Hive z lokalizacją katalogu aplikacji (dla Android/iOS/Desktop)
  final dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);

  // Rejestracja adapterów Hive
  Hive.registerAdapter(SessionModelAdapter());
  Hive.registerAdapter(QuestionModelAdapter());
  Hive.registerAdapter(VoteModelAdapter()); // <- DODANE

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
        '/qr': (context) => const QrScannerScreen(),
        '/vote': (context) {
          final session =
              ModalRoute.of(context)!.settings.arguments as SessionModel;
          return VotingScreen(session: session);
        },
      },
    );
  }
}
