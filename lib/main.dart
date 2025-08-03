import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'models/question_model.dart';
import 'models/session_model.dart';
import 'models/vote_model.dart';
import 'models/user_model.dart';
import 'models/device_model.dart';
import 'models/audit_log_model.dart';
import 'models/result_model.dart';

import 'screens/home_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/voter_join_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/admin_results_screen.dart';
import 'screens/voting_screen.dart';
import 'screens/qr_scanner_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicjalizacja Hive z uwzględnieniem Web vs reszta platform
  if (kIsWeb) {
    await Hive.initFlutter();
  } else {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
  }

  // Rejestracja wszystkich adapterów
  Hive.registerAdapter(SessionModelAdapter());
  Hive.registerAdapter(QuestionModelAdapter());
  Hive.registerAdapter(VoteModelAdapter());
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(DeviceModelAdapter());
  Hive.registerAdapter(AuditLogModelAdapter());
  Hive.registerAdapter(ResultModelAdapter());

  runApp(PwaPoolApp());
}

class PwaPoolApp extends StatelessWidget {
  const PwaPoolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PWA Pool App',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/admin': (context) => const AdminScreen(),
        '/voter': (context) => const VoterJoinScreen(),
        '/admin_dashboard': (context) => const AdminDashboardScreen(),
        '/admin_results': (context) => const AdminResultsScreen(),
        '/qr': (context) => const QrScannerScreen(),
        '/vote': (context) => const VotingScreen(),
      },
    );
  }
}
