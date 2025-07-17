import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Home',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {},
                child: const Text('OSTATNIE GŁOSOWANIA'),
              ),
              const SizedBox(height: 32),
              const Text(
                'DOŁĄCZ DO GŁOSOWANIA',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text('WYBIERZ SPOSÓB ŁĄCZENIA:'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/qr');
                },
                child: const Text('SKANUJ KOD QR'),
              ),

              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/voter');
                },
                child: const Text('WPISZ KOD RĘCZNIE'),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.bottomLeft,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/admin_dashboard');
                  },
                  child: const Text(
                    'zaloguj się jako administrator',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
