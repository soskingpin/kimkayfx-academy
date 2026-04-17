import 'package:flutter/material.dart';

void main() {
  runApp(const KimKayFXApp());
}

class KimKayFXApp extends StatelessWidget {
  const KimKayFXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KimKayFX Academy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MinimalHomeScreen(),
    );
  }
}

class MinimalHomeScreen extends StatelessWidget {
  const MinimalHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KimKayFX Academy'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '✅ App is working!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Open WhatsApp with pre-filled message
                const message = 'Hi KimKayFX, I want to purchase: VVIP Signals Lifetime';
                final url = 'https://wa.me/263771234567?text=${Uri.encodeComponent(message)}';
                // Note: url_launcher not included yet - this is just a placeholder
              },
              child: const Text('Test Purchase Flow'),
            ),
          ],
        ),
      ),
    );
  }
}
